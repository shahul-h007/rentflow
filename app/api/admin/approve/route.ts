import { NextResponse } from "next/server";
import { z } from "zod";
import { requireAdminHouseAccess } from "@/lib/auth";
import { apiError } from "@/lib/http";
import { prisma } from "@/lib/prisma";

const schema = z.object({
  email: z.string().email().transform((email) => email.toLowerCase()),
  name: z.string().trim().min(2).max(80).optional(),
});

export async function POST(request: Request) {
  try {
    const { house } = await requireAdminHouseAccess();
    const { email, name } = schema.parse(await request.json());
    const member = await prisma.member.upsert({
      where: { email },
      create: { email, name: name ?? email.split("@")[0], houseId: house.id },
      update: { active: true, houseId: house.id, ...(name ? { name } : {}) },
    });
    return NextResponse.json({ member });
  } catch (error) {
    return apiError(error);
  }
}
