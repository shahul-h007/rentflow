import { NextResponse } from "next/server";
import { requireAdmin } from "@/lib/auth";
import { apiError } from "@/lib/http";
import { prisma } from "@/lib/prisma";
import { PaymentStatus } from "@prisma/client";

export async function POST(request: Request, { params }: { params: Promise<{ id: string }> }) {
  try {
    const user = await requireAdmin();
    const { id } = await params;

    // Fetch the transaction
    const transaction = await prisma.rentPaymentTransaction.findUnique({
      where: { id },
      include: {
        rentPayment: true,
      },
    });

    if (!transaction) {
      return NextResponse.json({ error: "Transaction not found" }, { status: 404 });
    }

    if (transaction.status !== "SUBMITTED") {
      return NextResponse.json({ error: "Only submitted transactions can be confirmed" }, { status: 400 });
    }

    const updatedTransaction = await prisma.$transaction(async (tx) => {
      // 1. Confirm the transaction
      const updatedTx = await tx.rentPaymentTransaction.update({
        where: { id },
        data: {
          status: "CONFIRMED",
          verifiedAt: new Date(),
        },
      });

      // 2. Load latest rent payment status
      const rp = await tx.rentPayment.findUniqueOrThrow({
        where: { id: transaction.rentPaymentId },
      });

      const newAmountPaid = rp.amountPaid + transaction.amount;
      let newStatus: PaymentStatus = PaymentStatus.PENDING;
      if (newAmountPaid >= rp.amountDue) {
        newStatus = PaymentStatus.PAID;
      } else if (newAmountPaid > 0) {
        newStatus = PaymentStatus.PARTIAL;
      }

      // 3. Update the RentPayment record
      await tx.rentPayment.update({
        where: { id: transaction.rentPaymentId },
        data: {
          amountPaid: newAmountPaid,
          status: newStatus,
          paidAt: newStatus === PaymentStatus.PAID ? new Date() : rp.paidAt,
          method: transaction.method,
          reference: transaction.reference,
        },
      });

      // 4. If someone paid on behalf of another member, automatically create a settlement (Debt)
      // tenant = rp.memberId
      // payer = transaction.payerId
      if (transaction.payerId && transaction.payerId !== rp.memberId) {
        // Debtor is the tenant (rp.memberId)
        // Creditor is the payer (transaction.payerId)
        await tx.debt.create({
          data: {
            debtorId: rp.memberId,
            creditorId: transaction.payerId,
            amount: transaction.amount,
            settledAmount: 0,
            reason: `Rent coverage`,
            status: "OPEN",
          },
        });
      }

      return updatedTx;
    });

    // Log the activity
    await prisma.activityLog.create({
      data: {
        actorId: user.id,
        entity: "rent_payment_transaction",
        entityId: id,
        action: "confirmed",
        newValue: updatedTransaction,
      },
    });

    return NextResponse.json({ success: true, transaction: updatedTransaction });
  } catch (error) {
    return apiError(error);
  }
}
