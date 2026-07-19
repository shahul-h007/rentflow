import React from "react";
import { getPendingPayments, getPaymentHistory, confirmPayment, rejectPayment } from "@/app/actions/payments";
import { Check, X, CreditCard, History, Clock } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function PaymentsManagement() {
  const pendingTransactions = await getPendingPayments();
  const historyTransactions = await getPaymentHistory();

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground">Payments</h1>
          <p className="text-muted-foreground mt-1">Verify, confirm, or reject member rent payments.</p>
        </div>
      </div>

      {/* Pending Queue */}
      <div className="bg-card border border-border rounded-2xl shadow-soft overflow-hidden">
        <div className="p-6 border-b border-border flex items-center justify-between bg-amber-500/5">
          <h2 className="font-semibold text-amber-600 flex items-center gap-2 text-lg">
            <Clock size={20} /> Verification Queue
          </h2>
          <span className="bg-amber-100 text-amber-800 text-xs font-bold px-3 py-1 rounded-full">
            {pendingTransactions.length} Pending
          </span>
        </div>
        
        {pendingTransactions.length === 0 ? (
          <div className="p-8 text-center text-muted-foreground">
            <Check size={32} className="mx-auto mb-3 text-emerald-500 opacity-50" />
            <p className="font-medium text-foreground">All caught up!</p>
            <p className="text-sm">No pending payments to verify.</p>
          </div>
        ) : (
          <div className="divide-y divide-border">
            {pendingTransactions.map((tx) => (
              <div key={tx.id} className="p-6 flex flex-col md:flex-row md:items-center justify-between gap-4 hover:bg-muted/30 transition">
                <div className="flex items-center gap-4">
                  <div className="w-12 h-12 rounded-full bg-primary/10 flex items-center justify-center text-primary font-bold shadow-sm">
                    {tx.rentPayment.member.name.charAt(0)}
                  </div>
                  <div>
                    <p className="font-semibold text-foreground text-lg">{tx.rentPayment.member.name}</p>
                    <p className="text-sm text-muted-foreground">
                      Submitted <strong className="text-foreground">₹{tx.amount.toLocaleString()}</strong> via {tx.method}
                    </p>
                    {tx.payer && tx.payerId !== tx.rentPayment.memberId && (
                      <p className="text-xs text-primary font-medium mt-1">
                        Paid on behalf by {tx.payer.name}
                      </p>
                    )}
                    {tx.reference && (
                      <p className="text-xs font-numeric-data bg-muted px-2 py-0.5 rounded mt-1 inline-block">
                        Ref: {tx.reference}
                      </p>
                    )}
                  </div>
                </div>
                
                <div className="flex items-center gap-3 w-full md:w-auto">
                  <form action={async () => {
                    "use server";
                    await confirmPayment(tx.id);
                  }} className="flex-1 md:flex-none">
                    <button className="w-full px-5 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white font-semibold rounded-lg shadow-sm transition active:scale-95 flex items-center justify-center gap-2">
                      <Check size={18} /> Confirm
                    </button>
                  </form>
                  <form action={async () => {
                    "use server";
                    await rejectPayment(tx.id);
                  }} className="flex-1 md:flex-none">
                    <button className="w-full px-5 py-2.5 border border-destructive/30 text-destructive bg-destructive/5 hover:bg-destructive/10 font-semibold rounded-lg transition active:scale-95 flex items-center justify-center gap-2">
                      <X size={18} /> Reject
                    </button>
                  </form>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Payment History */}
      <div className="bg-card border border-border rounded-2xl shadow-soft overflow-hidden mt-8">
        <div className="p-6 border-b border-border flex items-center justify-between">
          <h2 className="font-semibold text-foreground flex items-center gap-2 text-lg">
            <History size={20} className="text-muted-foreground" /> Ledger History
          </h2>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse min-w-[700px]">
            <thead>
              <tr className="border-b border-border bg-muted/30">
                <th className="py-3 px-6 text-xs font-semibold text-muted-foreground uppercase tracking-wider">Date</th>
                <th className="py-3 px-6 text-xs font-semibold text-muted-foreground uppercase tracking-wider">Member</th>
                <th className="py-3 px-6 text-xs font-semibold text-muted-foreground uppercase tracking-wider">Method</th>
                <th className="py-3 px-6 text-xs font-semibold text-muted-foreground uppercase tracking-wider text-right">Amount</th>
                <th className="py-3 px-6 text-xs font-semibold text-muted-foreground uppercase tracking-wider text-center">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {historyTransactions.length === 0 ? (
                <tr>
                  <td colSpan={5} className="py-8 text-center text-muted-foreground">
                    No transactions found.
                  </td>
                </tr>
              ) : (
                historyTransactions.map((tx) => (
                  <tr key={tx.id} className="hover:bg-muted/20 transition">
                    <td className="py-3 px-6 text-sm text-muted-foreground font-numeric-data">
                      {tx.paidAt.toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" })}
                    </td>
                    <td className="py-3 px-6 font-medium text-foreground">
                      {tx.rentPayment.member.name}
                      {tx.payer && tx.payerId !== tx.rentPayment.memberId && (
                        <span className="block text-xs text-primary">by {tx.payer.name}</span>
                      )}
                    </td>
                    <td className="py-3 px-6 text-sm text-muted-foreground flex items-center gap-1.5 mt-1">
                      <CreditCard size={14} /> {tx.method}
                    </td>
                    <td className="py-3 px-6 text-right font-numeric-data font-bold text-foreground">
                      ₹{tx.amount.toLocaleString()}
                    </td>
                    <td className="py-3 px-6 text-center">
                      <span className={`inline-flex px-2.5 py-1 rounded-full text-xs font-bold uppercase tracking-wider ${
                        tx.status === "CONFIRMED" ? "bg-emerald-500/10 text-emerald-600" :
                        tx.status === "REJECTED" ? "bg-destructive/10 text-destructive" :
                        "bg-amber-500/10 text-amber-600"
                      }`}>
                        {tx.status}
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
