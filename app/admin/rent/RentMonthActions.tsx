"use client";

import { useState } from "react";
import { Lock, CheckCircle2, Activity, LoaderCircle } from "lucide-react";
import { closeMonth, reopenMonth, recalculateOpenMonths } from "@/app/actions/rent";
import DeleteMonthButton from "./DeleteMonthButton";

export default function RentMonthActions({ monthId, isClosed, totalDue }: { monthId: string, isClosed: boolean, totalDue: number }) {
  const [isProcessing, setIsProcessing] = useState(false);

  const handleAction = async (actionFn: () => Promise<void>) => {
    setIsProcessing(true);
    try {
      await actionFn();
    } catch (e: any) {
      alert(e.message);
    } finally {
      setIsProcessing(false);
    }
  };

  return (
    <div className="flex items-center gap-2">
      {isClosed ? (
        <>
          <button
            disabled={isProcessing}
            onClick={() => handleAction(async () => await reopenMonth(monthId))}
            className="px-3 py-1.5 border border-primary/20 text-primary bg-primary/5 hover:bg-primary/10 font-semibold rounded-lg transition text-xs flex items-center gap-1.5 disabled:opacity-50"
          >
            {isProcessing ? <LoaderCircle size={14} className="animate-spin" /> : <Lock size={14} />} Reopen Month
          </button>
          <DeleteMonthButton monthId={monthId} deleteAction={async (id) => handleAction(async () => {
            const { deleteMonth } = await import("@/app/actions/rent");
            await deleteMonth(id);
          })} />
        </>
      ) : (
        <>
          <button
            disabled={isProcessing}
            onClick={() => handleAction(async () => await closeMonth(monthId))}
            className="px-4 py-2 bg-foreground text-background font-semibold rounded-lg hover:bg-foreground/90 transition shadow-sm text-sm flex items-center gap-2 disabled:opacity-50"
          >
            {isProcessing ? <LoaderCircle size={16} className="animate-spin" /> : <CheckCircle2 size={16} />} Close Month
          </button>
          {totalDue === 0 && (
            <button
              disabled={isProcessing}
              onClick={() => handleAction(async () => await recalculateOpenMonths(monthId))}
              className="px-4 py-2 border border-border bg-background hover:bg-muted font-semibold rounded-lg transition text-sm flex items-center gap-2 disabled:opacity-50"
              title="Recalculate balances from utilities & expenses"
            >
              {isProcessing ? <LoaderCircle size={16} className="animate-spin" /> : <Activity size={16} />} Recalculate
            </button>
          )}
          <DeleteMonthButton monthId={monthId} deleteAction={async (id) => handleAction(async () => {
            const { deleteMonth } = await import("@/app/actions/rent");
            await deleteMonth(id);
          })} />
        </>
      )}
    </div>
  );
}
