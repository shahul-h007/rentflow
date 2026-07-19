import { NextResponse } from "next/server";
import { z } from "zod";
import { requireAdminHouseAccess } from "@/lib/auth";
import { apiError } from "@/lib/http";
import { prisma } from "@/lib/prisma";

const updateMemberSchema = z.object({
  id: z.string().uuid(),
  name: z.string().trim().min(2).max(80).optional(),
  active: z.boolean().optional(),
});

export async function GET(request: Request) {
  try {
    const { house } = await requireAdminHouseAccess();
    const pending = new URL(request.url).searchParams.get("pending") === "true";
    const members = await prisma.member.findMany({
      where: {
        houseId: house.id,
        email: { not: null },
        user: pending ? null : { isNot: null },
      },
      select: { id: true, email: true, name: true, active: true, joinedAt: true },
      orderBy: { name: "asc" },
    });
    return NextResponse.json(pending ? { emails: members.map((member) => member.email) } : { members });
  } catch (error) {
    return apiError(error);
  }
}

export async function PATCH(request: Request) {
  try {
    const { house } = await requireAdminHouseAccess();
    const { id, ...data } = updateMemberSchema.parse(await request.json());
    const member = await prisma.member.findFirst({ where: { id, houseId: house.id } });
    if (!member) return NextResponse.json({ error: "Member not found" }, { status: 404 });
    const updated = await prisma.member.update({
      where: { id },
      data,
      select: { id: true, email: true, name: true, active: true, joinedAt: true },
    });
    return NextResponse.json({ member: updated });
  } catch (error) {
    return apiError(error);
  }
}
