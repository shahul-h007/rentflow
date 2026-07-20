import React from "react";
import prisma from "@/lib/prisma";
import HouseClient from "./HouseClient";

export const dynamic = "force-dynamic";

export default async function HouseManagement() {
  const house = await prisma.house.findFirst();

  if (!house) {
    return (
      <div className="p-12 text-center text-muted-foreground bg-card border border-border rounded-2xl max-w-md mx-auto mt-12">
        <h2 className="text-xl font-bold mb-2 text-foreground">No House Configured</h2>
        <p className="mb-6 text-sm">You need to create a house in the database before you can manage rent and members.</p>
        <form action={async (formData: FormData) => {
          "use server";
          const { createHouse } = await import("@/app/actions/house");
          await createHouse({
            name: formData.get("name") as string,
            rent: Number(formData.get("rent")),
            dueDate: Number(formData.get("dueDate")),
            currency: "INR"
          });
        }} className="flex flex-col gap-4 text-left">
          <div>
            <label className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">House Name</label>
            <input name="name" type="text" required defaultValue="RentFlow House" className="w-full p-2 border rounded-lg mt-1" />
          </div>
          <div>
            <label className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">Monthly Rent (Total)</label>
            <input name="rent" type="number" required defaultValue="25000" className="w-full p-2 border rounded-lg mt-1" />
          </div>
          <div>
            <label className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">Due Date (Day of Month)</label>
            <input name="dueDate" type="number" required defaultValue="5" min="1" max="28" className="w-full p-2 border rounded-lg mt-1" />
          </div>
          <button type="submit" className="w-full bg-primary text-primary-foreground py-2.5 rounded-lg font-bold mt-2 hover:bg-primary/90 transition">
            Create House
          </button>
        </form>
      </div>
    );
  }

  return <HouseClient house={JSON.parse(JSON.stringify(house))} />;
}
