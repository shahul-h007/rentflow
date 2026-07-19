import React from "react";
import { getReportMetrics, getMonthlyRentData } from "@/app/actions/reports";
import { BarChart3, TrendingUp, Users, Wallet } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function ReportsManagement() {
  const metrics = await getReportMetrics();
  const monthlyData = await getMonthlyRentData();

  return (
    <div className="space-y-8 animate-in fade-in duration-500 max-w-5xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground flex items-center gap-2">
            <BarChart3 className="text-primary" size={28} /> Reports & Analytics
          </h1>
          <p className="text-muted-foreground mt-1">High-level financial overview of RentFlow.</p>
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="p-6 bg-card border border-border rounded-2xl shadow-sm">
          <div className="flex items-center gap-3 text-muted-foreground mb-3">
            <Wallet size={18} />
            <h3 className="font-semibold text-sm uppercase tracking-wider">Total Collected</h3>
          </div>
          <p className="text-3xl font-numeric-data font-bold text-foreground">₹{metrics.totalCollected.toLocaleString()}</p>
        </div>
        
        <div className="p-6 bg-card border border-border rounded-2xl shadow-sm">
          <div className="flex items-center gap-3 text-muted-foreground mb-3">
            <Users size={18} />
            <h3 className="font-semibold text-sm uppercase tracking-wider">Active Members</h3>
          </div>
          <p className="text-3xl font-numeric-data font-bold text-foreground">{metrics.activeMembers}</p>
        </div>

        <div className="p-6 bg-card border border-border rounded-2xl shadow-sm">
          <div className="flex items-center gap-3 text-destructive/70 mb-3">
            <TrendingUp size={18} />
            <h3 className="font-semibold text-sm uppercase tracking-wider">Open Debts</h3>
          </div>
          <p className="text-3xl font-numeric-data font-bold text-destructive">₹{metrics.totalOpenDebt.toLocaleString()}</p>
          <p className="text-xs text-muted-foreground mt-1 font-semibold">{metrics.pendingSettlements} pending settlements</p>
        </div>
      </div>

      <div className="bg-card border border-border rounded-2xl shadow-soft overflow-hidden">
        <div className="p-6 border-b border-border">
          <h2 className="font-semibold text-foreground text-lg">Monthly Revenue</h2>
        </div>
        
        {monthlyData.length === 0 ? (
          <div className="p-12 text-center text-muted-foreground">
            No rent data available to generate reports.
          </div>
        ) : (
          <div className="p-6 overflow-x-auto">
            <div className="flex items-end gap-2 min-h-[250px] min-w-[600px] pt-10">
              {monthlyData.map((data) => {
                const total = data.collected + data.pending;
                const collectedHeight = total > 0 ? (data.collected / total) * 100 : 0;
                const pendingHeight = total > 0 ? (data.pending / total) * 100 : 0;

                return (
                  <div key={data.month} className="flex-1 flex flex-col items-center gap-2 group">
                    <div className="w-full relative h-48 flex flex-col justify-end bg-muted/10 rounded-t-md overflow-hidden">
                      {/* Pending Stack */}
                      <div 
                        style={{ height: `${pendingHeight}%` }} 
                        className="w-full bg-amber-400/50 transition-all duration-500 group-hover:bg-amber-400/70"
                        title={`Pending: ₹${data.pending}`}
                      ></div>
                      {/* Collected Stack */}
                      <div 
                        style={{ height: `${collectedHeight}%` }} 
                        className="w-full bg-emerald-500 transition-all duration-500 group-hover:bg-emerald-600"
                        title={`Collected: ₹${data.collected}`}
                      ></div>
                    </div>
                    <span className="text-xs font-semibold text-muted-foreground">{data.month}</span>
                  </div>
                );
              })}
            </div>
            <div className="mt-6 flex items-center justify-center gap-6">
              <div className="flex items-center gap-2 text-sm font-medium text-muted-foreground">
                <span className="w-3 h-3 rounded-full bg-emerald-500"></span> Collected
              </div>
              <div className="flex items-center gap-2 text-sm font-medium text-muted-foreground">
                <span className="w-3 h-3 rounded-full bg-amber-400/50"></span> Pending
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
