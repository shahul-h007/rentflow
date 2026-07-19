import { requireAdminHouseAccess } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import UtilitiesClient from "./UtilitiesClient";

export const metadata = {
  title: "Utilities - Admin",
};

export default async function UtilitiesPage() {
  const { house } = await requireAdminHouseAccess();

  // Fetch current open month
  const openMonth = await prisma.month.findFirst({
    where: { houseId: house.id, status: "OPEN" },
    include: {
      utilities: {
        include: { paidBy: true, payments: { include: { member: true } } },
        orderBy: { createdAt: "desc" }
      }
    }
  });

  // Fetch active members
  const members = await prisma.member.findMany({
    where: { houseId: house.id, active: true },
    orderBy: { name: "asc" }
  });

  return (
    <div className="p-6">
      <div className="flex flex-col gap-6 max-w-5xl mx-auto">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground">Utilities</h1>
          <p className="text-muted-foreground mt-2">
            Manage recurring house bills (Electricity, Water, Internet) and automatically split them among members.
          </p>
        </div>

        {!openMonth ? (
          <div className="p-12 text-center text-muted-foreground bg-card border border-border rounded-2xl">
            <h2 className="text-xl font-bold mb-2 text-foreground">No Active Month</h2>
            <p>You need to generate rent for the current month before adding utility bills.</p>
          </div>
        ) : (
          <UtilitiesClient month={openMonth} members={members} />
        )}
      </div>
    </div>
  );
}
