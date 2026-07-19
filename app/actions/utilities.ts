"use server";

import { prisma } from "@/lib/prisma";
import { revalidatePath } from "next/cache";
import { SplitType, DebtStatus, PaymentStatus } from "@prisma/client";

export async function addUtility(data: {
  monthId: string;
  paidById: string;
  name: string;
  amount: number;
  splitType: SplitType;
  dueDate?: Date;
  attachmentUrl?: string;
  splits: { memberId: string; amount: number }[];
}) {
  return await prisma.$transaction(async (tx) => {
    // 1. Create the Utility
    const utility = await tx.utility.create({
      data: {
        monthId: data.monthId,
        paidById: data.paidById,
        name: data.name,
        amount: data.amount,
        splitType: data.splitType,
        dueDate: data.dueDate,
        attachmentUrl: data.attachmentUrl,
        status: PaymentStatus.PAID, // Since one person paid the entire bill on behalf of the house
        paidAt: new Date(),
      }
    });

    // 2. Create the Splits (UtilityPayment) and Generate Debts
    for (const split of data.splits) {
      if (split.amount <= 0) continue;

      const isSelf = split.memberId === data.paidById;

      await tx.utilityPayment.create({
        data: {
          utilityId: utility.id,
          memberId: split.memberId,
          amountDue: split.amount,
          amountPaid: isSelf ? split.amount : 0,
          status: isSelf ? PaymentStatus.PAID : PaymentStatus.PENDING,
        }
      });

      // 3. Generate member-to-member debt if someone else paid for them
      if (!isSelf) {
        await tx.debt.create({
          data: {
            debtorId: split.memberId,
            creditorId: data.paidById,
            amount: split.amount,
            reason: `Utility: ${utility.name}`,
            status: DebtStatus.OPEN,
          }
        });
      }
    }

    revalidatePath("/admin/utilities");
    return utility;
  });
}

export async function deleteUtility(utilityId: string) {
  return await prisma.$transaction(async (tx) => {
    const utility = await tx.utility.findUnique({
      where: { id: utilityId },
      include: { payments: true }
    });

    if (!utility) throw new Error("Utility not found");

    for (const split of utility.payments) {
      if (split.memberId !== utility.paidById && utility.paidById) {
        // Try to find the exact OPEN debt
        const openDebt = await tx.debt.findFirst({
          where: {
            debtorId: split.memberId,
            creditorId: utility.paidById,
            amount: split.amountDue,
            reason: `Utility: ${utility.name}`,
            status: DebtStatus.OPEN,
          }
        });

        if (openDebt) {
          await tx.debt.delete({ where: { id: openDebt.id } });
        } else {
          // Reversal
          await tx.debt.create({
            data: {
              debtorId: utility.paidById,
              creditorId: split.memberId,
              amount: split.amountDue,
              reason: `Reversal for deleted Utility: ${utility.name}`,
              status: DebtStatus.OPEN,
            }
          });
        }
      }
    }

    await tx.utility.delete({
      where: { id: utilityId }
    });

    revalidatePath("/admin/utilities");
  });
}
