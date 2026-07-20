import React from "react";
import prisma from "@/lib/prisma";
import MembersClient from "./MembersClient";

export const dynamic = "force-dynamic";

export default async function MembersManagement() {
  let members: any[] = [];
  let errorMsg = null;

  try {
    const rawMembers = await prisma.member.findMany({
      orderBy: { joinedAt: "asc" }
    });

    // We MUST serialize Date objects before passing them to a Client Component
    members = rawMembers.map(m => ({
      ...m,
      joinedAt: m.joinedAt?.toISOString() || null,
      createdAt: m.createdAt?.toISOString() || null,
      updatedAt: m.updatedAt?.toISOString() || null,
    }));
  } catch (err: any) {
    errorMsg = err.message || String(err);
  }

  if (errorMsg) {
    return (
      <div className="p-8 text-red-500 font-bold">
        Error loading members: {errorMsg}
      </div>
    );
  }

  return <MembersClient members={members} />;
}
