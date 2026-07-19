"use client";

import { Trash2 } from "lucide-react";

export default function DeleteMonthButton({ monthId, deleteAction }: { monthId: string; deleteAction: (monthId: string) => Promise<void> }) {
  return (
    <button
      onClick={async () => {
        const confirmed = window.confirm(
          "Are you sure you want to permanently delete this month and ALL its data (payments, utilities, expenses, debts)? This cannot be undone."
        );
        if (confirmed) {
          await deleteAction(monthId);
        }
      }}
      className="px-3 py-1.5 border border-destructive/30 text-destructive bg-destructive/5 hover:bg-destructive/10 font-semibold rounded-lg transition text-xs flex items-center gap-1.5"
    >
      <Trash2 size={14} /> Delete
    </button>
  );
}
