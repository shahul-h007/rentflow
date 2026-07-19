import React from "react";
import { Loader2 } from "lucide-react";

export default function AdminLoading() {
  return (
    <div className="w-full h-[60vh] flex flex-col items-center justify-center text-muted-foreground animate-in fade-in duration-500">
      <Loader2 className="h-10 w-10 animate-spin text-primary mb-4" />
      <p className="text-sm font-medium">Loading...</p>
    </div>
  );
}
