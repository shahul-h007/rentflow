import React from "react";
import prisma from "@/lib/prisma";
import MembersClient from "./MembersClient";

export const dynamic = "force-dynamic";

export default async function MembersManagement() {
  const members = await prisma.member.findMany({
    orderBy: { joinedAt: "asc" }
  });

  return <MembersClient members={members} />;
}
