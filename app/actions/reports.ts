"use server";

import prisma from "@/lib/prisma";

export async function getReportMetrics() {
  const [totalCollected, activeMembers, pendingSettlements, totalOpenDebt] = await Promise.all([
    prisma.rentPayment.aggregate({
      _sum: { amountPaid: true }
    }),
    prisma.member.count({ where: { active: true } }),
    prisma.debt.count({ where: { status: "OPEN" } }),
    prisma.debt.aggregate({
      where: { status: "OPEN" },
      _sum: { amount: true, settledAmount: true }
    })
  ]);

  const debtSum = (totalOpenDebt._sum.amount || 0) - (totalOpenDebt._sum.settledAmount || 0);

  return {
    totalCollected: totalCollected._sum.amountPaid || 0,
    activeMembers,
    pendingSettlements,
    totalOpenDebt: debtSum
  };
}

export async function getMonthlyRentData() {
  const months = await prisma.month.findMany({
    orderBy: { startsOn: "asc" },
    take: 12, // last 12 months
    include: {
      rentPayments: true
    }
  });

  return months.map(m => {
    const collected = m.rentPayments.reduce((acc, curr) => acc + curr.amountPaid, 0);
    const due = m.rentPayments.reduce((acc, curr) => acc + curr.amountDue, 0);
    return {
      month: m.startsOn.toLocaleDateString("en-US", { month: "short", year: "2-digit" }),
      collected,
      pending: due - collected > 0 ? due - collected : 0
    };
  });
}
