import { NextResponse, type NextRequest } from "next/server";
import { updateSession } from "@/utils/supabase/middleware";

export async function middleware(request: NextRequest) {
  const { response, user } = await updateSession(request);
  if (!request.nextUrl.pathname.startsWith("/admin")) return response;

  const adminEmail = process.env.ADMIN_EMAIL?.toLowerCase();
  if (!adminEmail) return new NextResponse("Admin email not configured", { status: 500 });
  if (user?.email?.toLowerCase() !== adminEmail) {
    return new NextResponse("Forbidden: admin only", { status: 403 });
  }
  return response;
}

export const config = {
  matcher: "/((?!_next/static|_next/image|favicon.ico|icon.svg|sw.js|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
};
