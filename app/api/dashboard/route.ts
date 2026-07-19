import { Role, PaymentStatus } from "@prisma/client";
import { NextResponse } from "next/server";
import { requireUser } from "@/lib/auth";
import { apiError } from "@/lib/http";
import { prisma } from "@/lib/prisma";

export async function GET() {
  try {
    const account = await requireUser();
    const now = new Date();

    // 1. Fetch House settings
    const house = account.role === Role.ADMIN
      ? await prisma.house.findFirst({ orderBy: { createdAt: "asc" } })
      : account.member?.houseId
        ? await prisma.house.findUnique({ where: { id: account.member.houseId } })
        : null;
    if (!house) {
      return NextResponse.json({
        configured: false,
        account: {
          id: account.id,
          email: account.email,
          name: account.member?.name ?? account.email,
          role: account.role,
          memberId: account.member?.id,
        },
      });
    }

    // 2. Fetch the latest Month billing cycle (matching Admin logic)
    const month = await prisma.month.findFirst({
      where: {
        houseId: house.id,
      },
      orderBy: { startsOn: "desc" },
      include: {
        rentPayments: {
          include: {
            member: true,
            transactions: {
              include: {
                payer: true,
              },
              orderBy: {
                paidAt: "desc",
              },
            },
          },
          orderBy: {
            member: { name: "asc" },
          },
        },
        utilities: {
          include: { paidBy: true, payments: { include: { member: true } } },
          orderBy: { createdAt: "desc" },
        },
        expenses: {
          include: { paidBy: true, splits: { include: { member: true } } },
          orderBy: { createdAt: "desc" },
        },
      },
    });

    // 3. Fetch all active members in the house
    const members = await prisma.member.findMany({
      where: { active: true, houseId: house.id },
      orderBy: { name: "asc" },
    });

    // 4. Fetch Settlements (Debts)
    let debts: any[] = [];
    if (account.role === Role.ADMIN) {
      debts = await prisma.debt.findMany({
        where: { status: "OPEN", debtor: { houseId: house.id }, creditor: { houseId: house.id } },
        include: { debtor: true, creditor: true },
        orderBy: { createdAt: "desc" },
      });
    } else if (account.member?.id) {
      debts = await prisma.debt.findMany({
        where: {
          status: "OPEN",
          debtor: { houseId: house.id },
          creditor: { houseId: house.id },
          OR: [
            { debtorId: account.member.id },
            { creditorId: account.member.id },
          ],
        },
        include: { debtor: true, creditor: true },
        orderBy: { createdAt: "desc" },
      });
    }

    // 5. Fetch Pending Confirmations (Admin only)
    let pendingConfirmations: any[] = [];
    if (account.role === Role.ADMIN) {
      pendingConfirmations = await prisma.rentPaymentTransaction.findMany({
        where: { status: "SUBMITTED", rentPayment: { month: { houseId: house.id } } },
        include: {
          payer: true,
          rentPayment: {
            include: { member: true },
          },
        },
        orderBy: { paidAt: "desc" },
      });
    }

    // 6. Fetch Recent Activity Feed (all rent transactions in the house)
    const recentActivity = await prisma.rentPaymentTransaction.findMany({
      where: {
        rentPayment: {
          month: {
            houseId: house.id,
          },
        },
      },
      include: {
        payer: true,
        rentPayment: {
          include: { member: true },
        },
      },
      orderBy: { paidAt: "desc" },
      take: 10,
    });

    return NextResponse.json({
      configured: true,
      house,
      account: {
        id: account.id,
        email: account.email,
        name: account.member?.name ?? account.email,
        role: account.role,
        memberId: account.member?.id,
      },
      month: month ? {
        ...month,
        debts,
      } : null,
      members,
      pendingConfirmations,
      recentActivity,
    });
  } catch (error) {
    return apiError(error);
  }
}
