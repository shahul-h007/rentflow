import React from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const navItems = [
    { name: "Dashboard", href: "/admin" },
    { name: "Members", href: "/admin/members" },
    { name: "Logs", href: "/admin/logs" },
    { name: "Settings", href: "/admin/settings" },
  ];

  return (
    <div className="min-h-screen flex flex-col bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100">
      <header className="bg-white dark:bg-gray-800 shadow-md p-4 flex justify-between items-center">
        <h1 className="text-2xl font-bold">RentFlow Admin Panel</h1>
        <Link href="/" className="text-blue-600 dark:text-blue-400 hover:underline">
          Back to App
        </Link>
      </header>
      <div className="flex flex-1">
        <aside className="w-64 bg-gray-200 dark:bg-gray-800 p-4 space-y-2">
          {navItems.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className={`block px-3 py-2 rounded ${pathname.startsWith(item.href) ? "bg-blue-600 text-white" : "text-gray-800 dark:text-gray-200 hover:bg-gray-300 dark:hover:bg-gray-700"}`}
            >
              {item.name}
            </Link>
          ))}
        </aside>
        <main className="flex-1 p-6 overflow-auto">{children}</main>
      </div>
    </div>
  );
}
