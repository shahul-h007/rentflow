"use server";

import { prisma } from "@/lib/prisma";
import { revalidatePath } from "next/cache";

export async function upsertDebt(debtorId: string, creditorId: string, amount: number, reason: string) {
  if (debtorId === creditorId || amount <= 0) return;

  // We are netting at the user level? 
  // No, the user explicitly approved adding specific settlement records so they can see line items.
  // Wait, if I create a new Debt record for each, then "Current Balances" needs to aggregate them in the UI.
  // That's what I will do. Let's just create a new Debt.
  await prisma.debt.create({
    data: {
      debtorId,
      creditorId,
      amount,
      reason,
      status: "OPEN",
    }
  });
}

export async function getSettlements() {
  const pending = await prisma.debt.findMany({
    where: { status: "OPEN" },
    include: {
      debtor: true,
      creditor: true,
    },
    orderBy: { createdAt: "desc" }
  });

  const history = await prisma.debt.findMany({
    where: { status: { in: ["SETTLED", "CANCELLED"] } },
    include: {
      debtor: true,
      creditor: true,
    },
    orderBy: { settledAt: "desc" },
    take: 50
  });

  return { pending, history };
}

export async function settleDebt(debtId: string, amount: number, method: string) {
  await prisma.$transaction(async (tx) => {
    const debt = await tx.debt.findUnique({ where: { id: debtId }, include: { debtor: true, creditor: true } });
    if (!debt) throw new Error("Debt not found");
    if (debt.status !== "OPEN") throw new Error("Debt is not open");
    if (amount <= 0 || amount > (debt.amount - debt.settledAmount)) {
      throw new Error("Invalid settlement amount");
    }

    const newSettledAmount = debt.settledAmount + amount;
    const isFullySettled = newSettledAmount >= debt.amount;

    await tx.debt.update({
      where: { id: debtId },
      data: {
        settledAmount: newSettledAmount,
        status: isFullySettled ? "SETTLED" : "OPEN",
        settledAt: isFullySettled ? new Date() : null,
      }
    });

    // Log Activity
    await tx.activityLog.create({
      data: {
        entity: "Debt",
        entityId: debt.id,
        action: isFullySettled ? "Fully Settled Debt" : "Partially Settled Debt",
        newValue: { amount, method, debtor: debt.debtor.name, creditor: debt.creditor.name }
      }
    });
  });

  revalidatePath("/admin/settlements");
}

export async function cancelDebt(debtId: string) {
  await prisma.$transaction(async (tx) => {
    const debt = await tx.debt.findUnique({ where: { id: debtId }, include: { debtor: true, creditor: true } });
    if (!debt) throw new Error("Debt not found");
    
    await tx.debt.update({
      where: { id: debtId },
      data: { status: "CANCELLED", settledAt: new Date() }
    });

    await tx.activityLog.create({
      data: {
        entity: "Debt",
        entityId: debt.id,
        action: "Cancelled Debt",
        newValue: { debtor: debt.debtor.name, creditor: debt.creditor.name }
      }
    });
  });

  revalidatePath("/admin/settlements");
}
