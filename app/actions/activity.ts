"use server";

import prisma from "@/lib/prisma";

export async function getActivityLogs() {
  return prisma.activityLog.findMany({
    orderBy: { createdAt: "desc" },
    take: 100, // fetch recent 100 activities
  });
}
