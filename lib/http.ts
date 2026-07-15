import { NextResponse } from "next/server";
import { ZodError } from "zod";
export function apiError(error:unknown){if(error instanceof ZodError)return NextResponse.json({error:"Invalid request",issues:error.flatten()},{status:400});const message=error instanceof Error?error.message:"Unexpected server error";const status=message==="Unauthorized"?401:message.includes("access")?403:message.includes("configured")?503:500;return NextResponse.json({error:message},{status})}
