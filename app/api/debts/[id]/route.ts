import { NextResponse } from "next/server";
import { requireUser } from "@/lib/auth";
import { apiError } from "@/lib/http";
import { prisma } from "@/lib/prisma";
import { DebtStatus } from "@prisma/client";

export async function PATCH(request: Request, { params }: { params: Promise<{ id: string }> }) {
  try {
    const user = await requireUser();
    const { id } = await params;

    // Fetch the debt
    const debt = await prisma.debt.findUnique({
      where: { id },
      include: {
        debtor: true,
        creditor: true,
      },
    });

    if (!debt) {
      return NextResponse.json({ error: "Settlement record not found" }, { status: 404 });
    }

    // Verify permissions: only debtor, creditor, or admin can update
    const currentMemberId = user.member?.id;
    const isDebtor = currentMemberId === debt.debtorId;
    const isCreditor = currentMemberId === debt.creditorId;
    const isAdmin = user.role === "ADMIN";

    if (!isDebtor && !isCreditor && !isAdmin) {
      return NextResponse.json({ error: "You do not have permission to update this settlement" }, { status: 403 });
    }

    const body = await request.json();
    const status = body.status as DebtStatus;

    if (status !== DebtStatus.SETTLED && status !== DebtStatus.CANCELLED && status !== DebtStatus.OPEN) {
      return NextResponse.json({ error: "Invalid status value" }, { status: 400 });
    }

    const updatedDebt = await prisma.debt.update({
      where: { id },
      data: {
        status,
        settledAmount: status === DebtStatus.SETTLED ? debt.amount : 0,
        settledAt: status === DebtStatus.SETTLED ? new Date() : null,
      },
    });

    // Log the activity
    await prisma.activityLog.create({
      data: {
        actorId: user.id,
        entity: "debt",
        entityId: id,
        action: status.toLowerCase(),
        newValue: updatedDebt,
      },
    });

    return NextResponse.json({ success: true, debt: updatedDebt });
  } catch (error) {
    return apiError(error);
  }
}
