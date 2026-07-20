import { prisma } from '@/lib/prisma';
import Link from 'next/link';

export const metadata = {
  title: 'Food Splitter Admin | RentFlow',
};

export const dynamic = 'force-dynamic';

export default async function FoodSplitterAdminPage() {
  let receipts = [];
  let errorMessage = null;

  try {
    receipts = await prisma.receipt.findMany({
      orderBy: { createdAt: 'desc' },
      include: {
        scannedBy: { select: { name: true } },
        items: true,
      }
    });
  } catch (error: any) {
    errorMessage = error.message || String(error);
  }

  return (
    <div className="p-8">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold">Food Expenses Dashboard</h1>
        <Link href="/admin" className="text-blue-500 hover:underline">
          Back to Admin
        </Link>
      </div>

      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Merchant</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Scanned By</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Items</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Total (₹)</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {errorMessage ? (
              <tr>
                <td colSpan={6} className="px-6 py-4 text-center text-red-500 font-bold">
                  Error loading receipts: {errorMessage}
                </td>
              </tr>
            ) : receipts.length === 0 ? (
              <tr>
                <td colSpan={6} className="px-6 py-4 text-center text-gray-500">
                  No food receipts found.
                </td>
              </tr>
            ) : (
              receipts.map((receipt) => (
                <tr key={receipt.id}>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {new Date(receipt.createdAt).toLocaleDateString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {receipt.merchant || 'Unknown'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {receipt.scannedBy?.name || 'Unknown User'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {receipt.items?.length || 0} items
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 font-bold">
                    ₹{(receipt.grandTotal || 0).toFixed(2)}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-blue-500 hover:underline cursor-pointer">
                    View Details
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
