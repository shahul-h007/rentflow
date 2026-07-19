"use client";
import { useState } from "react";
import { ArrowRight, LoaderCircle, LockKeyhole, Building2 } from "lucide-react";
import { useRouter } from "next/navigation";
import { createSupabaseBrowserClient } from "@/lib/supabase/client";

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  
  const supabase = createSupabaseBrowserClient();

  async function submit(event: React.FormEvent) {
    event.preventDefault();
    setError("");
    setLoading(true);
    
    try {
      const { error: signInError } = await supabase.auth.signInWithPassword({ email, password });
      if (signInError) throw signInError;
      
      const response = await fetch("/api/auth/session", { method: "POST" });
      const data = await response.json() as { error?: string };
      
      if (!response.ok) {
        await supabase.auth.signOut();
        throw new Error(data.error ?? "Unable to verify this account");
      }
      
      router.replace("/admin");
      router.refresh();
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : "Unable to sign in");
    } finally {
      setLoading(false);
    }
  }
  
  return (
    <main className="grid min-h-screen place-items-center bg-background p-5">
      <section className="w-full max-w-md rounded-2xl border border-border bg-card p-8 shadow-soft">
        <div className="grid h-12 w-12 place-items-center rounded-xl bg-primary text-primary-foreground shadow-sm">
          <Building2 size={24} />
        </div>
        <p className="mt-8 text-xs font-bold uppercase tracking-widest text-primary">RentFlow</p>
        <h1 className="mt-2 text-3xl font-bold tracking-tight text-foreground">Welcome back</h1>
        <p className="mt-2 text-sm text-muted-foreground">Sign in to your RentFlow Admin Portal.</p>
        
        <form onSubmit={submit} className="mt-8 space-y-5">
          <div>
            <label className="block text-sm font-semibold text-foreground mb-1.5">Email address</label>
            <input 
              required 
              type="email" 
              value={email} 
              onChange={e => setEmail(e.target.value)} 
              placeholder="admin@rentflow.com" 
              autoComplete="email" 
              className="w-full rounded-xl border border-input bg-background px-4 py-3 outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition"
            />
          </div>
          
          <div>
            <label className="block text-sm font-semibold text-foreground mb-1.5">Password</label>
            <div className="relative">
              <LockKeyhole className="absolute left-4 top-3.5 text-muted-foreground" size={18}/>
              <input 
                required 
                type="password" 
                minLength={6} 
                value={password} 
                onChange={e => setPassword(e.target.value)} 
                autoComplete="current-password" 
                className="w-full rounded-xl border border-input bg-background py-3 pl-11 pr-4 outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition"
              />
            </div>
          </div>
          
          {error && (
            <div className="rounded-xl bg-destructive/10 px-4 py-3 text-sm font-medium text-destructive">
              {error}
            </div>
          )}
          
          <button 
            disabled={loading} 
            className="flex w-full items-center justify-center gap-2 rounded-xl bg-primary px-4 py-3.5 font-semibold text-primary-foreground shadow-sm disabled:opacity-70 transition hover:bg-primary/90 active:scale-95"
          >
            {loading ? <LoaderCircle className="animate-spin" size={18}/> : <>Sign In <ArrowRight size={18}/></>}
          </button>
        </form>
      </section>
    </main>
  );
}
