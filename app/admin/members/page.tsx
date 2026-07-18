import React, { useEffect, useState } from "react";
import { AdminTable } from "@/components/AdminTable";
import { ConfirmModal } from "@/components/ConfirmModal";
import { Toast } from "@/components/Toast";
import { LoadingSpinner } from "@/components/LoadingSpinner";
import { prisma } from "@/lib/prisma";

export const dynamic = "force-dynamic";

interface Member {
  id: string;
  email: string;
  name?: string | null;
  role: string;
  createdAt: string;
}

export default function MembersPage() {
  const [members, setMembers] = useState<Member[]>([]);
  const [pending, setPending] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);
  const [toast, setToast] = useState<{msg:string;type?:"success"|"error"}>();
  const [confirm, setConfirm] = useState<{open:boolean;email:string}>({open:false,email:""});

  useEffect(() => {
    async function fetchData() {
      setLoading(true);
      try {
        const resMembers = await fetch("/api/admin/members");
        const dataMembers = await resMembers.json();
        setMembers(dataMembers.members);

        const resPending = await fetch("/api/admin/members?pending=true");
        const dataPending = await resPending.json();
        setPending(dataPending.emails);
      } catch (e) {
        console.error(e);
        setToast({msg:"Failed to load data",type:"error"});
      } finally {
        setLoading(false);
      }
    }
    fetchData();
  }, []);

  const approve = async (email: string) => {
    try {
      const res = await fetch("/api/admin/approve", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email }),
      });
      if (res.ok) {
        setToast({msg:`${email} approved`,type:"success"});
        setPending(pending.filter((e) => e !== email));
        // refresh members list
        const r = await fetch("/api/admin/members");
        const d = await r.json();
        setMembers(d.members);
      } else {
        const err = await res.json();
        setToast({msg:err.error||"Approve failed",type:"error"});
      }
    } catch (e) {
      setToast({msg:"Approve request error",type:"error"});
    }
  };

  const reject = async (email: string) => {
    try {
      const res = await fetch("/api/admin/reject", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email }),
      });
      if (res.ok) {
        setToast({msg:`${email} rejected`,type:"success"});
        setPending(pending.filter((e) => e !== email));
      } else {
        const err = await res.json();
        setToast({msg:err.error||"Reject failed",type:"error"});
      }
    } catch (e) {
      setToast({msg:"Reject request error",type:"error"});
    }
  };

  const columns = [
    { header: "Email", accessor: "email" as const },
    { header: "Name", accessor: "name" as const },
    { header: "Role", accessor: "role" as const },
    { header: "Created At", accessor: "createdAt" as const },
  ];

  return (
    <section className="space-y-6">
      <h1 className="text-3xl font-bold">Members Management</h1>
      {loading && <LoadingSpinner />}
      {toast && <Toast message={toast.msg} type={toast.type} onClose={() => setToast(undefined)} />}

      <div>
        <h2 className="text-2xl font-semibold mb-3">Approved Members</h2>
        <AdminTable data={members} columns={columns} />
      </div>

      <div>
        <h2 className="text-2xl font-semibold mb-3">Pending Approvals</h2>
        {pending.length === 0 ? (
          <p className="text-gray-600 dark:text-gray-300">No pending approvals.</p>
        ) : (
          <ul className="space-y-2">
            {pending.map((email) => (
              <li key={email} className="flex items-center justify-between bg-white dark:bg-gray-800 p-3 rounded shadow">
                <span>{email}</span>
                <div className="space-x-2">
                  <button
                    onClick={() => approve(email)}
                    className="px-3 py-1 bg-green-600 text-white rounded hover:bg-green-700"
                  >
                    Approve
                  </button>
                  <button
                    onClick={() => setConfirm({open:true,email})}
                    className="px-3 py-1 bg-red-600 text-white rounded hover:bg-red-700"
                  >
                    Reject
                  </button>
                </div>
              </li>
            ))}
          </ul>
        )}
      </div>

      <ConfirmModal
        open={confirm.open}
        title="Confirm Rejection"
        description={`Are you sure you want to reject ${confirm.email}? This will prevent the user from signing in.`}
        onCancel={() => setConfirm({open:false,email:""})}
        onConfirm={() => { reject(confirm.email); setConfirm({open:false,email:""}); }}
      />
    </section>
  );
}
