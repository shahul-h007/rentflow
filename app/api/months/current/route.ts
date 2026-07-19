import { NextResponse } from "next/server";
import { requireHouseAccess } from "@/lib/auth";
import { apiError } from "@/lib/http";
import { prisma } from "@/lib/prisma";
export async function GET(){try{const {house}=await requireHouseAccess();const now=new Date();const month=await prisma.month.findFirst({where:{startsOn:{lte:now},endsOn:{gte:now},houseId:house.id},include:{rentPayments:{include:{member:true},orderBy:{member:{name:"asc"}}},utilities:true,expenses:true}});return NextResponse.json({month})}catch(error){return apiError(error)}}
