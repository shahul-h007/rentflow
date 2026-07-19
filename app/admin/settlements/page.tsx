import React from "react";
import { getSettlements, settleDebt, cancelDebt } from "@/app/actions/settlements";
import { ArrowRightLeft, Check, X, ShieldAlert, History } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function SettlementsManagement() {
  const { pending, history } = await getSettlements();

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground">Settlement Engine</h1>
          <p className="text-muted-foreground mt-1">Track internal house debts and resolve balances.</p>
        </div>
      </div>

      {/* Pending Settlements */}
      <div className="bg-card border border-border rounded-2xl shadow-soft overflow-hidden">
        <div className="p-6 border-b border-border flex items-center justify-between bg-destructive/5">
          <h2 className="font-semibold text-destructive flex items-center gap-2 text-lg">
            <ArrowRightLeft size={20} /> Open Settlements
          </h2>
          <span className="bg-destructive/10 text-destructive text-xs font-bold px-3 py-1 rounded-full">
            {pending.length} Pending
          </span>
        </div>
        
        {pending.length === 0 ? (
          <div className="p-12 text-center text-muted-foreground flex flex-col items-center">
            <div className="w-16 h-16 rounded-full bg-emerald-500/10 flex items-center justify-center text-emerald-500 mb-4">
              <Check size={32} />
            </div>
            <p className="font-semibold text-foreground text-lg mb-1">Everyone is settled up!</p>
            <p className="text-sm">No members owe money to each other right now.</p>
          </div>
        ) : (
          <div className="divide-y divide-border">
            {pending.map((debt) => {
              const remaining = debt.amount - debt.settledAmount;
              return (
                <div key={debt.id} className="p-6 flex flex-col md:flex-row md:items-center justify-between gap-6 hover:bg-muted/30 transition">
                  <div className="flex items-center gap-4 flex-1">
                    <div className="flex items-center">
                      <div className="w-12 h-12 rounded-full bg-destructive/10 flex items-center justify-center text-destructive font-bold border-2 border-background z-10">
                        {debt.debtor.name.charAt(0)}
                      </div>
                      <div className="-ml-4 w-12 h-12 rounded-full bg-emerald-500/10 flex items-center justify-center text-emerald-600 font-bold border-2 border-background z-0">
                        {debt.creditor.name.charAt(0)}
                      </div>
                    </div>
                    <div>
                      <p className="font-semibold text-foreground">
                        <span className="text-destructive">{debt.debtor.name}</span> owes <span className="text-emerald-600">{debt.creditor.name}</span>
                      </p>
                      <p className="text-sm text-muted-foreground mt-0.5">{debt.reason}</p>
                      {debt.settledAmount > 0 && (
                        <p className="text-xs font-semibold text-emerald-600 bg-emerald-500/10 inline-block px-2 py-0.5 rounded mt-1.5">
                          ₹{debt.settledAmount.toLocaleString()} paid • ₹{remaining.toLocaleString()} left
                        </p>
                      )}
                    </div>
                  </div>
                  
                  <div className="flex items-center gap-6">
                    <div className="text-right">
                      <p className="text-xs text-muted-foreground font-semibold uppercase">Pending Balance</p>
                      <p className="text-xl font-numeric-data font-bold text-destructive">₹{remaining.toLocaleString()}</p>
                    </div>
                    
                    <div className="flex flex-col gap-2 min-w-[120px]">
                      <form action={async () => {
                        "use server";
                        await settleDebt(debt.id, remaining, "Cash/UPI");
                      }}>
                        <button className="w-full px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-semibold rounded-lg shadow-sm transition flex items-center justify-center gap-1.5">
                          <Check size={14} /> Full Settle
                        </button>
                      </form>
                      <form action={async () => {
                        "use server";
                        await cancelDebt(debt.id);
                      }}>
                        <button className="w-full px-4 py-2 border border-destructive/20 text-destructive bg-destructive/5 hover:bg-destructive/10 text-xs font-semibold rounded-lg transition flex items-center justify-center gap-1.5">
                          <ShieldAlert size={14} /> Cancel
                        </button>
                      </form>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* History */}
      <div className="bg-card border border-border rounded-2xl shadow-soft overflow-hidden mt-8">
        <div className="p-6 border-b border-border flex items-center justify-between">
          <h2 className="font-semibold text-foreground flex items-center gap-2 text-lg">
            <History size={20} className="text-muted-foreground" /> Settlement History
          </h2>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse min-w-[700px]">
            <thead>
              <tr className="border-b border-border bg-muted/30">
                <th className="py-3 px-6 text-xs font-semibold text-muted-foreground uppercase tracking-wider">Date</th>
                <th className="py-3 px-6 text-xs font-semibold text-muted-foreground uppercase tracking-wider">Transaction</th>
                <th className="py-3 px-6 text-xs font-semibold text-muted-foreground uppercase tracking-wider text-right">Amount</th>
                <th className="py-3 px-6 text-xs font-semibold text-muted-foreground uppercase tracking-wider text-center">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {history.length === 0 ? (
                <tr>
                  <td colSpan={4} className="py-8 text-center text-muted-foreground">
                    No settlement history found.
                  </td>
                </tr>
              ) : (
                history.map((debt) => (
                  <tr key={debt.id} className="hover:bg-muted/20 transition">
                    <td className="py-3 px-6 text-sm text-muted-foreground font-numeric-data">
                      {debt.settledAt?.toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" })}
                    </td>
                    <td className="py-3 px-6 font-medium text-foreground">
                      <span className="opacity-70">{debt.debtor.name}</span> paid <span className="opacity-70">{debt.creditor.name}</span>
                      <p className="text-xs text-muted-foreground font-normal mt-0.5">{debt.reason}</p>
                    </td>
                    <td className="py-3 px-6 text-right font-numeric-data font-bold text-foreground">
                      ₹{debt.amount.toLocaleString()}
                    </td>
                    <td className="py-3 px-6 text-center">
                      <span className={`inline-flex px-2.5 py-1 rounded-full text-xs font-bold uppercase tracking-wider ${
                        debt.status === "SETTLED" ? "bg-emerald-500/10 text-emerald-600" :
                        "bg-destructive/10 text-destructive"
                      }`}>
                        {debt.status}
                      </span>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
