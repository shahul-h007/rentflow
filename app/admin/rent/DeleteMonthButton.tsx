"use client";

import { useState } from "react";
import { Trash2, LoaderCircle } from "lucide-react";

export default function DeleteMonthButton({ monthId, deleteAction }: { monthId: string; deleteAction: (monthId: string) => Promise<void> }) {
  const [isDeleting, setIsDeleting] = useState(false);

  return (
    <button
      disabled={isDeleting}
      onClick={async () => {
        const confirmed = window.confirm(
          "Are you sure you want to permanently delete this month and ALL its data (payments, utilities, expenses, debts)? This cannot be undone."
        );
        if (confirmed) {
          setIsDeleting(true);
          try {
            await deleteAction(monthId);
          } finally {
            setIsDeleting(false);
          }
        }
      }}
      className="px-3 py-1.5 border border-destructive/30 text-destructive bg-destructive/5 hover:bg-destructive/10 font-semibold rounded-lg transition text-xs flex items-center gap-1.5 disabled:opacity-50"
    >
      {isDeleting ? <LoaderCircle size={14} className="animate-spin" /> : <Trash2 size={14} />} Delete
    </button>
  );
}
