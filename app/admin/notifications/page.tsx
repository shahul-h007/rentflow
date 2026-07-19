import React from "react";
import { getNotifications, markNotificationAsRead } from "@/app/actions/notifications";
import { Bell, Check, Info, AlertTriangle, ShieldAlert } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function NotificationsManagement() {
  const notifications = await getNotifications();

  return (
    <div className="space-y-8 animate-in fade-in duration-500 max-w-4xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground flex items-center gap-2">
            <Bell className="text-primary" size={28} /> Notifications
          </h1>
          <p className="text-muted-foreground mt-1">System alerts and critical updates.</p>
        </div>
      </div>

      <div className="bg-card border border-border rounded-2xl shadow-soft overflow-hidden">
        {notifications.length === 0 ? (
          <div className="p-12 text-center text-muted-foreground flex flex-col items-center">
            <Bell size={48} className="opacity-20 mb-4" />
            <p>You have no notifications.</p>
          </div>
        ) : (
          <div className="divide-y divide-border">
            {notifications.map((note) => {
              const Icon = note.type === "SYSTEM" ? Info : note.type === "RENT_DUE" ? AlertTriangle : ShieldAlert;
              const iconColor = note.type === "SYSTEM" ? "text-blue-500 bg-blue-500/10" : note.type === "RENT_DUE" ? "text-amber-500 bg-amber-500/10" : "text-primary bg-primary/10";
              
              return (
                <div key={note.id} className={`p-5 hover:bg-muted/30 transition flex flex-col sm:flex-row sm:items-start justify-between gap-4 ${note.isRead ? 'opacity-70' : 'bg-primary/5'}`}>
                  <div className="flex gap-4">
                    <div className={`w-10 h-10 rounded-full flex items-center justify-center shrink-0 ${iconColor}`}>
                      <Icon size={20} />
                    </div>
                    <div>
                      <h3 className={`font-semibold ${note.isRead ? 'text-foreground/80' : 'text-foreground'}`}>
                        {note.title}
                      </h3>
                      <p className="text-sm text-muted-foreground mt-0.5">{note.message}</p>
                      <p className="text-xs text-muted-foreground mt-2 font-numeric-data">
                        {note.createdAt.toLocaleString("en-US", { month: "short", day: "numeric", hour: "2-digit", minute: "2-digit" })}
                      </p>
                    </div>
                  </div>
                  
                  {!note.isRead && (
                    <form action={async () => {
                      "use server";
                      await markNotificationAsRead(note.id);
                    }}>
                      <button className="px-3 py-1.5 bg-muted text-muted-foreground hover:bg-emerald-500/10 hover:text-emerald-600 font-semibold rounded-lg transition text-xs flex items-center gap-1.5 shrink-0">
                        <Check size={14} /> Mark Read
                      </button>
                    </form>
                  )}
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}
