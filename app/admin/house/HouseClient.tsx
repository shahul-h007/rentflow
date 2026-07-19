"use client";

import React, { useState } from "react";
import { Edit2, Archive, ShieldAlert, Image as ImageIcon, LoaderCircle } from "lucide-react";
import { updateHouseDetails, updateHouseOwner, archiveHouse } from "@/app/actions/house";

export default function HouseClient({ house }: { house: any }) {
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  const [isTransferModalOpen, setIsTransferModalOpen] = useState(false);
  const [loading, setLoading] = useState(false);

  // Form states - House Details
  const [name, setName] = useState(house.name);
  const [rent, setRent] = useState(house.rent.toString());
  const [dueDate, setDueDate] = useState(house.dueDate.toString());
  const [currency, setCurrency] = useState(house.currency);

  // Form states - Ownership
  const [ownerName, setOwnerName] = useState(house.ownerName || "");
  const [upiId, setUpiId] = useState(house.upiId || "");

  const handleEditSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    await updateHouseDetails({ name, rent: parseInt(rent), dueDate: parseInt(dueDate), currency });
    setLoading(false);
    setIsEditModalOpen(false);
  };

  const handleTransferSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    await updateHouseOwner({ ownerName, upiId });
    setLoading(false);
    setIsTransferModalOpen(false);
  };

  const handleArchive = async () => {
    if (confirm("Are you absolutely sure you want to archive this house? This action is logged.")) {
      setLoading(true);
      await archiveHouse();
      setLoading(false);
      alert("House has been archived.");
    }
  };

  return (
    <div className="space-y-8 animate-in fade-in duration-500 max-w-4xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground">House Management</h1>
          <p className="text-muted-foreground mt-1">
            View and update your property details.
          </p>
        </div>
        <div className="flex gap-2">
          <button onClick={() => setIsEditModalOpen(true)} className="px-4 py-2 bg-primary text-primary-foreground font-semibold rounded-lg hover:bg-primary/90 transition shadow-sm text-sm flex items-center gap-2">
            <Edit2 size={16} /> Edit Details
          </button>
        </div>
      </div>

      <div className="bg-card border border-border rounded-2xl shadow-soft overflow-hidden">
        {/* Cover Photo Area */}
        <div className="h-48 bg-muted relative border-b border-border">
          {house.photoUrl ? (
            <img src={house.photoUrl} alt="House Cover" className="w-full h-full object-cover" />
          ) : (
            <div className="w-full h-full flex flex-col items-center justify-center text-muted-foreground">
              <ImageIcon size={48} className="mb-2 opacity-50" />
              <p className="text-sm font-medium">No cover photo uploaded</p>
            </div>
          )}
        </div>

        {/* Details Form/View */}
        <div className="p-6 md:p-8 space-y-8">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            <div className="space-y-4">
              <div>
                <label className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">House Name</label>
                <p className="text-lg font-semibold text-foreground mt-1">{house.name}</p>
              </div>

              <div>
                <label className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">House ID</label>
                <p className="text-base text-muted-foreground mt-1 text-sm font-mono">{house.id}</p>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Monthly Rent</label>
                  <p className="text-base font-numeric-data font-bold text-foreground mt-1">{house.currency} {house.rent.toLocaleString()}</p>
                </div>
                <div>
                  <label className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Due Date</label>
                  <p className="text-base font-numeric-data font-medium text-foreground mt-1">{house.dueDate}th of month</p>
                </div>
              </div>
            </div>

            <div className="space-y-4">
              <div>
                <label className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Owner Name</label>
                <p className="text-base font-medium text-foreground mt-1">{house.ownerName || "Not set"}</p>
              </div>

              <div>
                <label className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Owner UPI ID</label>
                <p className="text-base font-medium text-primary mt-1">{house.upiId || "Not set"}</p>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Created On</label>
                  <p className="text-base font-numeric-data font-medium text-foreground mt-1">{new Date(house.createdAt).toLocaleDateString()}</p>
                </div>
                <div>
                  <label className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Last Updated</label>
                  <p className="text-base font-numeric-data font-medium text-foreground mt-1">{new Date(house.updatedAt).toLocaleDateString()}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <button onClick={() => setIsTransferModalOpen(true)} className="p-6 bg-card border border-border rounded-2xl shadow-sm text-left flex items-start gap-4 hover:bg-muted/50 transition">
          <div className="p-3 bg-primary/10 text-primary rounded-xl">
            <ShieldAlert size={24} />
          </div>
          <div>
            <h3 className="font-semibold text-foreground">Transfer Ownership</h3>
            <p className="text-sm text-muted-foreground mt-1">Update owner details and UPI payments.</p>
          </div>
        </button>
        
        <button onClick={handleArchive} disabled={loading} className="p-6 bg-card border border-destructive/20 rounded-2xl shadow-sm text-left flex items-start gap-4 hover:bg-destructive/5 transition">
          <div className="p-3 bg-destructive/10 text-destructive rounded-xl">
            <Archive size={24} />
          </div>
          <div>
            <h3 className="font-semibold text-destructive">Archive House</h3>
            <p className="text-sm text-muted-foreground mt-1">Soft-delete this house record.</p>
          </div>
        </button>
      </div>

      {/* Edit Details Modal */}
      {isEditModalOpen && (
        <div className="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4">
          <div className="bg-card w-full max-w-md rounded-2xl shadow-xl overflow-hidden animate-in zoom-in-95 duration-200">
            <div className="p-6 border-b border-border">
              <h2 className="text-xl font-bold">Edit House Details</h2>
              <p className="text-sm text-muted-foreground mt-1">Update rent and scheduling.</p>
            </div>
            <form onSubmit={handleEditSubmit} className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-semibold mb-1.5">House Name</label>
                <input required value={name} onChange={e => setName(e.target.value)} type="text" className="w-full rounded-xl border border-input bg-background px-4 py-2.5 outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition" />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-semibold mb-1.5">Rent Amount</label>
                  <input required value={rent} onChange={e => setRent(e.target.value)} type="number" min="0" className="w-full rounded-xl border border-input bg-background px-4 py-2.5 outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition" />
                </div>
                <div>
                  <label className="block text-sm font-semibold mb-1.5">Currency</label>
                  <select required value={currency} onChange={e => setCurrency(e.target.value)} className="w-full rounded-xl border border-input bg-background px-4 py-2.5 outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition">
                    <option value="INR">INR (₹)</option>
                    <option value="USD">USD ($)</option>
                    <option value="EUR">EUR (€)</option>
                  </select>
                </div>
              </div>
              <div>
                <label className="block text-sm font-semibold mb-1.5">Due Date (Day of Month)</label>
                <input required value={dueDate} onChange={e => setDueDate(e.target.value)} type="number" min="1" max="28" className="w-full rounded-xl border border-input bg-background px-4 py-2.5 outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition" />
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

      {/* Transfer Ownership Modal */}
      {isTransferModalOpen && (
        <div className="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4">
          <div className="bg-card w-full max-w-md rounded-2xl shadow-xl overflow-hidden animate-in zoom-in-95 duration-200">
            <div className="p-6 border-b border-border">
              <h2 className="text-xl font-bold">Transfer Ownership</h2>
              <p className="text-sm text-muted-foreground mt-1">Update owner name and payment UPI.</p>
            </div>
            <form onSubmit={handleTransferSubmit} className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-semibold mb-1.5">New Owner Name</label>
                <input required value={ownerName} onChange={e => setOwnerName(e.target.value)} type="text" className="w-full rounded-xl border border-input bg-background px-4 py-2.5 outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition" />
              </div>
              <div>
                <label className="block text-sm font-semibold mb-1.5">New Owner UPI ID</label>
                <input required value={upiId} onChange={e => setUpiId(e.target.value)} type="text" className="w-full rounded-xl border border-input bg-background px-4 py-2.5 outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition" placeholder="example@upi" />
              </div>
              <div className="pt-4 flex gap-3 justify-end">
                <button type="button" onClick={() => setIsTransferModalOpen(false)} className="px-4 py-2 rounded-lg font-medium hover:bg-muted transition text-foreground">Cancel</button>
                <button type="submit" disabled={loading} className="px-4 py-2 rounded-lg font-medium bg-primary text-primary-foreground hover:bg-primary/90 transition flex items-center gap-2">
                  {loading && <LoaderCircle size={16} className="animate-spin" />} Save Ownership
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
