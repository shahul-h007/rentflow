import { NextResponse } from "next/server";
import { SplitType } from "@prisma/client";
import { z } from "zod";
import { requireHouseAccess } from "@/lib/auth";
import { apiError } from "@/lib/http";
import { prisma } from "@/lib/prisma";
import { addExpense } from "@/app/actions/expenses";

const schema = z.object({
  monthId: z.string().uuid(),
  title: z.string().trim().min(2).max(100),
  amount: z.number().int().positive(),
  paidById: z.string().uuid(),
  notes: z.string().trim().max(500).optional(),
  splitType: z.nativeEnum(SplitType).default(SplitType.EQUAL)
});

export async function GET() {
  try {
    const { house } = await requireHouseAccess();
    const expenses = await prisma.expense.findMany({
      where: { month: { houseId: house.id } },
      include: { paidBy: true, splits: { include: { member: true } } },
      orderBy: { createdAt: "desc" }
    });
    return NextResponse.json({ expenses });
  } catch (error) {
    return apiError(error);
  }
}

export async function POST(request: Request) {
  try {
    const { user, house } = await requireHouseAccess();
    const input = schema.parse(await request.json());
    
    const [month, payer] = await Promise.all([
      prisma.month.findFirst({ where: { id: input.monthId, houseId: house.id } }),
      prisma.member.findFirst({ where: { id: input.paidById, active: true, houseId: house.id } })
    ]);
    
    if (!month || !payer) throw new Error("Expense must belong to this house");
    if (user.role !== "ADMIN" && user.member?.id !== payer.id) {
      throw new Error("You may only record expenses you paid");
    }
    
    const members = await prisma.member.findMany({ where: { active: true, houseId: house.id } });
    if (!members.length) throw new Error("House must have active members");
    
    const base = Math.floor(input.amount / members.length);
    const remainder = input.amount % members.length;
    
    const splits = members.map((member, index) => ({
      memberId: member.id,
      amount: base + (index < remainder ? 1 : 0)
    }));
    
    const expense = await addExpense({
      monthId: input.monthId,
      paidById: input.paidById,
      title: input.title,
      amount: input.amount,
      splitType: input.splitType,
      notes: input.notes,
      splits: splits
    });
    
    return NextResponse.json({ expense }, { status: 201 });
  } catch (error) {
    return apiError(error);
  }
}
