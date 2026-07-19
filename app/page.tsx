import { redirect } from "next/navigation";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export default async function Home() {
  const { data: { user } } = await (await createSupabaseServerClient()).auth.getUser();
  if (!user) {
    redirect("/login");
  }
  redirect("/admin");
}
