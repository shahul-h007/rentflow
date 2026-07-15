import { createServerClient, type CookieOptions } from "@supabase/ssr";
import type { cookies } from "next/headers";

const url=process.env.NEXT_PUBLIC_SUPABASE_URL!;
const key=process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!;
type CookieStore=Awaited<ReturnType<typeof cookies>>;
export function createClient(cookieStore:CookieStore){return createServerClient(url,key,{cookies:{getAll:()=>cookieStore.getAll(),setAll(values:Array<{name:string;value:string;options:CookieOptions}>){try{values.forEach(({name,value,options})=>cookieStore.set(name,value,options))}catch{}}}})}
