import { NextResponse } from "next/server";
import { requireAdmin } from "@/lib/auth";
import { apiError } from "@/lib/http";
import { prisma } from "@/lib/prisma";

export async function POST(request: Request, { params }: { params: Promise<{ id: string }> }) {
  try {
    const user = await requireAdmin();
    const { id } = await params;

    // Fetch the transaction
    const transaction = await prisma.rentPaymentTransaction.findUnique({
      where: { id },
    });

    if (!transaction) {
      return NextResponse.json({ error: "Transaction not found" }, { status: 404 });
    }

    if (transaction.status !== "SUBMITTED") {
      return NextResponse.json({ error: "Only submitted transactions can be rejected" }, { status: 400 });
    }

    const updatedTransaction = await prisma.rentPaymentTransaction.update({
      where: { id },
      data: {
        status: "REJECTED",
        verifiedAt: new Date(),
      },
    });

    // Log the activity
    await prisma.activityLog.create({
      data: {
        actorId: user.id,
        entity: "rent_payment_transaction",
        entityId: id,
        action: "rejected",
        newValue: updatedTransaction,
      },
    });

    return NextResponse.json({ success: true, transaction: updatedTransaction });
  } catch (error) {
    return apiError(error);
  }
}
