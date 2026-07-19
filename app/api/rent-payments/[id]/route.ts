import { NextResponse } from "next/server";
import { z } from "zod";
import { requireAdminHouseAccess } from "@/lib/auth";
import { apiError } from "@/lib/http";
import { prisma } from "@/lib/prisma";
const updateSchema=z.object({method:z.string().trim().min(2).max(40).optional(),reference:z.string().trim().max(100).optional()});
export async function PATCH(request:Request,{params}:{params:Promise<{id:string}>}){try{const {user,house}=await requireAdminHouseAccess();const {id}=await params;const current=await prisma.rentPayment.findFirst({where:{id,month:{houseId:house.id}}});if(!current) return NextResponse.json({error:"Payment not found"},{status:404});const payload=updateSchema.parse(await request.json());const payment=await prisma.rentPayment.update({where:{id},data:payload});await prisma.activityLog.create({data:{actorId:user.id,entity:"rent_payment",entityId:id,action:"details_updated",oldValue:{method:current.method,reference:current.reference},newValue:{method:payment.method,reference:payment.reference}}});return NextResponse.json({payment})}catch(error){return apiError(error)}}
