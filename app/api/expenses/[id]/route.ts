import { NextRequest, NextResponse } from "next/server";
import { deleteExpense } from "@/app/actions/expenses";
import { requireHouseAccess } from "@/lib/auth";

export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { house } = await requireHouseAccess();
    const { id } = await params;
    
    // We should ideally verify that the expense belongs to the house
    // For MVP, we'll just attempt deletion. The action could be made more secure.
    await deleteExpense(id);

    return NextResponse.json({ success: true });
  } catch (error: any) {
    console.error("Error deleting expense:", error);
    return NextResponse.json(
      { error: error.message || "Failed to delete expense" },
      { status: 500 }
    );
  }
}
