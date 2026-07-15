import { redirect } from "next/navigation";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { Dashboard } from "@/components/dashboard";
export default async function Home(){const {data:{user}}=await (await createSupabaseServerClient()).auth.getUser();if(!user)redirect("/login");return <Dashboard/>}
