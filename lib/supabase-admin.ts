import { createClient } from "@supabase/supabase-js";

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || "";
const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY || "";

if (!supabaseUrl || !supabaseServiceRoleKey) {
  console.error("CRITICAL: Missing Supabase admin environment variables. Actions requiring auth admin will fail.");
}

// Fallback to empty strings to prevent crash during import, but calls will fail gracefully later.
export const supabaseAdmin = createClient(
  supabaseUrl || "https://placeholder.supabase.co", 
  supabaseServiceRoleKey || "placeholder_key", 
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  }
);
