// app/api/admin/reject/route.ts
import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { createSupabaseServerClient } from "@/lib/supabase";

export async function POST(request: Request) {
  const supabase = await createSupabaseServerClient();
  const { data: { user } } = await supabase.auth.getUser();
  const adminEmail = process.env.ADMIN_EMAIL?.toLowerCase();

  if (!user?.email?.toLowerCase() || user.email.toLowerCase() !== adminEmail) {
    return NextResponse.json({ error: "Only admin can reject members" }, { status: 403 });
  }

  const { email } = await request.json();
  if (!email) {
    return NextResponse.json({ error: "Missing email" }, { status: 400 });
  }

  // Delete the member record if it exists
  await prisma.member.deleteMany({ where: { email: email.toLowerCase() } });

  // Optionally sign out the user if they are already signed in
  // (Supabase auth will reject next login because no member exists)

  return NextResponse.json({ message: `${email} rejected` });
}
