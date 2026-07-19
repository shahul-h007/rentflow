import React from "react";
import { getActivityLogs } from "@/app/actions/activity";
import { Activity, Clock } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function ActivityManagement() {
  const logs = await getActivityLogs();

  return (
    <div className="space-y-8 animate-in fade-in duration-500 max-w-5xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground flex items-center gap-2">
            <Activity className="text-primary" size={28} /> Activity Logs
          </h1>
          <p className="text-muted-foreground mt-1">Immutable audit trail of all administrative and financial actions.</p>
        </div>
      </div>

      <div className="bg-card border border-border rounded-2xl shadow-soft overflow-hidden">
        <div className="p-6 border-b border-border bg-muted/20">
          <h2 className="font-semibold text-foreground flex items-center gap-2">
            <Clock size={18} className="text-muted-foreground" /> Recent Activity
          </h2>
        </div>
        
        {logs.length === 0 ? (
          <div className="p-12 text-center text-muted-foreground">
            <p>No activity recorded yet.</p>
          </div>
        ) : (
          <div className="divide-y divide-border">
            {logs.map((log) => (
              <div key={log.id} className="p-5 hover:bg-muted/30 transition flex flex-col sm:flex-row sm:items-start gap-4">
                <div className="sm:w-48 flex-shrink-0 text-sm text-muted-foreground font-numeric-data pt-1">
                  {log.createdAt.toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric", hour: "2-digit", minute: "2-digit" })}
                </div>
                <div>
                  <p className="font-medium text-foreground">
                    <span className="text-primary font-bold uppercase tracking-wider text-xs mr-2 px-2 py-0.5 bg-primary/10 rounded">{log.entity}</span> 
                    {log.action}
                  </p>
                  {log.newValue && (
                    <div className="mt-2 text-xs font-mono bg-muted p-2 rounded-md border border-border overflow-x-auto text-muted-foreground">
                      {JSON.stringify(log.newValue)}
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
