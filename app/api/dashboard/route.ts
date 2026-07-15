import { Role } from "@prisma/client";
import { NextResponse } from "next/server";
import { requireUser } from "@/lib/auth";
import { apiError } from "@/lib/http";
import { prisma } from "@/lib/prisma";

export async function GET(){try{const account=await requireUser();const now=new Date();const membersQuery=account.role===Role.ADMIN?prisma.member.findMany({where:{active:true},orderBy:{name:"asc"}}):prisma.member.findMany({where:{active:true},orderBy:{name:"asc"},select:{id:true,name:true,phone:true,active:true}});const [month,members,debts]=await Promise.all([prisma.month.findFirst({where:{startsOn:{lte:now},endsOn:{gte:now}},include:{rentPayments:{include:{member:true},orderBy:{member:{name:"asc"}}},utilities:{include:{paidBy:true},orderBy:{dueDate:"asc"}},expenses:{include:{paidBy:true},orderBy:{createdAt:"desc"}}}}),membersQuery,prisma.debt.findMany({include:{debtor:true,creditor:true},orderBy:{createdAt:"desc"}})]);return NextResponse.json({account:{name:account.member?.name??account.email,role:account.role,memberId:account.member?.id},month:month?{...month,debts}:null,members})}catch(error){return apiError(error)}}
