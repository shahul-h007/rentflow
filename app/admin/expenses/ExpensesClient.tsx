"use client";

import React, { useState } from "react";
import { Plus, Trash2, Calendar, IndianRupee } from "lucide-react";
import { addExpense, deleteExpense } from "@/app/actions/expenses";

export default function ExpensesClient({ month, members }: { month: any; members: any[] }) {
  const [isAdding, setIsAdding] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const [title, setTitle] = useState("");
  const [amount, setAmount] = useState("");
  const [paidById, setPaidById] = useState(members[0]?.id || "");
  const [splitType, setSplitType] = useState("EQUAL");
  const [customSplits, setCustomSplits] = useState<Record<string, string>>({});
  const [selectedMembers, setSelectedMembers] = useState<Record<string, boolean>>(
    members.reduce((acc, m) => ({ ...acc, [m.id]: true }), {})
  );

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
      } else if (splitType === "SELECTED") {
        const selectedIds = Object.keys(selectedMembers).filter(id => selectedMembers[id]);
        if (selectedIds.length === 0) throw new Error("Select at least one member");
        const share = Math.ceil(totalAmt / selectedIds.length);
        for (const id of selectedIds) {
          splits.push({ memberId: id, amount: share });
        }
      } else {
        let sum = 0;
        for (const m of members) {
          const val = parseInt(customSplits[m.id] || "0");
          sum += val;
          if (val > 0) splits.push({ memberId: m.id, amount: val });
        }
        if (sum !== totalAmt) {
          throw new Error(`Custom splits (${sum}) must equal total amount (${totalAmt})`);
        }
      }

      await addExpense({
        monthId: month.id,
        paidById,
        title,
        amount: totalAmt,
        splitType: splitType as any,
        splits
      });

      setIsAdding(false);
      setTitle("");
      setAmount("");
      setCustomSplits({});
    } catch (err: any) {
      alert(err.message);
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Are you sure? This will delete the expense and reverse the generated settlements.")) return;
    try {
      await deleteExpense(id);
    } catch (err: any) {
      alert(err.message);
    }
  };

  return (
    <div className="space-y-8">
      {/* List */}
      <div className="bg-card border border-border rounded-2xl overflow-hidden shadow-sm">
        <div className="p-6 border-b border-border flex items-center justify-between">
          <h2 className="text-xl font-bold text-foreground">Expenses for {new Date(month.startsOn).toLocaleString("default", { month: "long", year: "numeric" })}</h2>
          {!isAdding && (
            <button
              onClick={() => setIsAdding(true)}
              className="flex items-center gap-2 px-4 py-2 bg-primary text-primary-foreground font-semibold rounded-lg hover:bg-primary/90 transition-colors"
            >
              <Plus size={18} />
              Add Expense
            </button>
          )}
        </div>

        {isAdding && (
          <form onSubmit={handleAdd} className="p-6 bg-muted/30 border-b border-border">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
              <div>
                <label className="block text-sm font-medium text-foreground mb-1">Title</label>
                <input
                  type="text"
                  required
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  placeholder="e.g. Groceries, Supplies"
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
                  placeholder="1500"
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
                  <option value="SELECTED">Selected Members (Equal)</option>
                  <option value="CUSTOM">Custom Split</option>
                </select>
              </div>
            </div>

            {splitType === "SELECTED" && (
              <div className="mb-6 p-4 border border-border rounded-xl bg-background">
                <h4 className="font-semibold text-sm mb-3">Select Members to Split Between</h4>
                <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3">
                  {members.map(m => (
                    <label key={m.id} className="flex items-center gap-2 cursor-pointer">
                      <input
                        type="checkbox"
                        checked={selectedMembers[m.id] || false}
                        onChange={(e) => setSelectedMembers({ ...selectedMembers, [m.id]: e.target.checked })}
                        className="rounded border-border text-primary focus:ring-primary h-4 w-4"
                      />
                      <span className="text-sm font-medium truncate">{m.name}</span>
                    </label>
                  ))}
                </div>
              </div>
            )}

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
                {isSubmitting ? "Saving..." : "Save Expense"}
              </button>
            </div>
          </form>
        )}

        {month.expenses.length === 0 ? (
          <div className="p-8 text-center text-muted-foreground">
            No expenses added for this month yet.
          </div>
        ) : (
          <div className="divide-y divide-border">
            {month.expenses.map((e: any) => (
              <div key={e.id} className="p-6 hover:bg-muted/30 transition-colors">
                <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                  <div>
                    <h3 className="text-lg font-bold text-foreground">{e.title}</h3>
                    <div className="flex items-center gap-4 text-sm text-muted-foreground mt-1">
                      <span className="flex items-center gap-1"><IndianRupee size={14}/> {e.amount}</span>
                      <span className="flex items-center gap-1"><Calendar size={14}/> {new Date(e.createdAt).toLocaleDateString()}</span>
                      <span className="px-2 py-0.5 bg-primary/10 text-primary rounded-full text-xs font-semibold">
                        {e.splitType} SPLIT
                      </span>
                    </div>
                  </div>
                  
                  <div className="flex items-center gap-4">
                    <div className="text-right mr-4">
                      <p className="text-sm text-muted-foreground">Paid by</p>
                      <p className="font-semibold">{e.paidBy?.name}</p>
                    </div>
                    <button
                      onClick={() => handleDelete(e.id)}
                      className="p-2 text-red-500 hover:bg-red-500/10 rounded-lg transition-colors"
                      title="Delete Expense"
                    >
                      <Trash2 size={20} />
                    </button>
                  </div>
                </div>

                <div className="mt-4 grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-2">
                  {e.splits.map((p: any) => (
                    <div key={p.id} className="flex justify-between items-center text-sm p-2 bg-muted/30 rounded-lg border border-border">
                      <span className="font-medium text-foreground truncate mr-2">{p.member.name}</span>
                      <span className="text-muted-foreground">₹{p.amount}</span>
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
