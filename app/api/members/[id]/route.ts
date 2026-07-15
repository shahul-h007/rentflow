import { NextResponse } from "next/server";
import { z } from "zod";
import { requireAdmin } from "@/lib/auth";
import { apiError } from "@/lib/http";
import { prisma } from "@/lib/prisma";
const schema=z.object({name:z.string().trim().min(2).max(80).optional(),email:z.string().email().optional(),phone:z.string().trim().max(24).optional(),active:z.boolean().optional()});
export async function PATCH(request:Request,{params}:{params:Promise<{id:string}>}){try{await requireAdmin();const {id}=await params;const member=await prisma.member.update({where:{id},data:schema.parse(await request.json())});return NextResponse.json({member})}catch(error){return apiError(error)}}
