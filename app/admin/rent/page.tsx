import React from "react";
import prisma from "@/lib/prisma";
import { Wallet, PlayCircle, Lock, Calendar, CheckCircle2, Circle, Activity } from "lucide-react";
import { generateMonthlyRent, closeMonth, reopenMonth, recalculateOpenMonths, deleteMonth } from "@/app/actions/rent";
import { revalidatePath } from "next/cache";
import DeleteMonthButton from "./DeleteMonthButton";

export const dynamic = "force-dynamic";

export default async function RentManagement() {
  // Assuming a single house for now since this is the admin portal for one house.
  const house = await prisma.house.findFirst();
  
  if (!house) {
    return (
      <div className="p-8 text-center bg-card rounded-2xl shadow-soft mt-8 border border-border">
        <h2 className="text-xl font-bold mb-2">No House Configured</h2>
        <p className="text-muted-foreground">Please configure a house before managing rent.</p>
      </div>
    );
  }

  const months = await prisma.month.findMany({
    where: { houseId: house.id },
    orderBy: { startsOn: "desc" },
    include: {
      rentPayments: {
        include: { member: true },
        orderBy: { member: { name: "asc" } }
      }
    }
  });

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground">Monthly Rent</h1>
          <p className="text-muted-foreground mt-1">Manage rent generation, open/close months, and track balances.</p>
        </div>
        <div className="flex gap-2">
          <form action={async () => {
            "use server";
            const d = new Date();
            await generateMonthlyRent(house.id, d);
          }}>
            <button className="px-4 py-2 bg-primary text-primary-foreground font-semibold rounded-lg hover:bg-primary/90 transition shadow-sm text-sm flex items-center gap-2">
              <PlayCircle size={16} /> Generate New Month
            </button>
          </form>
        </div>
      </div>

      {months.length === 0 ? (
        <div className="p-12 text-center bg-card rounded-2xl shadow-soft border border-border flex flex-col items-center">
          <Calendar size={48} className="text-muted-foreground mb-4 opacity-50" />
          <h2 className="text-xl font-bold mb-2">No Rent Cycles Generated</h2>
          <p className="text-muted-foreground max-w-md">You haven't generated any rent cycles yet. Click "Generate New Month" to create the rent ledger for the current month.</p>
        </div>
      ) : (
        <div className="space-y-8">
          {months.map((month) => {
            const isClosed = month.status === "CLOSED";
            const totalDue = month.rentPayments.reduce((acc, curr) => acc + curr.amountDue, 0);
            const totalPaid = month.rentPayments.reduce((acc, curr) => acc + curr.amountPaid, 0);
            const monthName = month.startsOn.toLocaleDateString("en-US", { month: "long", year: "numeric" });
            
            return (
              <div key={month.id} className="bg-card border border-border rounded-2xl shadow-soft overflow-hidden">
                <div className={`p-5 flex items-center justify-between border-b border-border ${isClosed ? "bg-muted/30" : "bg-primary/5"}`}>
                  <div className="flex items-center gap-3">
                    <div className={`w-10 h-10 rounded-xl flex items-center justify-center font-bold ${isClosed ? "bg-muted text-muted-foreground" : "bg-primary/20 text-primary"}`}>
                      {isClosed ? <Lock size={20} /> : <Calendar size={20} />}
                    </div>
                    <div>
                      <h2 className="text-xl font-bold text-foreground">{monthName}</h2>
                      <span className={`text-xs font-semibold uppercase tracking-wider ${isClosed ? "text-muted-foreground" : "text-emerald-600"}`}>
                        {month.status}
                      </span>
                    </div>
                  </div>
                  
                  <div className="flex items-center gap-6">
                    <div className="hidden sm:block text-right">
                      <p className="text-xs text-muted-foreground font-semibold uppercase">Total Due</p>
                      <p className="text-sm font-numeric-data font-bold">₹{totalDue.toLocaleString()}</p>
                    </div>
                    <div className="hidden sm:block text-right">
                      <p className="text-xs text-muted-foreground font-semibold uppercase">Collected</p>
                      <p className="text-sm font-numeric-data font-bold text-emerald-600">₹{totalPaid.toLocaleString()}</p>
                    </div>
                    {isClosed ? (
                      <div className="flex items-center gap-2">
                        <form action={async () => {
                          "use server";
                          await reopenMonth(month.id);
                        }}>
                          <button className="px-3 py-1.5 border border-primary/20 text-primary bg-primary/5 hover:bg-primary/10 font-semibold rounded-lg transition text-xs flex items-center gap-1.5">
                            <Lock size={14} /> Reopen Month
                          </button>
                        </form>
                        <DeleteMonthButton monthId={month.id} deleteAction={deleteMonth} />
                      </div>
                    ) : (
                      <div className="flex items-center gap-2">
                        <form action={async () => {
                          "use server";
                          if (month.houseId) {
                            await recalculateOpenMonths(month.houseId);
                          }
                        }}>
                          <button 
                            className="px-3 py-1.5 border border-primary/20 text-primary bg-primary/5 hover:bg-primary/10 font-semibold rounded-lg transition text-xs flex items-center gap-1.5"
                          >
                            <Activity size={14} /> Recalculate
                          </button>
                        </form>
                        <form action={async () => {
                          "use server";
                          await closeMonth(month.id);
                        }}>
                          <button 
                            disabled={totalPaid < totalDue}
                            title={totalPaid < totalDue ? "Cannot close month until all rent is fully paid." : ""}
                            className="px-3 py-1.5 border border-destructive/20 text-destructive bg-destructive/5 hover:bg-destructive/10 disabled:opacity-50 disabled:cursor-not-allowed font-semibold rounded-lg transition text-xs flex items-center gap-1.5"
                          >
                            <Lock size={14} /> Close Month
                          </button>
                        </form>
                        <DeleteMonthButton monthId={month.id} deleteAction={deleteMonth} />
                      </div>
                    )}
                  </div>
                </div>

                <div className="overflow-x-auto">
                  <table className="w-full text-left border-collapse min-w-[600px]">
                    <thead>
                      <tr className="border-b border-border bg-muted/30">
                        <th className="py-3 px-6 text-xs font-semibold text-muted-foreground uppercase tracking-wider">Member</th>
                        <th className="py-3 px-6 text-xs font-semibold text-muted-foreground uppercase tracking-wider text-right">Rent Amount</th>
                        <th className="py-3 px-6 text-xs font-semibold text-muted-foreground uppercase tracking-wider text-right">Paid</th>
                        <th className="py-3 px-6 text-xs font-semibold text-muted-foreground uppercase tracking-wider text-right">Balance</th>
                        <th className="py-3 px-6 text-xs font-semibold text-muted-foreground uppercase tracking-wider text-center">Status</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-border">
                      {month.rentPayments.map(payment => {
                        const balance = payment.amountDue - payment.amountPaid;
                        return (
                          <tr key={payment.id} className="hover:bg-muted/20 transition-colors">
                            <td className="py-3 px-6 font-medium text-foreground">{payment.member.name}</td>
                            <td className="py-3 px-6 text-right font-numeric-data text-muted-foreground">
                              ₹{payment.amountDue.toLocaleString()}
                            </td>
                            <td className="py-3 px-6 text-right font-numeric-data font-medium text-emerald-600">
                              ₹{payment.amountPaid.toLocaleString()}
                            </td>
                            <td className={`py-3 px-6 text-right font-numeric-data font-bold ${balance > 0 ? "text-destructive" : "text-muted-foreground"}`}>
                              ₹{balance.toLocaleString()}
                            </td>
                            <td className="py-3 px-6 text-center">
                              {balance <= 0 ? (
                                <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-emerald-500/10 text-emerald-600">
                                  <CheckCircle2 size={12} /> PAID
                                </span>
                              ) : payment.amountPaid > 0 ? (
                                <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-amber-500/10 text-amber-600">
                                  <Circle size={12} /> PARTIAL
                                </span>
                              ) : (
                                <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-destructive/10 text-destructive">
                                  <Circle size={12} /> PENDING
                                </span>
                              )}
                            </td>
                          </tr>
                        );
                      })}
                    </tbody>
                  </table>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
