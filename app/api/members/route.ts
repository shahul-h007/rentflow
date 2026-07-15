import { NextResponse } from "next/server";
import { z } from "zod";
import { requireAdmin, requireUser } from "@/lib/auth";
import { apiError } from "@/lib/http";
import { prisma } from "@/lib/prisma";
const memberSchema=z.object({name:z.string().trim().min(2).max(80),phone:z.string().trim().max(24).optional(),photoUrl:z.string().url().optional()});
export async function GET(){try{await requireUser();const members=await prisma.member.findMany({where:{active:true},orderBy:{name:"asc"}});return NextResponse.json({members})}catch(error){return apiError(error)}}
export async function POST(request:Request){try{await requireAdmin();const payload=memberSchema.parse(await request.json());const member=await prisma.member.create({data:payload});return NextResponse.json({member},{status:201})}catch(error){return apiError(error)}}
