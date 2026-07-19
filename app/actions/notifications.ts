"use server";

import prisma from "@/lib/prisma";
import { revalidatePath } from "next/cache";

export async function getNotifications() {
  return prisma.notification.findMany({
    orderBy: { createdAt: "desc" },
    take: 50,
  });
}

export async function markNotificationAsRead(id: string) {
  await prisma.notification.update({
    where: { id },
    data: { isRead: true }
  });
  revalidatePath("/admin/notifications");
}

export async function createSystemNotification(title: string, message: string, type: string) {
  await prisma.notification.create({
    data: {
      title,
      message,
      type
    }
  });
  revalidatePath("/admin/notifications");
}
