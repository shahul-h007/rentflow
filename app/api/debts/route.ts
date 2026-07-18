import { NextResponse } from "next/server";
import { z } from "zod";
import { requireAdmin, requireUser } from "@/lib/auth";
import { apiError } from "@/lib/http";
import { prisma } from "@/lib/prisma";
const schema=z.object({debtorId:z.string().uuid(),creditorId:z.string().uuid(),amount:z.number().int().positive(),reason:z.string().trim().min(2).max(200)});
export async function GET(){try{await requireUser();const debts=await prisma.debt.findMany({include:{debtor:true,creditor:true},orderBy:{createdAt:"desc"}});return NextResponse.json({debts})}catch(error){return apiError(error)}}
export async function POST(request:Request){try{await requireUser();const data=schema.parse(await request.json());if(data.debtorId===data.creditorId)return NextResponse.json({error:"Debtor and creditor must be different members"},{status:400});const debt=await prisma.debt.create({data});return NextResponse.json({debt},{status:201})}catch(error){return apiError(error)}}
