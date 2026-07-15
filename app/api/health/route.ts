import { NextResponse } from "next/server";
export function GET(){return NextResponse.json({service:"rentflow",status:"ok",at:new Date().toISOString()})}
