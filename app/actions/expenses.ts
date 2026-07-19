"use server";

import { prisma } from "@/lib/prisma";
import { revalidatePath } from "next/cache";
import { SplitType, DebtStatus } from "@prisma/client";
import { upsertDebt } from "./settlements";

export async function addExpense(data: {
  monthId: string;
  paidById: string;
  title: string;
  amount: number;
  splitType: SplitType;
  notes?: string;
  receiptUrl?: string;
  splits: { memberId: string; amount: number }[];
}) {
  return await prisma.$transaction(async (tx) => {
    // 1. Create the Expense
    const expense = await tx.expense.create({
      data: {
        monthId: data.monthId,
        paidById: data.paidById,
        title: data.title,
        amount: data.amount,
        splitType: data.splitType,
        notes: data.notes,
        receiptUrl: data.receiptUrl,
      }
    });

    // 2. Create the Splits and Generate Debts
    for (const split of data.splits) {
      if (split.amount <= 0) continue;

      await tx.expenseSplit.create({
        data: {
          expenseId: expense.id,
          memberId: split.memberId,
          amount: split.amount,
        }
      });

      // 3. Generate member-to-member debt if someone else paid for them
      if (split.memberId !== data.paidById) {
        await tx.debt.create({
          data: {
            debtorId: split.memberId,
            creditorId: data.paidById,
            amount: split.amount,
            reason: `Expense: ${expense.title}`,
            status: DebtStatus.OPEN,
          }
        });
      }
    }

    revalidatePath("/admin/expenses");
    return expense;
  });
}

export async function deleteExpense(expenseId: string) {
  return await prisma.$transaction(async (tx) => {
    const expense = await tx.expense.findUnique({
      where: { id: expenseId },
      include: { splits: true }
    });

    if (!expense) throw new Error("Expense not found");

    // Reverting the debts is complex since they might be settled. 
    // If they are unsettled, we could delete them.
    // However, since we don't strictly tie the Debt record ID to the Expense Split (just by reason string),
    // it's safer to create a "REVERSAL" debt if it was already settled, or delete it if open.
    // For MVP, if we delete an expense, we will attempt to find and delete OPEN debts matching the reason.
    
    for (const split of expense.splits) {
      if (split.memberId !== expense.paidById) {
        // Try to find the exact OPEN debt
        const openDebt = await tx.debt.findFirst({
          where: {
            debtorId: split.memberId,
            creditorId: expense.paidById,
            amount: split.amount,
            reason: `Expense: ${expense.title}`,
            status: DebtStatus.OPEN,
          }
        });

        if (openDebt) {
          await tx.debt.delete({ where: { id: openDebt.id } });
        } else {
          // It was partially or fully settled. We must create a reversal debt.
          await tx.debt.create({
            data: {
              debtorId: expense.paidById, // Flipped! The payer now owes the member back
              creditorId: split.memberId,
              amount: split.amount,
              reason: `Reversal for deleted Expense: ${expense.title}`,
              status: DebtStatus.OPEN,
            }
          });
        }
      }
    }

    await tx.expense.delete({
      where: { id: expenseId }
    });

    revalidatePath("/admin/expenses");
  });
}
