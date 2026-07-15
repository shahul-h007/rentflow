import { createServerClient, type CookieOptions } from "@supabase/ssr";
import { cookies } from "next/headers";
export async function createSupabaseServerClient(){const jar=await cookies();return createServerClient(process.env.NEXT_PUBLIC_SUPABASE_URL!,process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!,{cookies:{getAll:()=>jar.getAll(),setAll(values:Array<{name:string;value:string;options:CookieOptions}>){try{values.forEach(({name,value,options})=>jar.set(name,value,options))}catch{}}}})}
