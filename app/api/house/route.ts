import { NextResponse } from "next/server";
import { requireAdmin, requireUser } from "@/lib/auth";
import { apiError } from "@/lib/http";
import { prisma } from "@/lib/prisma";
import { z } from "zod";

const houseSchema = z.object({
  name: z.string().trim().min(1, "House name is required"),
  rent: z.number().int().min(1, "Rent must be a positive number"),
  dueDate: z.number().int().min(1).max(31, "Due date must be between 1 and 31"),
  currency: z.string().default("INR"),
  upiId: z.string().trim().min(1, "UPI ID is required"),
  ownerName: z.string().trim().min(1, "Owner name is required"),
});

export async function GET() {
  try {
    const user = await requireUser();
    const house = user.role === "ADMIN"
      ? await prisma.house.findFirst({
        orderBy: { createdAt: "asc" },
        include: { members: true, months: true },
      })
      : user.member?.houseId
        ? await prisma.house.findUnique({
          where: { id: user.member.houseId },
          include: { members: true, months: true },
        })
        : null;

    if (!house) {
      return NextResponse.json({ configured: false });
    }

    return NextResponse.json({ configured: true, house });
  } catch (error) {
    return apiError(error);
  }
}

export async function POST(request: Request) {
  try {
    const user = await requireAdmin();
    
    // Validate request body
    const body = await request.json();
    const payload = houseSchema.parse(body);

    // Create the House record
    const existingHouse = await prisma.house.findFirst({ orderBy: { createdAt: "asc" } });
    const houseData = {
        name: payload.name,
        rent: payload.rent,
        dueDate: payload.dueDate,
        currency: payload.currency,
        upiId: payload.upiId,
        ownerName: payload.ownerName,
      };
    const house = existingHouse
      ? await prisma.house.update({ where: { id: existingHouse.id }, data: houseData })
      : await prisma.house.create({ data: houseData });

    // Link all existing members to this house
    await prisma.member.updateMany({
      where: { houseId: null },
      data: { houseId: house.id },
    });

    // Setup the current active month billing cycle
    const now = new Date();
    const startsOn = new Date(now.getFullYear(), now.getMonth(), 1);
    const endsOn = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59);

    // Check if the current month is already created
    let month = await prisma.month.findFirst({
      where: {
        startsOn,
        houseId: house.id,
      },
    });

    if (!month) {
      const newMonth = await prisma.month.create({
        data: {
          startsOn,
          endsOn,
          rent: payload.rent,
          houseId: house.id,
        },
      });
      month = newMonth;

      // Automatically create RentPayment records for all active members
      const activeMembers = await prisma.member.findMany({
        where: { active: true, houseId: house.id },
      });

      if (activeMembers.length > 0) {
        const share = Math.floor(payload.rent / activeMembers.length);
        const remainder = payload.rent % activeMembers.length;

        await Promise.all(
          activeMembers.map((member, index) => {
            const memberDue = share + (index < remainder ? 1 : 0);
            return prisma.rentPayment.create({
              data: {
                monthId: newMonth.id,
                memberId: member.id,
                amountDue: memberDue,
                amountPaid: 0,
                status: "PENDING",
              },
            });
          })
        );
      }
    } else {
      // If month already exists, update its rent and houseId
      await prisma.month.update({
        where: { id: month.id },
        data: {
          rent: payload.rent,
          houseId: house.id,
        },
      });
    }

    // Log action
    await prisma.activityLog.create({
      data: {
        actorId: user.id,
        entity: "house",
        entityId: house.id,
        action: "created",
        newValue: house,
      },
    });

    return NextResponse.json({ success: true, house });
  } catch (error) {
    return apiError(error);
  }
}
