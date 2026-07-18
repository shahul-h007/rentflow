// app/api/admin/approve/route.ts
import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { createSupabaseServerClient } from "@/lib/supabase";

export async function POST(request: Request) {
  const supabase = await createSupabaseServerClient();
  const { data: { user } } = await supabase.auth.getUser();
  const adminEmail = process.env.ADMIN_EMAIL?.toLowerCase();

  if (!user?.email?.toLowerCase() || user.email.toLowerCase() !== adminEmail) {
    return NextResponse.json({ error: "Only admin can approve members" }, { status: 403 });
  }

  const { email } = await request.json();
  if (!email) {
    return NextResponse.json({ error: "Missing email" }, { status: 400 });
  }

  // Upsert member record (idempotent)
  await prisma.member.upsert({
    where: { email: email.toLowerCase() },
    create: { email: email.toLowerCase() },
    update: {},
  });

  return NextResponse.json({ message: `${email} approved` });
}
