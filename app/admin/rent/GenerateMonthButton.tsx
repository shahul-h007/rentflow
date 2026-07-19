"use client";

import { useState } from "react";
import { PlayCircle, LoaderCircle } from "lucide-react";
import { generateMonthlyRent } from "@/app/actions/rent";

export default function GenerateMonthButton({ houseId }: { houseId: string }) {
  const [isGenerating, setIsGenerating] = useState(false);

  return (
    <button
      disabled={isGenerating}
      onClick={async () => {
        setIsGenerating(true);
        try {
          const d = new Date();
          await generateMonthlyRent(houseId, d);
        } catch (e: any) {
          alert(e.message);
        } finally {
          setIsGenerating(false);
        }
      }}
      className="px-4 py-2 bg-primary text-primary-foreground font-semibold rounded-lg hover:bg-primary/90 transition shadow-sm text-sm flex items-center gap-2 disabled:opacity-50"
    >
      {isGenerating ? <LoaderCircle size={16} className="animate-spin" /> : <PlayCircle size={16} />} 
      Generate New Month
    </button>
  );
}
