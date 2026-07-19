import { NextResponse } from "next/server";
import { z } from "zod";
import { requireAdminHouseAccess } from "@/lib/auth";
import { apiError } from "@/lib/http";
import { prisma } from "@/lib/prisma";

const schema = z.object({ email: z.string().email().transform((email) => email.toLowerCase()) });

export async function POST(request: Request) {
  try {
    const { house } = await requireAdminHouseAccess();
    const { email } = schema.parse(await request.json());
    const member = await prisma.member.findFirst({ where: { email, houseId: house.id } });
    if (!member) return NextResponse.json({ error: "Member not found" }, { status: 404 });
    await prisma.member.update({ where: { id: member.id }, data: { active: false } });
    return NextResponse.json({ message: `${email} rejected` });
  } catch (error) {
    return apiError(error);
  }
}
