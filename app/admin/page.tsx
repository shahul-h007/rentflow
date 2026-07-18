import React from "react";
import Link from "next/link";
import { prisma } from "@/lib/prisma"; // ensure prisma client is exported

export const dynamic = "force-dynamic"; // always fetch latest stats

export default async function AdminHome() {
  // Fetch some quick stats (users, pending approvals, recent logs)
  const totalUsers = await prisma.user.count();
  const totalMembers = await prisma.member.count();
  const pending = await prisma.$queryRaw<Array<{ email: string }>`
    SELECT DISTINCT u.email
    FROM "User" u
    LEFT JOIN "Member" m ON u.email = m.email
    WHERE m.id IS NULL
  `;

  const recentLogs = await prisma.activityLog.findMany({
    orderBy: { createdAt: "desc" },
    take: 5,
  });

  return (
    <section className="space-y-6">
      <h1 className="text-3xl font-bold">Dashboard</h1>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <StatCard title="Total Users" value={totalUsers} />
        <StatCard title="Members (Approved)" value={totalMembers} />
        <StatCard title="Pending Approvals" value={pending.length} />
      </div>

      <div>
        <h2 className="text-2xl font-semibold mb-2">Recent Activity</h2>
        <ul className="space-y-2">
          {recentLogs.map((log) => (
            <li key={log.id} className="bg-white dark:bg-gray-800 p-3 rounded shadow">
              <span className="font-medium">{log.action}</span> by user ID {log.actorId} at {new Date(log.createdAt).toLocaleString()}
            </li>
          ))}
        </ul>
        <Link href="/admin/logs" className="text-blue-600 hover:underline mt-2 inline-block">
          View all logs →
        </Link>
      </div>
    </section>
  );
}

function StatCard({ title, value }: { title: string; value: number }) {
  return (
    <div className="bg-white dark:bg-gray-800 p-4 rounded-lg shadow text-center">
      <p className="text-gray-600 dark:text-gray-400">{title}</p>
      <p className="text-3xl font-bold text-gray-800 dark:text-gray-100">{value}</p>
    </div>
  );
}
