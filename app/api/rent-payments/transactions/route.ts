import { NextResponse } from "next/server";
import { requireHouseAccess } from "@/lib/auth";
import { apiError } from "@/lib/http";
import { prisma } from "@/lib/prisma";
import { z } from "zod";

const transactionSchema = z.object({
  rentPaymentId: z.string().uuid("Invalid Rent Payment ID"),
  amount: z.number().int().min(1, "Amount must be greater than zero"),
  method: z.string().trim().min(1, "Payment method is required"),
  reference: z.string().trim().optional(),
  screenshotUrl: z.string().trim().optional(),
  payerId: z.string().uuid("Invalid Payer Member ID").optional(),
});

export async function POST(request: Request) {
  try {
    const { user, house } = await requireHouseAccess();
    const body = await request.json();
    const payload = transactionSchema.parse(body);

    // Verify the rent payment record exists
    const rentPayment = await prisma.rentPayment.findFirst({
      where: { id: payload.rentPaymentId, month: { houseId: house.id } },
      include: { member: true },
    });

    if (!rentPayment) {
      return NextResponse.json({ error: "Rent payment record not found" }, { status: 404 });
    }

    // Set the default payer to the current user's member profile if not specified
    const currentMemberId = user.member?.id;
    if (!currentMemberId && user.role !== "ADMIN") {
      return NextResponse.json({ error: "Your user account is not linked to a member profile" }, { status: 403 });
    }

    const payerId = payload.payerId ?? currentMemberId;
    if (!payerId) {
      return NextResponse.json({ error: "Payer must be specified" }, { status: 400 });
    }

    const payer = await prisma.member.findFirst({ where: { id: payerId, active: true, houseId: house.id } });
    if (!payer) return NextResponse.json({ error: "Payer must be an active member of this house" }, { status: 400 });

    // Standard members can only submit payments where they are either the tenant or the payer
    if (user.role !== "ADMIN" && rentPayment.memberId !== currentMemberId && payerId !== currentMemberId) {
      return NextResponse.json({ error: "You do not have permission to submit this transaction" }, { status: 403 });
    }

    if (payload.amount > rentPayment.amountDue - rentPayment.amountPaid) {
      return NextResponse.json({ error: "Payment amount exceeds the outstanding balance" }, { status: 400 });
    }

    // Check if there's already a SUBMITTED transaction
    const existingTransaction = await prisma.rentPaymentTransaction.findFirst({
      where: {
        rentPaymentId: payload.rentPaymentId,
        status: "SUBMITTED",
      }
    });

    if (existingTransaction) {
      return NextResponse.json({ error: "A payment request is already pending verification. Please wait for admin approval." }, { status: 400 });
    }

    // Create the transaction record with SUBMITTED status
    const transaction = await prisma.rentPaymentTransaction.create({
      data: {
        rentPaymentId: payload.rentPaymentId,
        amount: payload.amount,
        method: payload.method,
        reference: payload.reference || null,
        screenshotUrl: payload.screenshotUrl || null,
        status: "SUBMITTED",
        payerId: payerId,
      },
    });

    // Log the activity
    await prisma.activityLog.create({
      data: {
        actorId: user.id,
        entity: "rent_payment_transaction",
        entityId: transaction.id,
        action: "submitted",
        newValue: transaction,
      },
    });

    return NextResponse.json({ success: true, transaction });
  } catch (error) {
    return apiError(error);
  }
}
