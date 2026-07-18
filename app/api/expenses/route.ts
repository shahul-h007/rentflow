import { NextResponse } from "next/server";
import { SplitType } from "@prisma/client";
import { z } from "zod";
import { requireAdmin, requireUser } from "@/lib/auth";
import { apiError } from "@/lib/http";
import { prisma } from "@/lib/prisma";
const schema=z.object({monthId:z.string().uuid(),title:z.string().trim().min(2).max(100),amount:z.number().int().positive(),paidById:z.string().uuid(),notes:z.string().trim().max(500).optional(),splitType:z.nativeEnum(SplitType).default(SplitType.EQUAL)});
export async function GET(){try{await requireUser();const expenses=await prisma.expense.findMany({include:{paidBy:true,splits:{include:{member:true}}},orderBy:{createdAt:"desc"}});return NextResponse.json({expenses})}catch(error){return apiError(error)}}
export async function POST(request:Request){try{await requireUser();const input=schema.parse(await request.json());const members=await prisma.member.findMany({where:{active:true}});const expense=await prisma.$transaction(async tx=>{const item=await tx.expense.create({data:input});const base=Math.floor(input.amount/members.length),remainder=input.amount%members.length;await tx.expenseSplit.createMany({data:members.map((member,index)=>({expenseId:item.id,memberId:member.id,amount:base+(index<remainder?1:0)}))});return item});return NextResponse.json({expense},{status:201})}catch(error){return apiError(error)}}
