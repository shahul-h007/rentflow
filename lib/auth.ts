import { Role } from "@prisma/client";
import { prisma } from "./prisma";
import { createSupabaseServerClient } from "./supabase/server";
export async function requireUser(){if(!process.env.NEXT_PUBLIC_SUPABASE_URL||!process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY)throw new Error("Authentication is not configured");const {data:{user}}=await (await createSupabaseServerClient()).auth.getUser();if(!user)throw new Error("Unauthorized");const account=await prisma.user.findUnique({where:{authId:user.id},include:{member:true}});if(!account)throw new Error("Your account has not been approved by the house administrator");return account}
export async function requireAdmin(){const user=await requireUser();if(user.role!==Role.ADMIN)throw new Error("Administrator access required");return user}
