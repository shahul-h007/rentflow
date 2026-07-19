import { NextResponse } from "next/server";
import { z } from "zod";
import { requireAdminHouseAccess, requireHouseAccess } from "@/lib/auth";
import { apiError } from "@/lib/http";
import { prisma } from "@/lib/prisma";
const schema=z.object({debtorId:z.string().uuid(),creditorId:z.string().uuid(),amount:z.number().int().positive(),reason:z.string().trim().min(2).max(200)});
export async function GET(){try{const {user,house}=await requireHouseAccess();const base={status:"OPEN" as const,debtor:{houseId:house.id},creditor:{houseId:house.id}};const debts=await prisma.debt.findMany({where:user.role==="ADMIN"?base:{...base,OR:[{debtorId:user.member?.id},{creditorId:user.member?.id}]},include:{debtor:true,creditor:true},orderBy:{createdAt:"desc"}});return NextResponse.json({debts})}catch(error){return apiError(error)}}
export async function POST(request:Request){try{const {house}=await requireAdminHouseAccess();const data=schema.parse(await request.json());if(data.debtorId===data.creditorId)return NextResponse.json({error:"Debtor and creditor must be different members"},{status:400});const members=await prisma.member.count({where:{id:{in:[data.debtorId,data.creditorId]},houseId:house.id}});if(members!==2)throw new Error("Debt members must belong to this house");const debt=await prisma.debt.create({data});return NextResponse.json({debt},{status:201})}catch(error){return apiError(error)}}
