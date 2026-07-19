"use client";

import React, { useState } from "react";
import { Check, X, LoaderCircle } from "lucide-react";
import { confirmPayment, rejectPayment } from "@/app/actions/payments";

export default function PaymentActions({ txId }: { txId: string }) {
  const [isConfirming, setIsConfirming] = useState(false);
  const [isRejecting, setIsRejecting] = useState(false);

  const handleConfirm = async () => {
    setIsConfirming(true);
    try {
      await confirmPayment(txId);
    } catch (e: any) {
      alert(e.message);
    } finally {
      setIsConfirming(false);
    }
  };

  const handleReject = async () => {
    if (!confirm("Are you sure you want to reject this payment?")) return;
    setIsRejecting(true);
    try {
      await rejectPayment(txId);
    } catch (e: any) {
      alert(e.message);
    } finally {
      setIsRejecting(false);
    }
  };

  return (
    <div className="flex items-center gap-3 w-full md:w-auto">
      <button 
        onClick={handleConfirm}
        disabled={isConfirming || isRejecting}
        className="flex-1 md:flex-none px-5 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white font-semibold rounded-lg shadow-sm transition active:scale-95 flex items-center justify-center gap-2 disabled:opacity-50"
      >
        {isConfirming ? <LoaderCircle size={18} className="animate-spin" /> : <Check size={18} />} Confirm
      </button>
      <button 
        onClick={handleReject}
        disabled={isConfirming || isRejecting}
        className="flex-1 md:flex-none px-5 py-2.5 border border-destructive/30 text-destructive bg-destructive/5 hover:bg-destructive/10 font-semibold rounded-lg transition active:scale-95 flex items-center justify-center gap-2 disabled:opacity-50"
      >
        {isRejecting ? <LoaderCircle size={18} className="animate-spin" /> : <X size={18} />} Reject
      </button>
    </div>
  );
}
