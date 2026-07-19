import { Role } from "@prisma/client";
import { prisma } from "./prisma";
import { createSupabaseServerClient } from "./supabase/server";
import { headers, cookies } from "next/headers";
import { createClient } from "@supabase/supabase-js";

export async function requireUser(){
  await cookies(); // properly opt into dynamic rendering
  if(!process.env.NEXT_PUBLIC_SUPABASE_URL||!process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY)throw new Error("Authentication is not configured");
  
  let user = null;
  try {
    const {data:{user: cookieUser}}=await (await createSupabaseServerClient()).auth.getUser();
    user = cookieUser;
  } catch (e) {
    // Ignore cookie parse failures
  }
  
  if (!user) {
    try {
      const reqHeaders = await headers();
      const authHeader = reqHeaders.get("authorization");
      if (authHeader && authHeader.startsWith("Bearer ")) {
        const token = authHeader.substring(7);
        const supabase = createClient(
          process.env.NEXT_PUBLIC_SUPABASE_URL!,
          process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!
        );
        const { data: { user: tokenUser } } = await supabase.auth.getUser(token);
        user = tokenUser;
      }
    } catch (e) {
      // Ignore header/token retrieval errors
    }
  }

  if(!user)throw new Error("Unauthorized");
  const account=await prisma.user.findUnique({where:{authId:user.id},include:{member:true}});
  if(!account)throw new Error("Your account has not been approved by the house administrator");
  return account;
}

export async function requireAdmin(){const user=await requireUser();if(user.role!==Role.ADMIN)throw new Error("Administrator access required");return user}

export async function requireHouseAccess() {
  const user = await requireUser();
  const house = user.role === Role.ADMIN
    ? await prisma.house.findFirst({ orderBy: { createdAt: "asc" } })
    : user.member?.houseId
      ? await prisma.house.findUnique({ where: { id: user.member.houseId } })
      : null;

  if (!house) throw new Error("House access is not configured for this account");
  return { user, house };
}

export async function requireAdminHouseAccess() {
  const user = await requireAdmin();
  const house = await prisma.house.findFirst({ orderBy: { createdAt: "asc" } });
  if (!house) throw new Error("House access is not configured for this account");
  return { user, house };
}
