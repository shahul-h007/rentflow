"use client";

import React, { useState } from "react";
import { Plus, Shield, UserX, Mail, Edit2, CheckCircle2, AlertTriangle, LoaderCircle, Trash2, Key } from "lucide-react";
import { addMember, updateMember, toggleMemberStatus, deleteMember, resetMemberPassword } from "@/app/actions/members";

export default function MembersClient({ members }: { members: any[] }) {
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  const [currentMember, setCurrentMember] = useState<any>(null);
  const [loading, setLoading] = useState(false);
  const [generatedCredentials, setGeneratedCredentials] = useState<{email: string, password: string} | null>(null);

  // Form states
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");

  const handleOpenAdd = () => {
    setName("");
    setEmail("");
    setPhone("");
    setIsAddModalOpen(true);
  };

  const handleOpenEdit = (m: any) => {
    setCurrentMember(m);
    setName(m.name);
    setEmail(m.email || "");
    setPhone(m.phone || "");
    setIsEditModalOpen(true);
  };

  const handleAddSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email) {
      alert("An email is required to automatically provision their app login.");
      return;
    }
    setLoading(true);
    try {
      const res = await addMember({ name, email, phone, role: "MEMBER" });
      if (res?.success && res?.password) {
        setGeneratedCredentials({ email, password: res.password });
      }
      setIsAddModalOpen(false);
    } catch (err: any) {
      alert(err.message || "Failed to add member");
    } finally {
      setLoading(false);
    }
  };

  const handleEditSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    await updateMember(currentMember.id, { name, email, phone });
    setLoading(false);
    setIsEditModalOpen(false);
  };

  const handleDelete = async (id: string, name: string) => {
    if (confirm(`Are you absolutely sure you want to completely delete ${name} from the database? This cannot be undone.`)) {
      try {
        await deleteMember(id);
      } catch (err: any) {
        alert(err.message);
      }
    }
  };

  const handleResetPassword = async (id: string, name: string) => {
    if (confirm(`Do you want to generate/reset the app login password for ${name}?`)) {
      setLoading(true);
      try {
        const res = await resetMemberPassword(id);
        if (res?.success && res?.password) {
          setGeneratedCredentials({ email: res.email, password: res.password });
        }
      } catch (err: any) {
        alert(err.message);
      } finally {
        setLoading(false);
      }
    }
  };

  const handleToggleStatus = async (id: string, active: boolean) => {
    if (confirm(`Are you sure you want to ${active ? 'deactivate' : 'reactivate'} this member?`)) {
      await toggleMemberStatus(id, active);
    }
  };

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground">Members</h1>
          <p className="text-muted-foreground mt-1">
            Manage house residents and statuses.
          </p>
        </div>
        <div className="flex gap-2">
          <button onClick={handleOpenAdd} className="px-4 py-2 bg-primary text-primary-foreground font-semibold rounded-lg hover:bg-primary/90 transition shadow-sm text-sm flex items-center gap-2">
            <Plus size={16} /> Add Member
          </button>
        </div>
      </div>

      <div className="bg-card border border-border rounded-2xl shadow-soft overflow-hidden flex flex-col">
        <div className="p-4 border-b border-border flex items-center justify-between gap-4 bg-muted/20">
          <div className="text-sm text-muted-foreground font-medium px-2">
            {members.length} total member(s)
          </div>
        </div>
        
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse min-w-[800px]">
            <thead>
              <tr className="border-b border-border bg-muted/30">
                <th className="py-4 px-6 text-xs font-semibold text-muted-foreground uppercase tracking-wider">Member</th>
                <th className="py-4 px-6 text-xs font-semibold text-muted-foreground uppercase tracking-wider">Contact</th>
                <th className="py-4 px-6 text-xs font-semibold text-muted-foreground uppercase tracking-wider">Join Date</th>
                <th className="py-4 px-6 text-xs font-semibold text-muted-foreground uppercase tracking-wider">Status</th>
                <th className="py-4 px-6 text-xs font-semibold text-muted-foreground uppercase tracking-wider text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {members.length === 0 ? (
                <tr>
                  <td colSpan={5} className="py-12 text-center text-muted-foreground">
                    No members found.
                  </td>
                </tr>
              ) : (
                members.map((member) => (
                  <tr key={member.id} className={`hover:bg-muted/30 transition-colors ${!member.active && 'opacity-60'}`}>
                    <td className="py-4 px-6">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center text-primary font-bold shadow-sm">
                          {member.name.charAt(0)}
                        </div>
                        <div className="font-medium text-foreground">{member.name}</div>
                      </div>
                    </td>
                    <td className="py-4 px-6">
                      <div className="flex flex-col gap-1">
                        <span className="text-sm font-numeric-data">{member.phone || "N/A"}</span>
                        <span className="text-xs text-muted-foreground">{member.email || "No email"}</span>
                      </div>
                    </td>
                    <td className="py-4 px-6 text-sm text-muted-foreground font-numeric-data">
                      {new Date(member.joinedAt).toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" })}
                    </td>
                    <td className="py-4 px-6">
                      <span className={`inline-flex px-2.5 py-1 rounded-full text-xs font-semibold ${
                        member.active
                          ? "bg-emerald-500/10 text-emerald-600"
                          : "bg-destructive/10 text-destructive"
                      }`}>
                        {member.active ? "Active" : "Inactive"}
                      </span>
                    </td>
                    <td className="py-4 px-6 text-right">
                      <div className="flex items-center justify-end gap-2">
                        <button onClick={() => handleOpenEdit(member)} className="p-1.5 text-muted-foreground hover:text-primary rounded-md hover:bg-muted transition" title="Edit details">
                          <Edit2 size={16} />
                        </button>
                        {member.email && (
                          <a href={`mailto:${member.email}`} className="p-1.5 text-muted-foreground hover:text-blue-500 rounded-md hover:bg-muted transition" title="Send email">
                            <Mail size={16} />
                          </a>
                        )}
                        <button onClick={() => handleToggleStatus(member.id, member.active)} className="p-1.5 text-muted-foreground hover:text-destructive rounded-md hover:bg-muted transition" title={member.active ? "Deactivate" : "Reactivate"}>
                          {member.active ? <UserX size={16} /> : <CheckCircle2 size={16} />}
                        </button>
                        <button onClick={() => handleResetPassword(member.id, member.name)} className="p-1.5 text-muted-foreground hover:text-amber-500 rounded-md hover:bg-muted transition" title="Reset/Generate App Password">
                          <Key size={16} />
                        </button>
                        <button onClick={() => handleDelete(member.id, member.name)} className="p-1.5 text-muted-foreground hover:text-red-600 rounded-md hover:bg-muted transition" title="Delete member">
                          <Trash2 size={16} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Add Member Modal */}
      {isAddModalOpen && (
        <div className="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4">
          <div className="bg-card w-full max-w-md rounded-2xl shadow-xl overflow-hidden animate-in zoom-in-95 duration-200">
            <div className="p-6 border-b border-border">
              <h2 className="text-xl font-bold">Add New Member</h2>
              <p className="text-sm text-muted-foreground mt-1">Add a resident to your house.</p>
            </div>
            <form onSubmit={handleAddSubmit} className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-semibold mb-1.5">Full Name</label>
                <input required value={name} onChange={e => setName(e.target.value)} type="text" className="w-full rounded-xl border border-input bg-background px-4 py-2.5 outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition" placeholder="John Doe" />
              </div>
              <div>
                <label className="block text-sm font-semibold mb-1.5">Email (Optional)</label>
                <input value={email} onChange={e => setEmail(e.target.value)} type="email" className="w-full rounded-xl border border-input bg-background px-4 py-2.5 outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition" placeholder="john@example.com" />
              </div>
              <div>
                <label className="block text-sm font-semibold mb-1.5">Phone (Optional)</label>
                <input value={phone} onChange={e => setPhone(e.target.value)} type="text" className="w-full rounded-xl border border-input bg-background px-4 py-2.5 outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition" placeholder="+91 9876543210" />
              </div>
              <div className="pt-4 flex gap-3 justify-end">
                <button type="button" onClick={() => setIsAddModalOpen(false)} className="px-4 py-2 rounded-lg font-medium hover:bg-muted transition text-foreground">Cancel</button>
                <button type="submit" disabled={loading} className="px-4 py-2 rounded-lg font-medium bg-primary text-primary-foreground hover:bg-primary/90 transition flex items-center gap-2">
                  {loading && <LoaderCircle size={16} className="animate-spin" />} Save Member
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Edit Member Modal */}
      {isEditModalOpen && (
        <div className="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4">
          <div className="bg-card w-full max-w-md rounded-2xl shadow-xl overflow-hidden animate-in zoom-in-95 duration-200">
            <div className="p-6 border-b border-border">
              <h2 className="text-xl font-bold">Edit Member</h2>
              <p className="text-sm text-muted-foreground mt-1">Update details for {currentMember?.name}</p>
            </div>
            <form onSubmit={handleEditSubmit} className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-semibold mb-1.5">Full Name</label>
                <input required value={name} onChange={e => setName(e.target.value)} type="text" className="w-full rounded-xl border border-input bg-background px-4 py-2.5 outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition" />
              </div>
              <div>
                <label className="block text-sm font-semibold mb-1.5">Email (Optional)</label>
                <input value={email} onChange={e => setEmail(e.target.value)} type="email" className="w-full rounded-xl border border-input bg-background px-4 py-2.5 outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition" />
              </div>
              <div>
                <label className="block text-sm font-semibold mb-1.5">Phone (Optional)</label>
                <input value={phone} onChange={e => setPhone(e.target.value)} type="text" className="w-full rounded-xl border border-input bg-background px-4 py-2.5 outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition" />
              </div>
              <div className="pt-4 flex gap-3 justify-end">
                <button type="button" onClick={() => setIsEditModalOpen(false)} className="px-4 py-2 rounded-lg font-medium hover:bg-muted transition text-foreground">Cancel</button>
                <button type="submit" disabled={loading} className="px-4 py-2 rounded-lg font-medium bg-primary text-primary-foreground hover:bg-primary/90 transition flex items-center gap-2">
                  {loading && <LoaderCircle size={16} className="animate-spin" />} Save Changes
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Generated Credentials Modal */}
      {generatedCredentials && (
        <div className="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4">
          <div className="bg-card w-full max-w-md rounded-2xl shadow-xl overflow-hidden animate-in zoom-in-95 duration-200 border-2 border-emerald-500/20">
            <div className="p-6 border-b border-border bg-emerald-500/5 flex items-center gap-3">
              <div className="p-2 bg-emerald-500 text-white rounded-full">
                <CheckCircle2 size={24} />
              </div>
              <div>
                <h2 className="text-xl font-bold text-emerald-700">Account Created!</h2>
                <p className="text-sm text-muted-foreground mt-0.5">They can now log into the mobile app.</p>
              </div>
            </div>
            <div className="p-6 space-y-4">
              <div className="bg-muted/30 p-4 rounded-xl border border-border">
                <label className="block text-xs font-semibold text-muted-foreground uppercase tracking-wider mb-1">Login Email</label>
                <div className="font-mono text-sm font-medium text-foreground mb-4 select-all">{generatedCredentials.email}</div>
                
                <label className="block text-xs font-semibold text-muted-foreground uppercase tracking-wider mb-1">Temporary Password</label>
                <div className="font-mono text-lg font-bold text-emerald-600 select-all">{generatedCredentials.password}</div>
              </div>
              <p className="text-xs text-muted-foreground text-center">
                Copy and send these credentials to the member via WhatsApp. They can change their password later in the app.
              </p>
              <div className="pt-2">
                <button 
                  onClick={() => setGeneratedCredentials(null)} 
                  className="w-full px-4 py-3 rounded-lg font-bold bg-emerald-500 text-white hover:bg-emerald-600 transition shadow-sm"
                >
                  Done
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
