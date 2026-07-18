import React from "react";
import Link from "next/link";

interface AdminTableProps<T> {
  data: T[];
  columns: { header: string; accessor: keyof T }[];
  onEdit?: (item: T) => void;
  onDelete?: (item: T) => void;
}

export function AdminTable<T extends Record<string, any>>({
  data,
  columns,
  onEdit,
  onDelete,
}: AdminTableProps<T>) {
  return (
    <div className="overflow-x-auto rounded-lg shadow">
      <table className="min-w-full bg-white dark:bg-gray-800">
        <thead className="bg-gray-100 dark:bg-gray-700">
          <tr>
            {columns.map((col) => (
              <th
                key={String(col.accessor)}
                className="px-4 py-2 text-left font-medium text-gray-700 dark:text-gray-200"
              >
                {col.header}
              </th>
            ))}
            {(onEdit || onDelete) && (
              <th className="px-4 py-2 text-left font-medium text-gray-700 dark:text-gray-200">
                Actions
              </th>
            )}
          </tr>
        </thead>
        <tbody>
          {data.map((row, i) => (
            <tr
              key={i}
              className="border-b border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-700 transition"
            >
              {columns.map((col) => (
                <td key={String(col.accessor)} className="px-4 py-2 text-gray-800 dark:text-gray-300">
                  {String(row[col.accessor])}
                </td>
              ))}
              {(onEdit || onDelete) && (
                <td className="px-4 py-2 space-x-2">
                  {onEdit && (
                    <button
                      onClick={() => onEdit(row)}
                      className="px-2 py-1 bg-blue-600 text-white rounded hover:bg-blue-700 transition"
                    >
                      Edit
                    </button>
                  )}
                  {onDelete && (
                    <button
                      onClick={() => onDelete(row)}
                      className="px-2 py-1 bg-red-600 text-white rounded hover:bg-red-700 transition"
                    >
                      Delete
                    </button>
                  )}
                </td>
              )}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
