"use server";

import prisma from "@/lib/prisma";
import { revalidatePath } from "next/cache";

export async function addMember(data: { name: string; email?: string; phone?: string; role: "ADMIN" | "MEMBER" }) {
  const house = await prisma.house.findFirst();
  if (!house) return { success: false, error: "No house configured" };

  if (!data.email) {
    return { success: false, error: "An email is required to provision a member login." };
  }

  // 1. Generate a random 8-character password
  const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*";
  let generatedPassword = "";
  for (let i = 0; i < 8; i++) {
    generatedPassword += chars.charAt(Math.floor(Math.random() * chars.length));
  }

  // 2. Import Admin client dynamically to avoid exposing it globally
  const { supabaseAdmin } = await import("@/lib/supabase-admin");

  // 3. Create the user in Supabase Auth
  const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
    email: data.email,
    password: generatedPassword,
    email_confirm: true, // Auto-confirm their email
  });

  if (authError || !authData.user) {
    console.error("Supabase Auth Error:", authError);
    return { success: false, error: authError?.message || "Failed to provision authentication account." };
  }

  // 4. Create the User in Prisma (mapping to authId)
  const user = await prisma.user.create({
    data: {
      authId: authData.user.id,
      email: data.email,
      role: data.role,
    }
  });

  // 5. Create the Member in Prisma (linked to User and House)
  await prisma.member.create({
    data: {
      userId: user.id,
      name: data.name,
      email: data.email,
      phone: data.phone || null,
      houseId: house.id,
      active: true,
      appPassword: generatedPassword,
    }
  });

  await prisma.activityLog.create({
    data: {
      entity: "Member",
      entityId: user.id,
      action: `Provisioned new member account: ${data.name}`,
    }
  });

  const { recalculateOpenMonths } = await import("./rent");
  await recalculateOpenMonths(house.id);

  revalidatePath("/admin/members");
  
  // Return the password so the frontend can display it
  return { success: true, password: generatedPassword };
}

export async function updateMember(id: string, data: { name: string; email?: string; phone?: string }): Promise<{success: boolean, error?: string}> {
  const old = await prisma.member.findUnique({ where: { id } });
  
  await prisma.member.update({
    where: { id },
    data: {
      name: data.name,
      email: data.email || null,
      phone: data.phone || null,
    }
  });

  await prisma.activityLog.create({
    data: {
      entity: "Member",
      entityId: id,
      action: `Updated details for member: ${old?.name || data.name}`,
    }
  });

  revalidatePath("/admin/members");
  return { success: true };
}

export async function toggleMemberStatus(id: string, currentlyActive: boolean): Promise<{success: boolean, error?: string}> {
  const member = await prisma.member.update({
    where: { id },
    data: { active: !currentlyActive }
  });

  await prisma.activityLog.create({
    data: {
      entity: "Member",
      entityId: id,
      action: `${member.active ? 'Reactivated' : 'Deactivated'} member: ${member.name}`,
    }
  });

  const { recalculateOpenMonths } = await import("./rent");
  if (member.houseId) {
    await recalculateOpenMonths(member.houseId);
  }

  revalidatePath("/admin/members");
  return { success: true };
}

export async function deleteMember(id: string) {
  const member = await prisma.member.findUnique({ where: { id }, include: { user: true } });
  if (!member) return { success: false, error: "Member not found" };

  try {
    // 1. Delete Member from Prisma
    await prisma.member.delete({ where: { id } });

    // 2. Delete User from Prisma and Auth if they exist
    if (member.userId && member.user) {
      await prisma.user.delete({ where: { id: member.userId } });
      
      const { supabaseAdmin } = await import("@/lib/supabase-admin");
      await supabaseAdmin.auth.admin.deleteUser(member.user.authId);
    }

    await prisma.activityLog.create({
      data: {
        entity: "Member",
        entityId: id,
        action: `Deleted member: ${member.name}`,
      }
    });

    revalidatePath("/admin/members");
    return { success: true };
  } catch (error: any) {
    console.error(error);
    return { success: false, error: "Cannot delete this member because they are linked to existing rent payments or debts. Please deactivate them instead." };
  }
}

export async function resetMemberPassword(id: string) {
  const member = await prisma.member.findUnique({ where: { id }, include: { user: true } });
  if (!member) return { success: false, error: "Member not found" };

  if (!member.email) {
    return { success: false, error: "This member has no email address. Please click the 'Edit' button to add their email first." };
  }

  // 1. Generate new 8 character password
  const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*";
  let generatedPassword = "";
  for (let i = 0; i < 8; i++) {
    generatedPassword += chars.charAt(Math.floor(Math.random() * chars.length));
  }

  const { supabaseAdmin } = await import("@/lib/supabase-admin");

  // 2. If they already have an auth account, just update the password
  if (member.userId && member.user) {
    const { error: authError } = await supabaseAdmin.auth.admin.updateUserById(
      member.user.authId,
      { password: generatedPassword }
    );
    
    if (authError) {
      console.error("Supabase auth error:", authError);
      return { success: false, error: authError.message || "Failed to reset password in Supabase." };
    }
    
    // Just update the password in the database
    await prisma.member.update({
      where: { id: member.id },
      data: { appPassword: generatedPassword }
    });
  } else {
    // 3. They don't have an auth account yet (migrated member). Create it now!
    const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email: member.email,
      password: generatedPassword,
      email_confirm: true,
    });

    if (authError || !authData.user) {
      console.error("Supabase create user error:", authError);
      return { success: false, error: authError?.message || "Failed to provision authentication account." };
    }

    // Create the User in Prisma
    const user = await prisma.user.create({
      data: {
        authId: authData.user.id,
        email: member.email,
        role: "MEMBER",
      }
    });

    // Link it to the Member
    await prisma.member.update({
      where: { id: member.id },
      data: { userId: user.id, appPassword: generatedPassword }
    });
  }

  await prisma.activityLog.create({
    data: {
      entity: "Member",
      entityId: id,
      action: `Reset/Provisioned login credentials for: ${member.name}`,
    }
  });

  return { success: true, email: member.email, password: generatedPassword };
}
