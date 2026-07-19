import React from "react";
import prisma from "@/lib/prisma";
import {
  Wallet,
  Users,
  AlertCircle,
  TrendingUp,
  Activity,
  CheckCircle2,
  Clock
} from "lucide-react";
import Link from "next/link";
import { getReportMetrics } from "@/app/actions/reports";
import { getActivityLogs } from "@/app/actions/activity";

export const dynamic = "force-dynamic";

export default async function AdminDashboard() {
  const metrics = await getReportMetrics();
  const recentActivity = await getActivityLogs().then(logs => logs.slice(0, 3));
  const currentMonthDate = new Date().toLocaleDateString("en-US", { month: "long", year: "numeric" });
  
  // Try to find the active month to show specific rent progress
  const startOfMonth = new Date();
  startOfMonth.setDate(1);
  startOfMonth.setHours(0,0,0,0);
  
  const activeMonth = await prisma.month.findFirst({
    where: { startsOn: { lte: new Date() }, status: "OPEN" },
    orderBy: { startsOn: "desc" },
    include: { rentPayments: true }
  });

  let houseRent = 0;
  let collected = 0;
  let pending = 0;
  let membersPaid = 0;
  let membersPending = 0;

  if (activeMonth) {
    houseRent = activeMonth.rent;
    collected = activeMonth.rentPayments.reduce((sum, p) => sum + p.amountPaid, 0);
    pending = activeMonth.rentPayments.reduce((sum, p) => sum + (p.amountDue - p.amountPaid), 0);
    membersPaid = activeMonth.rentPayments.filter(p => p.amountPaid >= p.amountDue).length;
    membersPending = activeMonth.rentPayments.filter(p => p.amountPaid < p.amountDue).length;
  }

  const rentProgress = houseRent > 0 ? (collected / houseRent) * 100 : 0;
  const memberProgress = (membersPaid + membersPending) > 0 ? (membersPaid / (membersPaid + membersPending)) * 100 : 0;
  const pendingMemberProgress = (membersPaid + membersPending) > 0 ? (membersPending / (membersPaid + membersPending)) * 100 : 0;

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground">Dashboard</h1>
          <p className="text-muted-foreground mt-1">
            Overview for {currentMonthDate}
          </p>
        </div>
        <div className="flex items-center gap-3">
          <Link href="/admin/rent" className="px-4 py-2 bg-primary text-primary-foreground font-semibold rounded-lg hover:bg-primary/90 transition shadow-sm text-sm">
            Manage Rent Cycle
          </Link>
        </div>
      </div>

      {/* Main Metrics */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        <div className="bg-card border border-border p-6 rounded-2xl shadow-soft">
          <div className="flex items-center justify-between pb-2">
            <h3 className="text-sm font-semibold text-muted-foreground">House Rent (Active)</h3>
            <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center text-primary">
              <Wallet size={16} />
            </div>
          </div>
          <p className="text-3xl font-bold font-numeric-data">₹{houseRent.toLocaleString()}</p>
          <div className="mt-4 flex items-center text-sm">
            <span className="text-emerald-500 font-medium flex items-center gap-1">
              <TrendingUp size={14} /> 100%
            </span>
            <span className="text-muted-foreground ml-2">Total Expected</span>
          </div>
        </div>

        <div className="bg-card border border-border p-6 rounded-2xl shadow-soft">
          <div className="flex items-center justify-between pb-2">
            <h3 className="text-sm font-semibold text-muted-foreground">Collected</h3>
            <div className="w-8 h-8 rounded-full bg-emerald-500/10 flex items-center justify-center text-emerald-500">
              <CheckCircle2 size={16} />
            </div>
          </div>
          <p className="text-3xl font-bold font-numeric-data">₹{collected.toLocaleString()}</p>
          <div className="mt-4 flex items-center text-sm">
            <div className="w-full bg-muted rounded-full h-1.5 mr-2">
              <div className="bg-emerald-500 h-1.5 rounded-full" style={{ width: `${rentProgress}%` }}></div>
            </div>
            <span className="text-muted-foreground font-numeric-data">{Math.round(rentProgress)}%</span>
          </div>
        </div>

        <div className="bg-card border border-border p-6 rounded-2xl shadow-soft">
          <div className="flex items-center justify-between pb-2">
            <h3 className="text-sm font-semibold text-muted-foreground">Pending Rent</h3>
            <div className="w-8 h-8 rounded-full bg-destructive/10 flex items-center justify-center text-destructive">
              <Clock size={16} />
            </div>
          </div>
          <p className="text-3xl font-bold font-numeric-data text-destructive">₹{pending.toLocaleString()}</p>
          <div className="mt-4 flex items-center text-sm">
            <span className="text-destructive font-medium">
              {membersPending} members
            </span>
            <span className="text-muted-foreground ml-2">yet to pay</span>
          </div>
        </div>

        <div className="bg-card border border-border p-6 rounded-2xl shadow-soft">
          <div className="flex items-center justify-between pb-2">
            <h3 className="text-sm font-semibold text-muted-foreground">Open Debts</h3>
            <div className="w-8 h-8 rounded-full bg-amber-500/10 flex items-center justify-center text-amber-500">
              <AlertCircle size={16} />
            </div>
          </div>
          <p className="text-3xl font-bold font-numeric-data text-amber-500">₹{metrics.totalOpenDebt.toLocaleString()}</p>
          <div className="mt-4 flex items-center text-sm">
            <Link href="/admin/settlements" className="text-primary hover:underline font-medium">
              Resolve {metrics.pendingSettlements} now →
            </Link>
          </div>
        </div>
      </div>

      {/* Secondary Metrics */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-card border border-border rounded-2xl shadow-soft overflow-hidden">
          <div className="p-6 border-b border-border flex items-center justify-between">
            <h3 className="font-semibold text-foreground flex items-center gap-2">
              <Activity size={18} className="text-primary" />
              Recent Activity
            </h3>
            <Link href="/admin/activity" className="text-sm text-primary hover:underline">
              View All
            </Link>
          </div>
          <div className="divide-y divide-border">
            {recentActivity.length === 0 ? (
              <div className="p-6 text-center text-muted-foreground text-sm">No recent activity.</div>
            ) : (
              recentActivity.map((log) => (
                <div key={log.id} className="p-4 px-6 flex items-center justify-between hover:bg-muted/50 transition">
                  <div className="flex items-center gap-4">
                    <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center text-primary font-bold">
                      {log.entity.charAt(0)}
                    </div>
                    <div>
                      <p className="font-medium text-sm">{log.action}</p>
                      <p className="text-xs text-muted-foreground">
                        {log.createdAt.toLocaleDateString("en-US", { month: "short", day: "numeric" })}
                      </p>
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>

        <div className="bg-card border border-border rounded-2xl shadow-soft p-6">
          <h3 className="font-semibold text-foreground flex items-center gap-2 mb-6">
            <Users size={18} className="text-primary" />
            Active Month Members
          </h3>
          <div className="space-y-6">
            <div>
              <div className="flex justify-between text-sm mb-2">
                <span className="text-muted-foreground">Paid ({membersPaid})</span>
                <span className="font-medium">{Math.round(memberProgress)}%</span>
              </div>
              <div className="w-full bg-muted rounded-full h-2">
                <div className="bg-emerald-500 h-2 rounded-full" style={{ width: `${memberProgress}%` }}></div>
              </div>
            </div>
            <div>
              <div className="flex justify-between text-sm mb-2">
                <span className="text-muted-foreground">Pending ({membersPending})</span>
                <span className="font-medium">{Math.round(pendingMemberProgress)}%</span>
              </div>
              <div className="w-full bg-muted rounded-full h-2">
                <div className="bg-destructive h-2 rounded-full" style={{ width: `${pendingMemberProgress}%` }}></div>
              </div>
            </div>
            <div className="pt-4 mt-4 border-t border-border flex justify-between items-center">
              <div>
                <p className="text-xs text-muted-foreground">Total Active Members</p>
                <p className="text-xl font-bold font-numeric-data">{metrics.activeMembers}</p>
              </div>
              <Link href="/admin/members" className="px-4 py-2 border border-border rounded-lg text-sm font-medium hover:bg-muted transition">
                Manage Members
              </Link>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
