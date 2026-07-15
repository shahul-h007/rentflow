import { NextResponse } from "next/server";
import { PaymentStatus } from "@prisma/client";
import { z } from "zod";
import { requireUser } from "@/lib/auth";
import { apiError } from "@/lib/http";
import { prisma } from "@/lib/prisma";
const updateSchema=z.object({amountPaid:z.number().int().min(0),method:z.string().trim().min(2).max(40).optional(),reference:z.string().trim().max(100).optional(),status:z.nativeEnum(PaymentStatus).optional()});
export async function PATCH(request:Request,{params}:{params:Promise<{id:string}>}){try{const user=await requireUser();const {id}=await params;const current=await prisma.rentPayment.findUnique({where:{id}});if(!current) return NextResponse.json({error:"Payment not found"},{status:404});if(user.role!=="ADMIN"&&user.member?.id!==current.memberId)return NextResponse.json({error:"You may only update your own payment"},{status:403});const payload=updateSchema.parse(await request.json());const amountDue=current.amountDue;const status=payload.status??(payload.amountPaid>=amountDue?PaymentStatus.PAID:payload.amountPaid>0?PaymentStatus.PARTIAL:PaymentStatus.PENDING);const payment=await prisma.rentPayment.update({where:{id},data:{...payload,status,paidAt:payload.amountPaid>0?new Date():null}});await prisma.activityLog.create({data:{actorId:user.id,entity:"rent_payment",entityId:id,action:"updated",oldValue:{amountPaid:current.amountPaid,status:current.status},newValue:{amountPaid:payment.amountPaid,status:payment.status}}});return NextResponse.json({payment})}catch(error){return apiError(error)}}
