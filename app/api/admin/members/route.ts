// app/api/admin/members/route.ts
import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { createSupabaseServerClient } from "@/lib/supabase";

export async function GET(request: Request) {
  const url = new URL(request.url);
  const pending = url.searchParams.get("pending") === "true";

  const supabase = await createSupabaseServerClient();
  const { data: { user } } = await supabase.auth.getUser();
  const adminEmail = process.env.ADMIN_EMAIL?.toLowerCase();

  // Only admin can access this endpoint
  if (!user?.email?.toLowerCase() || user.email.toLowerCase() !== adminEmail) {
    return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  }

  if (pending) {
    // Return e‑mails that have auth entries but no member row
    const pendingEmails = await prisma.$queryRaw<Array<{ email: string }>`
      SELECT DISTINCT u.email
      FROM "User" u
      LEFT JOIN "Member" m ON u.email = m.email
      WHERE m.id IS NULL
    `;
    return NextResponse.json({ emails: pendingEmails.map((e) => e.email) });
  }

  // Return all approved members with basic info
  const members = await prisma.member.findMany({
    select: { id: true, email: true, name: true, role: true, createdAt: true },
  });
  return NextResponse.json({ members });
}

// Optional: Update member (e.g., role or name) – PATCH /api/admin/members/:id
export async function PATCH(request: Request) {
  const supabase = await createSupabaseServerClient();
  const { data: { user } } = await supabase.auth.getUser();
  const adminEmail = process.env.ADMIN_EMAIL?.toLowerCase();
  if (!user?.email?.toLowerCase() || user.email.toLowerCase() !== adminEmail) {
    return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  }

  const { id, name, role } = await request.json();
  if (!id) {
    return NextResponse.json({ error: "Missing member id" }, { status: 400 });
  }

  const updated = await prisma.member.update({
    where: { id },
    data: { name, role },
    select: { id: true, email: true, name: true, role: true, createdAt: true },
  });
  return NextResponse.json({ member: updated });
}
