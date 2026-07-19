"use server";

import prisma from "@/lib/prisma";
import { revalidatePath } from "next/cache";

export async function getHouseRentData(houseId: string) {
  const months = await prisma.month.findMany({
    where: { houseId },
    orderBy: { startsOn: "desc" },
    include: {
      rentPayments: {
        include: {
          member: true,
        },
      },
    },
  });

  return months;
}

export async function generateMonthlyRent(houseId: string, monthDate: Date) {
  // Check if month already exists
  const startOfMonth = new Date(monthDate.getFullYear(), monthDate.getMonth(), 1);
  const endOfMonth = new Date(monthDate.getFullYear(), monthDate.getMonth() + 1, 0);

  const existingMonth = await prisma.month.findFirst({
    where: {
      houseId,
      startsOn: startOfMonth,
    }
  });

  if (existingMonth) {
    throw new Error("Rent for this month has already been generated.");
  }

  const house = await prisma.house.findUnique({
    where: { id: houseId },
    include: { members: { where: { active: true } } }
  });

  if (!house || house.members.length === 0) {
    throw new Error("House not found or has no active members.");
  }

  const rentPerMember = Math.ceil(house.rent / house.members.length);

  // Generate Month and Rent Payments in a transaction
  const newMonth = await prisma.$transaction(async (tx) => {
    const month = await tx.month.create({
      data: {
        startsOn: startOfMonth,
        endsOn: endOfMonth,
        rent: house.rent,
        houseId,
        status: "OPEN",
      }
    });

    // Create rent records
    const rentPayments = house.members.map(member => ({
      monthId: month.id,
      memberId: member.id,
      amountDue: rentPerMember,
      status: "PENDING" as const,
    }));

    await tx.rentPayment.createMany({
      data: rentPayments
    });

    // Log Activity
    await tx.activityLog.create({
      data: {
        entity: "Month",
        entityId: month.id,
        action: "Generated Monthly Rent",
        newValue: { month: startOfMonth.toISOString(), rent: house.rent }
      }
    });

    return month;
  });

  revalidatePath("/admin/rent");
  return newMonth;
}

export async function closeMonth(monthId: string) {
  // Verify all rent payments are fully paid
  const month = await prisma.month.findUnique({
    where: { id: monthId },
    include: { rentPayments: true }
  });

  if (!month) throw new Error("Month not found");

  const hasUnpaid = month.rentPayments.some(p => p.amountPaid < p.amountDue);
  if (hasUnpaid) {
    throw new Error("Cannot close month until all members have fully paid their rent.");
  }

  await prisma.month.update({
    where: { id: monthId },
    data: { 
      status: "CLOSED",
      closedAt: new Date()
    }
  });
  
  await prisma.activityLog.create({
    data: {
      entity: "Month",
      entityId: monthId,
      action: "Closed Month",
    }
  });

  revalidatePath("/admin/rent");
}

export async function recalculateOpenMonths(houseId: string) {
  const house = await prisma.house.findUnique({
    where: { id: houseId },
    include: { members: { where: { active: true } } }
  });

  if (!house || house.members.length === 0) return;

  const rentPerMember = Math.ceil(house.rent / house.members.length);
  
  const openMonths = await prisma.month.findMany({
    where: { houseId, status: "OPEN" },
    include: { rentPayments: true }
  });

  for (const month of openMonths) {
    // For each active member, upsert the rent payment
    for (const member of house.members) {
      await prisma.rentPayment.upsert({
        where: {
          monthId_memberId: {
            monthId: month.id,
            memberId: member.id
          }
        },
        create: {
          monthId: month.id,
          memberId: member.id,
          amountDue: rentPerMember,
          status: "PENDING"
        },
        update: {
          amountDue: rentPerMember
        }
      });
    }

    // Delete pending payments for members who are no longer active
    const activeMemberIds = house.members.map(m => m.id);
    const inactivePayments = month.rentPayments.filter(p => !activeMemberIds.includes(p.memberId));
    
    for (const payment of inactivePayments) {
      if (payment.amountPaid === 0) {
        await prisma.rentPayment.delete({ where: { id: payment.id } });
      }
    }
  }

  revalidatePath("/admin/rent");
}


export async function reopenMonth(monthId: string) {
  await prisma.month.update({
    where: { id: monthId },
    data: { 
      status: "OPEN",
      closedAt: null
    }
  });
  
  await prisma.activityLog.create({
    data: {
      entity: "Month",
      entityId: monthId,
      action: "Reopened Month",
    }
  });

  revalidatePath("/admin/rent");
}

export async function deleteMonth(monthId: string) {
  const month = await prisma.month.findUnique({
    where: { id: monthId },
    include: {
      rentPayments: { include: { transactions: true } },
      utilities: { include: { payments: true } },
      expenses: { include: { splits: true } },
    }
  });

  if (!month) throw new Error("Month not found");

  await prisma.$transaction(async (tx) => {
    // 1. Delete rent payment transactions first
    for (const rp of month.rentPayments) {
      if (rp.transactions.length > 0) {
        await tx.rentPaymentTransaction.deleteMany({ where: { rentPaymentId: rp.id } });
      }
    }

    // 2. Delete rent payments
    await tx.rentPayment.deleteMany({ where: { monthId } });

    // 3. Delete utility payments, then utilities
    for (const util of month.utilities) {
      if (util.payments.length > 0) {
        await tx.utilityPayment.deleteMany({ where: { utilityId: util.id } });
      }
    }
    await tx.utility.deleteMany({ where: { monthId } });

    // 4. Delete expense splits, then expenses
    for (const exp of month.expenses) {
      if (exp.splits.length > 0) {
        await tx.expenseSplit.deleteMany({ where: { expenseId: exp.id } });
      }
    }
    await tx.expense.deleteMany({ where: { monthId } });


    // 6. Delete the month itself
    await tx.month.delete({ where: { id: monthId } });

    // 7. Log activity
    await tx.activityLog.create({
      data: {
        entity: "Month",
        entityId: monthId,
        action: "Deleted Month",
        newValue: { startsOn: month.startsOn.toISOString() },
      }
    });
  });

  revalidatePath("/admin/rent");
}
