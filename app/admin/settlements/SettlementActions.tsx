"use client";

import React, { useState } from "react";
import { Check, ShieldAlert, LoaderCircle } from "lucide-react";
import { settleDebt, cancelDebt } from "@/app/actions/settlements";

export default function SettlementActions({ debtId, remaining }: { debtId: string, remaining: number }) {
  const [isSettling, setIsSettling] = useState(false);
  const [isCanceling, setIsCanceling] = useState(false);

  const handleSettle = async () => {
    setIsSettling(true);
    try {
      await settleDebt(debtId, remaining, "Cash/UPI");
    } catch (e: any) {
      alert(e.message);
    } finally {
      setIsSettling(false);
    }
  };

  const handleCancel = async () => {
    if (!confirm("Are you sure you want to cancel this debt?")) return;
    setIsCanceling(true);
    try {
      await cancelDebt(debtId);
    } catch (e: any) {
      alert(e.message);
    } finally {
      setIsCanceling(false);
    }
  };

  return (
    <div className="flex flex-col gap-2 min-w-[120px]">
      <button 
        onClick={handleSettle}
        disabled={isSettling || isCanceling}
        className="w-full px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-semibold rounded-lg shadow-sm transition flex items-center justify-center gap-1.5 disabled:opacity-50"
      >
        {isSettling ? <LoaderCircle size={14} className="animate-spin" /> : <Check size={14} />} Full Settle
      </button>
      <button 
        onClick={handleCancel}
        disabled={isSettling || isCanceling}
        className="w-full px-4 py-2 border border-destructive/20 text-destructive bg-destructive/5 hover:bg-destructive/10 text-xs font-semibold rounded-lg transition flex items-center justify-center gap-1.5 disabled:opacity-50"
      >
        {isCanceling ? <LoaderCircle size={14} className="animate-spin" /> : <ShieldAlert size={14} />} Cancel
      </button>
    </div>
  );
}
