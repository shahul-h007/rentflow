"use server";

import prisma from "@/lib/prisma";
import { revalidatePath } from "next/cache";

export async function createHouse(data: {
  name: string;
  rent: number;
  dueDate: number;
  currency: string;
}) {
  const existing = await prisma.house.findFirst();
  if (existing) throw new Error("A house already exists.");

  const house = await prisma.house.create({
    data: {
      name: data.name,
      rent: data.rent,
      dueDate: data.dueDate,
      currency: data.currency,
      ownerName: "Owner Name", // Default placeholders
      upiId: "example@upi",
    }
  });

  await prisma.activityLog.create({
    data: {
      entity: "House",
      entityId: house.id,
      action: "Created new House",
    }
  });

  revalidatePath("/admin/house");
  return house;
}

export async function updateHouseDetails(data: {
  name: string;
  rent: number;
  dueDate: number;
  currency: string;
}) {
  const house = await prisma.house.findFirst();
  if (!house) throw new Error("No house configured");

  await prisma.house.update({
    where: { id: house.id },
    data: {
      name: data.name,
      rent: data.rent,
      dueDate: data.dueDate,
      currency: data.currency,
    }
  });

  await prisma.activityLog.create({
    data: {
      entity: "House",
      entityId: house.id,
      action: `Updated house settings (Name, Rent, Due Date)`,
    }
  });

  revalidatePath("/admin/house");
}

export async function updateHouseOwner(data: { ownerName: string; upiId: string }) {
  const house = await prisma.house.findFirst();
  if (!house) throw new Error("No house configured");

  await prisma.house.update({
    where: { id: house.id },
    data: {
      ownerName: data.ownerName,
      upiId: data.upiId,
    }
  });

  await prisma.activityLog.create({
    data: {
      entity: "House",
      entityId: house.id,
      action: `Transferred ownership or updated owner details`,
    }
  });

  revalidatePath("/admin/house");
}

export async function archiveHouse() {
  const house = await prisma.house.findFirst();
  if (!house) throw new Error("No house configured");

  // Soft delete representation - we could just set a setting, but for now we log it.
  // We won't actually delete the DB records as it breaks relationships.
  await prisma.activityLog.create({
    data: {
      entity: "House",
      entityId: house.id,
      action: `Archived house: ${house.name}`,
    }
  });

  revalidatePath("/admin/house");
}
