"use client";

import React, { useState } from "react";
import { Plus, Trash2, Calendar, IndianRupee } from "lucide-react";
import { addUtility, deleteUtility } from "@/app/actions/utilities";

export default function UtilitiesClient({ month, members }: { month: any; members: any[] }) {
  const [isAdding, setIsAdding] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const [name, setName] = useState("");
  const [amount, setAmount] = useState("");
  const [paidById, setPaidById] = useState(members[0]?.id || "");
  const [splitType, setSplitType] = useState("EQUAL");
  const [customSplits, setCustomSplits] = useState<Record<string, string>>({});

  const handleAdd = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    try {
      const totalAmt = parseInt(amount);
      if (isNaN(totalAmt) || totalAmt <= 0) throw new Error("Invalid amount");

      const splits = [];

      if (splitType === "EQUAL") {
        const share = Math.ceil(totalAmt / members.length);
        for (const m of members) {
          splits.push({ memberId: m.id, amount: share });
        }
      } else {
        let sum = 0;
        for (const m of members) {
          const val = parseInt(customSplits[m.id] || "0");
          sum += val;
          splits.push({ memberId: m.id, amount: val });
        }
        if (sum !== totalAmt) {
          throw new Error(`Custom splits (${sum}) must equal total amount (${totalAmt})`);
        }
      }

      await addUtility({
        monthId: month.id,
        paidById,
        name,
        amount: totalAmt,
        splitType: splitType as any,
        splits
      });

      setIsAdding(false);
      setName("");
      setAmount("");
      setCustomSplits({});
    } catch (err: any) {
      alert(err.message);
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Are you sure? This will delete the utility and reverse the generated settlements.")) return;
    try {
      await deleteUtility(id);
    } catch (err: any) {
      alert(err.message);
    }
  };

  return (
    <div className="space-y-8">
      {/* List */}
      <div className="bg-card border border-border rounded-2xl overflow-hidden shadow-sm">
        <div className="p-6 border-b border-border flex items-center justify-between">
          <h2 className="text-xl font-bold text-foreground">Bills for {new Date(month.startsOn).toLocaleString("default", { month: "long", year: "numeric" })}</h2>
          {!isAdding && (
            <button
              onClick={() => setIsAdding(true)}
              className="flex items-center gap-2 px-4 py-2 bg-primary text-primary-foreground font-semibold rounded-lg hover:bg-primary/90 transition-colors"
            >
              <Plus size={18} />
              Add Bill
            </button>
          )}
        </div>

        {isAdding && (
          <form onSubmit={handleAdd} className="p-6 bg-muted/30 border-b border-border">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
              <div>
                <label className="block text-sm font-medium text-foreground mb-1">Utility Name</label>
                <input
                  type="text"
                  required
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="e.g. Electricity, Water"
                  className="w-full bg-background border border-border rounded-lg px-4 py-2.5 outline-none focus:border-primary"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-foreground mb-1">Total Amount (₹)</label>
                <input
                  type="number"
                  required
                  min="1"
                  value={amount}
                  onChange={(e) => setAmount(e.target.value)}
                  placeholder="2480"
                  className="w-full bg-background border border-border rounded-lg px-4 py-2.5 outline-none focus:border-primary"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-foreground mb-1">Paid By</label>
                <select
                  value={paidById}
                  onChange={(e) => setPaidById(e.target.value)}
                  className="w-full bg-background border border-border rounded-lg px-4 py-2.5 outline-none focus:border-primary"
                >
                  {members.map(m => <option key={m.id} value={m.id}>{m.name}</option>)}
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-foreground mb-1">Split Method</label>
                <select
                  value={splitType}
                  onChange={(e) => setSplitType(e.target.value)}
                  className="w-full bg-background border border-border rounded-lg px-4 py-2.5 outline-none focus:border-primary"
                >
                  <option value="EQUAL">Equal Split</option>
                  <option value="CUSTOM">Custom Split</option>
                </select>
              </div>
            </div>

            {splitType === "CUSTOM" && (
              <div className="mb-6 p-4 border border-border rounded-xl bg-background">
                <h4 className="font-semibold text-sm mb-3">Enter Custom Shares</h4>
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
                  {members.map(m => (
                    <div key={m.id} className="flex items-center gap-2">
                      <span className="text-sm font-medium w-24 truncate">{m.name}</span>
                      <input
                        type="number"
                        min="0"
                        value={customSplits[m.id] || ""}
                        onChange={(e) => setCustomSplits({ ...customSplits, [m.id]: e.target.value })}
                        placeholder="₹"
                        className="w-full bg-background border border-border rounded-lg px-3 py-1.5 outline-none focus:border-primary text-sm"
                      />
                    </div>
                  ))}
                </div>
              </div>
            )}

            <div className="flex gap-3 justify-end">
              <button
                type="button"
                onClick={() => setIsAdding(false)}
                className="px-4 py-2 text-muted-foreground hover:text-foreground font-medium transition-colors"
              >
                Cancel
              </button>
              <button
                type="submit"
                disabled={isSubmitting}
                className="px-6 py-2 bg-primary text-primary-foreground font-semibold rounded-lg hover:bg-primary/90 transition-colors disabled:opacity-50"
              >
                {isSubmitting ? "Saving..." : "Save Utility"}
              </button>
            </div>
          </form>
        )}

        {month.utilities.length === 0 ? (
          <div className="p-8 text-center text-muted-foreground">
            No utilities added for this month yet.
          </div>
        ) : (
          <div className="divide-y divide-border">
            {month.utilities.map((u: any) => (
              <div key={u.id} className="p-6 hover:bg-muted/30 transition-colors">
                <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                  <div>
                    <h3 className="text-lg font-bold text-foreground">{u.name}</h3>
                    <div className="flex items-center gap-4 text-sm text-muted-foreground mt-1">
                      <span className="flex items-center gap-1"><IndianRupee size={14}/> {u.amount}</span>
                      <span className="flex items-center gap-1"><Calendar size={14}/> {new Date(u.createdAt).toLocaleDateString()}</span>
                      <span className="px-2 py-0.5 bg-primary/10 text-primary rounded-full text-xs font-semibold">
                        {u.splitType} SPLIT
                      </span>
                    </div>
                  </div>
                  
                  <div className="flex items-center gap-4">
                    <div className="text-right mr-4">
                      <p className="text-sm text-muted-foreground">Paid by</p>
                      <p className="font-semibold">{u.paidBy?.name}</p>
                    </div>
                    <button
                      onClick={() => handleDelete(u.id)}
                      className="p-2 text-red-500 hover:bg-red-500/10 rounded-lg transition-colors"
                      title="Delete Utility"
                    >
                      <Trash2 size={20} />
                    </button>
                  </div>
                </div>

                <div className="mt-4 grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-2">
                  {u.payments.map((p: any) => (
                    <div key={p.id} className="flex justify-between items-center text-sm p-2 bg-muted/30 rounded-lg border border-border">
                      <span className="font-medium text-foreground truncate mr-2">{p.member.name}</span>
                      <span className="text-muted-foreground">₹{p.amountDue}</span>
                    </div>
                  ))}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
