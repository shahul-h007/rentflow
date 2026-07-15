import { NextResponse } from "next/server";
import { PaymentStatus, SplitType } from "@prisma/client";
import { z } from "zod";
import { requireAdmin, requireUser } from "@/lib/auth";
import { apiError } from "@/lib/http";
import { prisma } from "@/lib/prisma";
const schema=z.object({monthId:z.string().uuid(),name:z.string().trim().min(2).max(80),amount:z.number().int().positive(),paidById:z.string().uuid().optional(),dueDate:z.string().datetime().optional(),splitType:z.nativeEnum(SplitType).default(SplitType.EQUAL)});
export async function GET(){try{await requireUser();const utilities=await prisma.utility.findMany({include:{paidBy:true,payments:{include:{member:true}}},orderBy:{createdAt:"desc"}});return NextResponse.json({utilities})}catch(error){return apiError(error)}}
export async function POST(request:Request){try{await requireAdmin();const input=schema.parse(await request.json());const members=await prisma.member.findMany({where:{active:true}});const utility=await prisma.$transaction(async tx=>{const item=await tx.utility.create({data:{...input,dueDate:input.dueDate?new Date(input.dueDate):undefined}});const base=Math.floor(input.amount/members.length),remainder=input.amount%members.length;await tx.utilityPayment.createMany({data:members.map((member,index)=>({utilityId:item.id,memberId:member.id,amountDue:base+(index<remainder?1:0),status:PaymentStatus.PENDING}))});return item});return NextResponse.json({utility},{status:201})}catch(error){return apiError(error)}}
