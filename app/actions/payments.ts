"use server";

import prisma from "@/lib/prisma";
import { revalidatePath } from "next/cache";

export async function getPendingPayments() {
  return prisma.rentPaymentTransaction.findMany({
    where: { status: "SUBMITTED" },
    include: {
      rentPayment: {
        include: {
          member: true,
          month: true,
        }
      },
      payer: true,
    },
    orderBy: { paidAt: "desc" }
  });
}

export async function getPaymentHistory() {
  return prisma.rentPaymentTransaction.findMany({
    include: {
      rentPayment: {
        include: { member: true, month: true }
      },
      payer: true,
    },
    orderBy: { paidAt: "desc" },
    take: 100, // Limit to recent 100 for now
  });
}

export async function confirmPayment(transactionId: string) {
  await prisma.$transaction(async (tx) => {
    const transaction = await tx.rentPaymentTransaction.findUnique({
      where: { id: transactionId },
      include: { rentPayment: true }
    });

    if (!transaction) throw new Error("Transaction not found");
    if (transaction.status === "CONFIRMED") throw new Error("Already confirmed");

    // 1. Update Transaction
    await tx.rentPaymentTransaction.update({
      where: { id: transactionId },
      data: { 
        status: "CONFIRMED",
        verifiedAt: new Date()
      }
    });

    // 2. Update Rent Payment Record
    const newAmountPaid = transaction.rentPayment.amountPaid + transaction.amount;
    const isFullyPaid = newAmountPaid >= transaction.rentPayment.amountDue;

    await tx.rentPayment.update({
      where: { id: transaction.rentPaymentId },
      data: {
        amountPaid: newAmountPaid,
        status: isFullyPaid ? "PAID" : "PARTIAL"
      }
    });

    // 2.5 Generate Debt if paid by someone else
    if (transaction.payerId && transaction.payerId !== transaction.rentPayment.memberId) {
      await tx.debt.create({
        data: {
          debtorId: transaction.rentPayment.memberId,
          creditorId: transaction.payerId,
          amount: transaction.amount,
          reason: "Rent Payment",
          status: "OPEN"
        }
      });
    }

    // 3. Log Activity
    await tx.activityLog.create({
      data: {
        entity: "RentPaymentTransaction",
        entityId: transaction.id,
        action: "Confirmed Payment",
        newValue: { amount: transaction.amount, method: transaction.method }
      }
    });
  });

  revalidatePath("/admin/payments");
  revalidatePath("/admin/rent");
  revalidatePath("/admin");
}

export async function rejectPayment(transactionId: string) {
  await prisma.$transaction(async (tx) => {
    await tx.rentPaymentTransaction.update({
      where: { id: transactionId },
      data: { status: "REJECTED", verifiedAt: new Date() }
    });

    await tx.activityLog.create({
      data: {
        entity: "RentPaymentTransaction",
        entityId: transactionId,
        action: "Rejected Payment",
      }
    });
  });

  revalidatePath("/admin/payments");
}
