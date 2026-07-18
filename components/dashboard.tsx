"use client";

import { useEffect, useState, useMemo } from "react";
import {
  LayoutDashboard,
  Users,
  CreditCard,
  History as HistoryIcon,
  User as UserIcon,
  Check,
  X,
  Shield,
  Plus,
  ArrowRight,
  ArrowLeft,
  Copy,
  AlertCircle,
  Info,
  Loader2,
  RefreshCw,
  Bell,
  Home,
  DollarSign,
  Wallet,
  Calendar,
  CheckCircle2,
  XCircle,
  AlertTriangle
} from "lucide-react";
import { toast } from "sonner";

// Types mapping directly to our schema-aligned API payloads
type House = {
  id: string;
  name: string;
  rent: number;
  dueDate: number;
  currency: string;
  upiId: string;
  ownerName: string;
};

type Member = {
  id: string;
  name: string;
  email?: string | null;
  phone?: string | null;
  active: boolean;
};

type Transaction = {
  id: string;
  rentPaymentId: string;
  amount: number;
  method: string;
  reference?: string | null;
  status: "SUBMITTED" | "CONFIRMED" | "REJECTED";
  paidAt: string;
  verifiedAt?: string | null;
  payer?: Member | null;
  rentPayment?: {
    member: Member;
  } | null;
};

type RentPayment = {
  id: string;
  monthId: string;
  memberId: string;
  amountDue: number;
  amountPaid: number;
  carryForward: number;
  status: "PENDING" | "PAID" | "PARTIAL" | "WAIVED";
  method?: string | null;
  reference?: string | null;
  paidAt?: string | null;
  member: Member;
  transactions: Transaction[];
};

type Month = {
  id: string;
  startsOn: string;
  endsOn: string;
  rent: number;
  rentPayments: RentPayment[];
  utilities: any[];
  expenses: any[];
};

type Debt = {
  id: string;
  debtorId: string;
  creditorId: string;
  amount: number;
  settledAmount: number;
  reason: string;
  createdAt: string;
  status: "OPEN" | "SETTLED" | "CANCELLED";
  debtor: Member;
  creditor: Member;
};

type DashboardData = {
  configured: boolean;
  house?: House;
  account: {
    name: string;
    role: "ADMIN" | "MEMBER";
    memberId?: string;
  };
  month?: Month | null;
  members: Member[];
  debts: Debt[];
  pendingConfirmations?: Transaction[];
  recentActivity?: Transaction[];
};

export function Dashboard() {
  const [data, setData] = useState<DashboardData | null>(null);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<"home" | "members" | "payments" | "history" | "profile">("home");
  const [busy, setBusy] = useState(false);

  // Form states for House Setup
  const [setupName, setSetupName] = useState("");
  const [setupRent, setSetupRent] = useState("");
  const [setupDueDate, setSetupDueDate] = useState("5");
  const [setupCurrency, setSetupCurrency] = useState("INR");
  const [setupOwnerName, setSetupOwnerName] = useState("");
  const [setupOwnerUpi, setSetupOwnerUpi] = useState("");

  // Form states for Member Invite
  const [newMemberName, setNewMemberName] = useState("");
  const [newMemberPhone, setNewMemberPhone] = useState("");

  // Form states for Payment Submission
  const [payAmount, setPayAmount] = useState("");
  const [payTargetPaymentId, setPayTargetPaymentId] = useState("");
  const [payTargetMemberId, setPayTargetMemberId] = useState("");
  const [payMethod, setPayMethod] = useState("UPI");
  const [payReference, setPayReference] = useState("");
  const [payBehalf, setPayBehalf] = useState(false);

  // Load dashboard data
  const loadData = async () => {
    try {
      const res = await fetch("/api/dashboard");
      if (!res.ok) throw new Error("Failed to load dashboard metrics");
      const json = (await res.json()) as DashboardData;
      setData(json);

      // Prepopulate payment form amount and target payment record if member view
      if (json.configured && json.month && json.account.role === "MEMBER" && json.account.memberId) {
        const myPayment = json.month.rentPayments.find(
          (p) => p.memberId === json.account.memberId
        );
        if (myPayment) {
          setPayTargetPaymentId(myPayment.id);
          setPayTargetMemberId(myPayment.memberId);
          setPayAmount(String(myPayment.amountDue - myPayment.amountPaid));
        }
      }
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Unable to sync with live database");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  // Format currency wrapper
  const formatMoney = (amount: number) => {
    const currency = data?.house?.currency ?? "INR";
    return new Intl.NumberFormat("en-IN", {
      style: "currency",
      currency: currency,
      maximumFractionDigits: 0,
    }).format(amount);
  };

  // Submit House Setup
  const handleHouseSetup = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!setupName || !setupRent || !setupOwnerName || !setupOwnerUpi) {
      toast.error("Please fill in all setup fields");
      return;
    }
    setBusy(true);
    try {
      const res = await fetch("/api/house", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          name: setupName,
          rent: Number(setupRent),
          dueDate: Number(setupDueDate),
          currency: setupCurrency,
          ownerName: setupOwnerName,
          upiId: setupOwnerUpi,
        }),
      });
      const resJson = await res.json();
      if (!res.ok) throw new Error(resJson.error ?? "Failed to initialize house");
      toast.success(`House "${setupName}" configured successfully!`);
      await loadData();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Error establishing house");
    } finally {
      setBusy(false);
    }
  };

  // Submit Rent Payment Transaction
  const handlePaymentSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!payTargetPaymentId || !payAmount || !payMethod) {
      toast.error("Please fill in all transaction fields");
      return;
    }
    setBusy(true);
    try {
      // Find payerId depending on behalf toggle
      let payerId = data?.account.memberId;
      if (payBehalf && payTargetMemberId) {
        // If paying on behalf of someone else, we are the payer (account.memberId),
        // and the target payment record is the other member's payment.
        payerId = data?.account.memberId;
      }

      const res = await fetch("/api/rent-payments/transactions", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          rentPaymentId: payTargetPaymentId,
          amount: Number(payAmount),
          method: payMethod,
          reference: payReference,
          payerId: payerId,
        }),
      });
      const resJson = await res.json();
      if (!res.ok) throw new Error(resJson.error ?? "Failed to log transaction");
      toast.success("Rent payment submitted! Awaiting administrator verification.");
      setPayReference("");
      setActiveTab("home");
      await loadData();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Error submitting transaction");
    } finally {
      setBusy(false);
    }
  };

  // Add Member
  const handleAddMember = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newMemberName) {
      toast.error("Member name is required");
      return;
    }
    setBusy(true);
    try {
      const res = await fetch("/api/members", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          name: newMemberName,
          phone: newMemberPhone || undefined,
        }),
      });
      const resJson = await res.json();
      if (!res.ok) throw new Error(resJson.error ?? "Failed to create member");
      toast.success(`Member "${newMemberName}" added to the house!`);
      setNewMemberName("");
      setNewMemberPhone("");
      await loadData();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Error creating member");
    } finally {
      setBusy(false);
    }
  };

  // Confirm rent transaction
  const handleConfirmTransaction = async (txId: string, memberName: string) => {
    setBusy(true);
    try {
      const res = await fetch(`/api/rent-payments/transactions/${txId}/confirm`, {
        method: "POST",
      });
      const resJson = await res.json();
      if (!res.ok) throw new Error(resJson.error ?? "Verification failed");
      toast.success(`Verified and confirmed payment for ${memberName}!`);
      await loadData();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Verification failed");
    } finally {
      setBusy(false);
    }
  };

  // Reject rent transaction
  const handleRejectTransaction = async (txId: string, memberName: string) => {
    setBusy(true);
    try {
      const res = await fetch(`/api/rent-payments/transactions/${txId}/reject`, {
        method: "POST",
      });
      const resJson = await res.json();
      if (!res.ok) throw new Error(resJson.error ?? "Rejection failed");
      toast.warning(`Payment submission for ${memberName} was rejected.`);
      await loadData();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Rejection failed");
    } finally {
      setBusy(false);
    }
  };

  // Settle Debt / Settlement
  const handleSettleDebt = async (debtId: string, debtorName: string) => {
    setBusy(true);
    try {
      const res = await fetch(`/api/debts/${debtId}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ status: "SETTLED" }),
      });
      const resJson = await res.json();
      if (!res.ok) throw new Error(resJson.error ?? "Failed to complete settlement");
      toast.success(`Settlement with ${debtorName} marked as completed!`);
      await loadData();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Settlement failed");
    } finally {
      setBusy(false);
    }
  };

  // Calculations for Admin stats
  const adminStats = useMemo(() => {
    if (!data?.month) return { total: 0, collected: 0, pending: 0, progress: 0, paidCount: 0, totalCount: 0 };
    const total = data.month.rent;
    const collected = data.month.rentPayments.reduce((sum, p) => sum + p.amountPaid, 0);
    const pending = total - collected;
    const progress = total > 0 ? Math.round((collected / total) * 100) : 0;

    const totalCount = data.month.rentPayments.length;
    const paidCount = data.month.rentPayments.filter((p) => p.status === "PAID").length;

    return { total, collected, pending, progress, paidCount, totalCount };
  }, [data]);

  // Calculations for Member stats
  const memberStats = useMemo(() => {
    if (!data?.month || !data.account.memberId) return null;
    const myPayment = data.month.rentPayments.find(
      (p) => p.memberId === data.account.memberId
    );
    if (!myPayment) return null;

    const due = myPayment.amountDue;
    const paid = myPayment.amountPaid;
    const balance = due - paid;
    const progress = due > 0 ? Math.round((paid / due) * 100) : 0;
    const status = myPayment.status;

    return { due, paid, balance, progress, status, paymentId: myPayment.id };
  }, [data]);

  // Format Date string helper
  const formatDate = (dateStr: string) => {
    return new Date(dateStr).toLocaleDateString("en-IN", {
      month: "short",
      day: "numeric",
      year: "numeric",
    });
  };

  // Loading Screen
  if (loading) {
    return (
      <main className="grid min-h-screen place-items-center bg-background text-primary">
        <div className="text-center space-y-4">
          <Loader2 className="animate-spin mx-auto text-primary" size={48} />
          <p className="font-label-md text-label-md text-on-surface-variant">Connecting to live database...</p>
        </div>
      </main>
    );
  }

  // 1. HOUSE SETUP SCREEN
  if (!data?.configured) {
    return (
      <div className="bg-background text-on-surface min-h-screen flex flex-col font-body-md">
        <header className="bg-surface border-b border-outline-variant sticky top-0 z-40">
          <div className="flex items-center w-full px-lg max-w-container_max_width mx-auto h-16">
            <h1 className="font-headline-md text-headline-md font-bold text-primary">RentFlow</h1>
          </div>
        </header>
        <main className="flex-grow flex flex-col px-lg pt-lg pb-xl max-w-lg mx-auto w-full">
          <div className="flex flex-col gap-2 mb-xl">
            <div className="flex justify-between items-end">
              <span className="font-label-md text-label-md text-on-surface-variant">Step 1 of 1</span>
              <span className="font-label-md text-label-md text-primary font-bold">Initial Configuration</span>
            </div>
            <div className="w-full h-2 bg-surface-container-high rounded-full overflow-hidden">
              <div className="h-full bg-primary-container w-1/2 transition-all duration-500 ease-out"></div>
            </div>
          </div>
          <div className="mb-xl">
            <h2 className="font-headline-lg-mobile text-headline-lg-mobile text-on-surface mb-2">Setup Your House</h2>
            <p className="font-body-md text-body-md text-on-surface-variant">
              Create a digital ledger for your home to manage rents and shared settlements transparently.
            </p>
          </div>
          <form onSubmit={handleHouseSetup} className="flex flex-col gap-lg">
            <div className="flex flex-col gap-sm">
              <label className="font-label-md text-label-md text-on-surface-variant" htmlFor="house-name">
                House Name
              </label>
              <div className="relative">
                <span className="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-outline">
                  home
                </span>
                <input
                  required
                  className="w-full pl-12 pr-4 py-3 bg-surface border border-outline-variant rounded-xl font-body-md text-body-md"
                  id="house-name"
                  placeholder="e.g., Green Villa"
                  type="text"
                  value={setupName}
                  onChange={(e) => setSetupName(e.target.value)}
                />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-md">
              <div className="flex flex-col gap-sm">
                <label className="font-label-md text-label-md text-on-surface-variant" htmlFor="rent">
                  Monthly Rent
                </label>
                <div className="relative">
                  <span className="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-outline">
                    payments
                  </span>
                  <input
                    required
                    className="w-full pl-12 pr-4 py-3 bg-surface border border-outline-variant rounded-xl font-numeric-data text-body-md"
                    id="rent"
                    placeholder="30000"
                    type="number"
                    value={setupRent}
                    onChange={(e) => setSetupRent(e.target.value)}
                  />
                </div>
              </div>
              <div className="flex flex-col gap-sm">
                <label className="font-label-md text-label-md text-on-surface-variant" htmlFor="currency">
                  Currency
                </label>
                <div className="relative">
                  <select
                    className="w-full px-4 py-3 bg-surface border border-outline-variant rounded-xl font-body-md text-body-md appearance-none"
                    id="currency"
                    value={setupCurrency}
                    onChange={(e) => setSetupCurrency(e.target.value)}
                  >
                    <option value="INR">INR (₹)</option>
                    <option value="USD">USD ($)</option>
                    <option value="EUR">EUR (€)</option>
                  </select>
                  <span className="material-symbols-outlined absolute right-4 top-1/2 -translate-y-1/2 text-outline pointer-events-none">
                    expand_more
                  </span>
                </div>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-md">
              <div className="flex flex-col gap-sm">
                <label className="font-label-md text-label-md text-on-surface-variant" htmlFor="due-date">
                  Due Date (Day)
                </label>
                <div className="relative">
                  <select
                    className="w-full px-4 py-3 bg-surface border border-outline-variant rounded-xl font-body-md text-body-md appearance-none"
                    id="due-date"
                    value={setupDueDate}
                    onChange={(e) => setSetupDueDate(e.target.value)}
                  >
                    <option value="1">1st of month</option>
                    <option value="5">5th of month</option>
                    <option value="10">10th of month</option>
                    <option value="15">15th of month</option>
                    <option value="25">25th of month</option>
                  </select>
                  <span className="material-symbols-outlined absolute right-4 top-1/2 -translate-y-1/2 text-outline pointer-events-none">
                    calendar_today
                  </span>
                </div>
              </div>
            </div>
            <div className="bg-surface-container-lowest border border-outline-variant rounded-xl p-lg setup-card-shadow mt-2">
              <div className="flex items-center gap-sm mb-lg">
                <span className="material-symbols-outlined text-primary">admin_panel_settings</span>
                <h3 className="font-label-md text-label-md text-on-surface font-bold">Owner Payment Details</h3>
              </div>
              <div className="flex flex-col gap-lg">
                <div className="flex flex-col gap-sm">
                  <label className="font-label-md text-label-md text-on-surface-variant" htmlFor="owner-name">
                    Owner Name
                  </label>
                  <input
                    required
                    className="w-full px-4 py-3 bg-surface border border-outline-variant rounded-xl font-body-md text-body-md"
                    id="owner-name"
                    placeholder="e.g., Shahul"
                    type="text"
                    value={setupOwnerName}
                    onChange={(e) => setSetupOwnerName(e.target.value)}
                  />
                </div>
                <div className="flex flex-col gap-sm">
                  <label className="font-label-md text-label-md text-on-surface-variant" htmlFor="upi-id">
                    Owner UPI ID
                  </label>
                  <div className="relative">
                    <span className="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-outline">
                      qr_code_2
                    </span>
                    <input
                      required
                      className="w-full pl-12 pr-4 py-3 bg-surface border border-outline-variant rounded-xl font-body-md text-body-md"
                      id="upi-id"
                      placeholder="shahul@oksbi"
                      type="text"
                      value={setupOwnerUpi}
                      onChange={(e) => setSetupOwnerUpi(e.target.value)}
                    />
                  </div>
                </div>
              </div>
            </div>
            <div className="mt-xl pb-2xl">
              <button
                disabled={busy}
                className="w-full bg-primary-container hover:bg-emerald-600 text-on-primary-container font-bold py-4 rounded-xl shadow-lg active:scale-95 transition-all duration-150 flex items-center justify-center gap-2 disabled:opacity-50"
                type="submit"
              >
                {busy ? (
                  <>
                    <Loader2 className="animate-spin" size={20} />
                    <span>Setting up house...</span>
                  </>
                ) : (
                  <>
                    <span>Create House</span>
                    <span className="material-symbols-outlined">chevron_right</span>
                  </>
                )}
              </button>
              <p className="text-center font-label-sm text-label-sm text-outline mt-lg">
                By creating, you agree to RentFlow Terms & Policies.
              </p>
            </div>
          </form>
        </main>
      </div>
    );
  }

  // 2. MAIN CONFIGURED RENTFLOW INTERFACE
  const isAdmin = data.account.role === "ADMIN";
  const houseName = data.house?.name ?? "My House";

  return (
    <div className="bg-background text-on-surface min-h-screen flex flex-col font-body-md pb-24">
      {/* TopAppBar */}
      <header className="bg-surface sticky top-0 z-40 border-b border-outline-variant">
        <div className="flex justify-between items-center w-full px-lg h-16 max-w-container_max_width mx-auto">
          <div className="flex items-center gap-md">
            <span className="material-symbols-outlined text-primary text-2xl">account_balance_wallet</span>
            <h1 className="font-headline-md text-headline-md font-bold text-primary">{houseName}</h1>
          </div>
          <div className="relative">
            <button
              onClick={loadData}
              className="w-10 h-10 flex items-center justify-center rounded-full hover:bg-surface-container-low transition-colors active:scale-95 duration-150 text-on-surface-variant"
            >
              <RefreshCw size={18} className={busy ? "animate-spin" : ""} />
            </button>
          </div>
        </div>
      </header>

      {/* Main Tab content */}
      <main className="px-lg py-md space-y-lg flex-grow max-w-container_max_width mx-auto w-full">
        {/* HOME TAB */}
        {activeTab === "home" && (
          <div className="space-y-lg">
            {/* STATS HEADER: ADMIN VIEW */}
            {isAdmin ? (
              <>
                <section className="grid grid-cols-1 gap-md">
                  <div className="bg-surface-container-lowest border border-outline-variant p-lg rounded-xl shadow-sm relative">
                    <div className="flex justify-between items-start mb-sm">
                      <div>
                        <p className="font-label-md text-label-md text-on-surface-variant">Total Rent</p>
                        <h2 className="font-display-lg text-headline-lg font-bold text-on-surface">
                          {formatMoney(adminStats.total)}
                        </h2>
                      </div>
                      <div className="bg-primary-container/20 p-sm rounded-lg">
                        <span className="material-symbols-outlined text-primary">payments</span>
                      </div>
                    </div>
                    <div className="mt-md space-y-sm">
                      <div className="flex justify-between text-label-sm font-label-sm mb-xs">
                        <span className="text-on-surface-variant">{adminStats.progress}% Collected</span>
                        <span className="text-primary font-bold">
                          {formatMoney(adminStats.collected)} / {formatMoney(adminStats.total)}
                        </span>
                      </div>
                      <div className="h-2 w-full bg-surface-container-highest rounded-full overflow-hidden flex">
                        <div
                          className="h-full bg-primary-container rounded-full"
                          style={{ width: `${adminStats.progress}%` }}
                        ></div>
                      </div>
                    </div>
                  </div>
                  <div className="grid grid-cols-2 gap-md">
                    <div className="bg-surface-container-lowest border border-outline-variant p-md rounded-xl shadow-sm">
                      <p className="font-label-md text-label-md text-on-surface-variant">Collected</p>
                      <h3 className="font-numeric-data text-numeric-data text-primary font-bold">
                        {formatMoney(adminStats.collected)}
                      </h3>
                    </div>
                    <div className="bg-surface-container-lowest border border-outline-variant p-md rounded-xl shadow-sm">
                      <p className="font-label-md text-label-md text-on-surface-variant">Pending</p>
                      <h3 className="font-numeric-data text-numeric-data text-error font-bold">
                        {formatMoney(adminStats.pending)}
                      </h3>
                    </div>
                  </div>
                </section>

                <section className="bg-surface-container-lowest border border-outline-variant rounded-xl p-lg space-y-md">
                  <div className="flex justify-between items-center">
                    <h2 className="font-headline-md text-headline-lg-mobile font-bold">
                      {new Date().toLocaleDateString("en-US", { month: "long", year: "numeric" })} Overview
                    </h2>
                    <span className="bg-secondary-fixed text-on-secondary-fixed text-label-sm font-bold px-sm py-xs rounded-full">
                      Active
                    </span>
                  </div>
                  <div className="flex items-center gap-md bg-background p-md rounded-lg">
                    <div className="relative w-16 h-16 flex items-center justify-center">
                      <svg className="w-full h-full transform -rotate-90">
                        <circle
                          className="text-surface-container-highest"
                          cx="32"
                          cy="32"
                          fill="transparent"
                          r="28"
                          stroke="currentColor"
                          strokeWidth="6"
                        ></circle>
                        <circle
                          className="text-primary"
                          cx="32"
                          cy="32"
                          fill="transparent"
                          r="28"
                          stroke="currentColor"
                          strokeWidth="6"
                          strokeDasharray={176}
                          strokeDashoffset={
                            adminStats.totalCount > 0
                              ? 176 - 176 * (adminStats.paidCount / adminStats.totalCount)
                              : 176
                          }
                        ></circle>
                      </svg>
                      <span className="absolute text-label-sm font-bold text-on-surface">
                        {adminStats.totalCount > 0
                          ? Math.round((adminStats.paidCount / adminStats.totalCount) * 100)
                          : 0}
                        %
                      </span>
                    </div>
                    <div>
                      <p className="font-body-md text-body-md text-on-surface font-semibold">
                        {adminStats.paidCount} / {adminStats.totalCount} Members Paid
                      </p>
                      <p className="font-label-sm text-label-sm text-on-surface-variant">
                        Due Date: {data.house?.dueDate}th of the month
                      </p>
                    </div>
                  </div>
                </section>
              </>
            ) : (
              /* STATS HEADER: MEMBER VIEW */
              memberStats && (
                <section className="relative overflow-hidden rounded-xl border border-outline-variant bg-surface-container-lowest p-lg shadow-sm">
                  <div className="flex justify-between items-start mb-md">
                    <div>
                      <p className="font-label-md text-label-md text-on-surface-variant">Billing Period</p>
                      <h2 className="font-headline-md text-headline-md font-bold">
                        {new Date().toLocaleDateString("en-US", { month: "long", year: "numeric" })}
                      </h2>
                    </div>
                    <span
                      className={`px-sm py-1 font-label-sm text-label-sm rounded-full font-bold ${
                        memberStats.status === "PAID"
                          ? "bg-primary-container/20 text-primary"
                          : memberStats.status === "PARTIAL"
                          ? "bg-secondary-fixed text-on-secondary-fixed"
                          : "bg-error-container text-on-error-container"
                      }`}
                    >
                      {memberStats.status}
                    </span>
                  </div>
                  <div className="space-y-sm mb-lg">
                    <div className="flex justify-between items-center">
                      <span className="text-on-surface-variant font-label-md text-label-md">Rent Due</span>
                      <span className="font-numeric-data text-numeric-data">{formatMoney(memberStats.due)}</span>
                    </div>
                    <div className="flex justify-between items-center">
                      <span className="text-on-surface-variant font-label-md text-label-md text-primary">Paid</span>
                      <span className="font-numeric-data text-numeric-data text-primary">
                        {formatMoney(memberStats.paid)}
                      </span>
                    </div>
                    <div className="w-full h-2 bg-surface-container-high rounded-full overflow-hidden flex">
                      <div className="bg-primary h-full" style={{ width: `${memberStats.progress}%` }}></div>
                    </div>
                    <div className="flex justify-between items-center pt-sm border-t border-outline-variant mt-sm">
                      <span className="font-label-md text-label-md font-bold">Balance</span>
                      <span
                        className={`font-numeric-data text-numeric-data font-bold ${
                          memberStats.balance > 0 ? "text-error" : "text-primary"
                        }`}
                      >
                        {formatMoney(memberStats.balance)}
                      </span>
                    </div>
                  </div>
                  {memberStats.balance > 0 && (
                    <button
                      onClick={() => setActiveTab("payments")}
                      className="w-full bg-primary hover:bg-emerald-700 text-white font-headline-md text-headline-md py-lg rounded-xl active:scale-[0.98] transition-all flex justify-center items-center gap-sm font-bold shadow-md"
                    >
                      <span>Pay Rent</span>
                      <ArrowRight size={18} />
                    </button>
                  )}
                </section>
              )
            )}

            {/* ACTIVE SETTLEMENTS */}
            <section className="space-y-md">
              <h2 className="font-label-md text-label-md font-bold text-on-surface-variant uppercase tracking-wider px-1">
                Active Settlements
              </h2>
              <div className="space-y-sm">
                {data.debts.length === 0 ? (
                  <div className="p-md text-center bg-surface-container-low border border-outline-variant rounded-xl py-lg">
                    <p className="font-label-sm text-label-sm text-outline italic">No pending settlements</p>
                  </div>
                ) : (
                  data.debts.map((debt) => {
                    const isUserDebtor = data.account.memberId === debt.debtorId;
                    const isUserCreditor = data.account.memberId === debt.creditorId;

                    return (
                      <div
                        key={debt.id}
                        className="bg-surface-container-lowest border border-outline-variant rounded-xl p-md flex items-center justify-between shadow-sm"
                      >
                        <div className="flex items-center gap-md">
                          <div className="w-10 h-10 rounded-full bg-secondary-fixed flex items-center justify-center text-on-secondary-fixed font-bold">
                            {isUserDebtor ? debt.creditor.name[0] : debt.debtor.name[0]}
                          </div>
                          <div>
                            <p className="font-body-md text-body-md">
                              {isUserDebtor ? (
                                <>
                                  You owe <span className="font-bold">{debt.creditor.name}</span>
                                </>
                              ) : isUserCreditor ? (
                                <>
                                  <span className="font-bold">{debt.debtor.name}</span> owes you
                                </>
                              ) : (
                                <>
                                  <span className="font-bold">{debt.debtor.name}</span> owes{" "}
                                  <span className="font-bold">{debt.creditor.name}</span>
                                </>
                              )}
                            </p>
                            <p className="text-xs text-on-surface-variant">{debt.reason}</p>
                          </div>
                        </div>
                        <div className="flex items-center gap-md">
                          <span
                            className={`font-numeric-data text-numeric-data font-bold ${
                              isUserDebtor ? "text-error" : "text-primary"
                            }`}
                          >
                            {formatMoney(debt.amount - debt.settledAmount)}
                          </span>
                          {(isUserDebtor || isUserCreditor || isAdmin) && (
                            <button
                              disabled={busy}
                              onClick={() => handleSettleDebt(debt.id, isUserDebtor ? debt.creditor.name : debt.debtor.name)}
                              className="bg-surface border border-primary text-primary hover:bg-primary hover:text-white px-lg py-sm rounded-full transition-colors text-xs font-semibold"
                            >
                              Settle
                            </button>
                          )}
                        </div>
                      </div>
                    );
                  })
                )}
              </div>
            </section>

            {/* RECENT ACTIVITY */}
            <section className="space-y-md">
              <div className="flex justify-between items-center px-1">
                <h2 className="font-label-md text-label-md font-bold text-on-surface-variant uppercase tracking-wider">
                  Recent Activity
                </h2>
                <button onClick={() => setActiveTab("history")} className="text-primary font-label-sm text-label-sm hover:underline">
                  See All
                </button>
              </div>
              <div className="bg-surface-container-lowest border border-outline-variant rounded-xl divide-y divide-outline-variant/30 shadow-sm overflow-hidden">
                {data.recentActivity && data.recentActivity.length > 0 ? (
                  data.recentActivity.map((act) => (
                    <div key={act.id} className="p-md flex items-center justify-between hover:bg-surface-container-low transition-colors duration-150">
                      <div className="flex items-center gap-md">
                        <div
                          className={`w-10 h-10 rounded-full flex items-center justify-center ${
                            act.status === "CONFIRMED"
                              ? "bg-primary-container/20 text-primary"
                              : act.status === "REJECTED"
                              ? "bg-error-container text-on-error-container"
                              : "bg-secondary-fixed text-on-secondary-fixed"
                          }`}
                        >
                          <span className="material-symbols-outlined">
                            {act.method === "Cash" ? "payments" : act.method === "UPI" ? "qr_code_2" : "account_balance"}
                          </span>
                        </div>
                        <div>
                          <p className="font-label-md text-label-md font-semibold text-on-surface">
                            {act.rentPayment?.member.name ?? "Member"} submitted rent
                          </p>
                          <p className="font-label-sm text-label-sm text-on-surface-variant">
                            via {act.method} • {formatDate(act.paidAt)}
                          </p>
                          {act.payer && act.payer.id !== act.rentPayment?.memberId && (
                            <p className="text-[10px] text-secondary font-bold">Paid on behalf by {act.payer.name}</p>
                          )}
                        </div>
                      </div>
                      <div className="text-right">
                        <p className="font-numeric-data text-numeric-data font-bold text-on-surface">
                          {formatMoney(act.amount)}
                        </p>
                        <span
                          className={`text-[10px] font-bold uppercase tracking-wider ${
                            act.status === "CONFIRMED"
                              ? "text-primary"
                              : act.status === "REJECTED"
                              ? "text-error"
                              : "text-secondary"
                          }`}
                        >
                          {act.status}
                        </span>
                      </div>
                    </div>
                  ))
                ) : (
                  <div className="p-md text-center py-lg">
                    <p className="font-label-sm text-label-sm text-outline italic">No activity logged yet.</p>
                  </div>
                )}
              </div>
            </section>
          </div>
        )}

        {/* MEMBERS TAB */}
        {activeTab === "members" && (
          <div className="space-y-lg">
            {isAdmin && (
              <section className="bg-surface-container-lowest border border-outline-variant rounded-xl p-lg shadow-sm">
                <div className="flex items-center gap-sm mb-lg">
                  <Plus className="text-primary" />
                  <h3 className="font-label-md text-label-md text-on-surface font-bold">Add House Member</h3>
                </div>
                <form onSubmit={handleAddMember} className="grid grid-cols-1 md:grid-cols-2 gap-md">
                  <div className="flex flex-col gap-sm">
                    <label className="font-label-md text-label-md text-on-surface-variant" htmlFor="new-member-name">
                      Member Name
                    </label>
                    <input
                      required
                      className="w-full px-4 py-3 bg-surface border border-outline-variant rounded-xl font-body-md text-body-md"
                      id="new-member-name"
                      placeholder="e.g. Rinshad"
                      type="text"
                      value={newMemberName}
                      onChange={(e) => setNewMemberName(e.target.value)}
                    />
                  </div>
                  <div className="flex flex-col gap-sm">
                    <label className="font-label-md text-label-md text-on-surface-variant" htmlFor="new-member-phone">
                      Phone (Optional)
                    </label>
                    <input
                      className="w-full px-4 py-3 bg-surface border border-outline-variant rounded-xl font-body-md text-body-md"
                      id="new-member-phone"
                      placeholder="e.g. +91 9876543210"
                      type="text"
                      value={newMemberPhone}
                      onChange={(e) => setNewMemberPhone(e.target.value)}
                    />
                  </div>
                  <div className="md:col-span-2 mt-md">
                    <button
                      disabled={busy}
                      className="bg-primary hover:bg-emerald-700 text-white font-label-md text-label-md px-lg py-sm rounded-xl transition-all duration-150 active:scale-95 flex items-center gap-2 disabled:opacity-50"
                      type="submit"
                    >
                      {busy ? <Loader2 className="animate-spin" size={16} /> : <Plus size={16} />}
                      Save Member
                    </button>
                  </div>
                </form>
              </section>
            )}

            <section className="space-y-md">
              <h2 className="font-headline-md text-headline-lg-mobile font-bold px-1">House Members ({data.members.length})</h2>
              <div className="bg-surface-container-lowest border border-outline-variant rounded-xl overflow-hidden divide-y divide-outline-variant/30 shadow-sm">
                {data.members.map((member) => {
                  const rp = data.month?.rentPayments.find((p) => p.memberId === member.id);
                  const paid = rp?.amountPaid ?? 0;
                  const due = rp?.amountDue ?? 0;
                  const balance = due - paid;
                  const status = rp?.status ?? "PENDING";

                  return (
                    <div key={member.id} className="p-md flex items-center justify-between hover:bg-surface-container-low transition-colors duration-150">
                      <div className="flex items-center gap-md">
                        <div className="w-10 h-10 rounded-full bg-surface-container-high flex items-center justify-center text-primary font-bold">
                          {member.name[0]}
                        </div>
                        <div>
                          <p className="font-label-md text-label-md font-semibold text-on-surface">{member.name}</p>
                          <p className="text-xs text-on-surface-variant">{member.phone ?? "No phone set"}</p>
                          {data.month && (
                            <span
                              className={`text-[9px] font-bold px-1.5 py-0.5 rounded font-numeric-data uppercase ${
                                status === "PAID"
                                  ? "bg-emerald-100 text-emerald-800"
                                  : status === "PARTIAL"
                                  ? "bg-indigo-100 text-indigo-800"
                                  : "bg-red-100 text-red-800"
                              }`}
                            >
                              {status}
                            </span>
                          )}
                        </div>
                      </div>
                      {data.month && (
                        <div className="text-right">
                          <p
                            className={`font-numeric-data text-numeric-data font-bold ${
                              balance > 0 ? "text-error" : "text-primary"
                            }`}
                          >
                            {balance > 0 ? formatMoney(balance) : "₹0"}
                          </p>
                          <p className="text-[10px] text-on-surface-variant">
                            {balance > 0 ? "balance due" : "paid in full"}
                          </p>
                        </div>
                      )}
                    </div>
                  );
                })}
              </div>
            </section>
          </div>
        )}

        {/* PAYMENTS TAB */}
        {activeTab === "payments" && (
          <div className="space-y-lg">
            {/* ADMIN VIEW: VERIFICATION QUEUE */}
            {isAdmin ? (
              <section className="space-y-md">
                <div className="flex justify-between items-center px-1">
                  <h3 className="font-headline-md text-headline-lg-mobile font-bold flex items-center gap-2">
                    <span className="material-symbols-outlined text-error">priority_high</span>
                    Needs Attention
                  </h3>
                  <span className="bg-error-container text-on-error-container font-label-sm text-label-sm px-2.5 py-0.5 rounded-full font-bold">
                    {data.pendingConfirmations?.length ?? 0} Pending Confirmations
                  </span>
                </div>
                <div className="space-y-sm">
                  {!data.pendingConfirmations || data.pendingConfirmations.length === 0 ? (
                    <div className="p-xl text-center bg-surface-container-lowest border border-outline-variant rounded-xl shadow-sm">
                      <CheckCircle2 size={32} className="mx-auto text-primary mb-md" />
                      <p className="font-body-md text-body-md text-on-surface font-semibold">All caught up!</p>
                      <p className="font-label-sm text-label-sm text-outline mt-xs">No pending rent transactions to verify.</p>
                    </div>
                  ) : (
                    data.pendingConfirmations.map((tx) => (
                      <div
                        key={tx.id}
                        className="bg-surface-container-lowest border border-outline-variant rounded-xl p-md flex flex-col gap-md shadow-sm"
                      >
                        <div className="flex justify-between items-start">
                          <div className="flex items-center gap-md">
                            <div className="w-12 h-12 rounded-full bg-surface-container-high flex items-center justify-center text-primary font-bold">
                              {tx.rentPayment?.member.name[0]}
                            </div>
                            <div>
                              <p className="font-label-md text-label-md font-bold">
                                {tx.rentPayment?.member.name}
                              </p>
                              <p className="text-label-sm font-label-sm text-on-surface-variant">
                                submitted {formatMoney(tx.amount)} via {tx.method}
                              </p>
                              {tx.payer && tx.payer.id !== tx.rentPayment?.memberId && (
                                <p className="text-xs text-secondary font-bold">Paid on behalf by {tx.payer.name}</p>
                              )}
                              {tx.reference && (
                                <p className="text-xs font-numeric-data font-bold text-on-surface bg-surface-container-low px-2 py-0.5 rounded inline-block mt-1">
                                  Ref: {tx.reference}
                                </p>
                              )}
                            </div>
                          </div>
                          <div className="text-right">
                            <p className="font-numeric-data text-numeric-data text-primary font-bold">
                              {formatMoney(tx.amount)}
                            </p>
                            <p className="text-[10px] text-on-surface-variant">{formatDate(tx.paidAt)}</p>
                          </div>
                        </div>
                        <div className="flex gap-2">
                          <button
                            disabled={busy}
                            onClick={() => handleConfirmTransaction(tx.id, tx.rentPayment?.member.name ?? "Member")}
                            className="flex-1 bg-primary hover:bg-emerald-700 text-white py-2 rounded-lg font-label-md text-label-md active:scale-95 transition-transform flex items-center justify-center gap-1 font-semibold"
                          >
                            <Check size={16} /> Confirm
                          </button>
                          <button
                            disabled={busy}
                            onClick={() => handleRejectTransaction(tx.id, tx.rentPayment?.member.name ?? "Member")}
                            className="flex-1 border border-outline-variant hover:bg-red-50 text-error py-2 rounded-lg font-label-md text-label-md active:scale-95 transition-transform flex items-center justify-center gap-1 font-semibold"
                          >
                            <X size={16} /> Reject
                          </button>
                        </div>
                      </div>
                    ))
                  )}
                </div>
              </section>
            ) : (
              /* MEMBER VIEW: PAY RENT FORM */
              memberStats && (
                <section className="bg-surface-container-lowest border border-outline-variant rounded-xl p-lg shadow-sm">
                  <div className="mb-lg border-b border-outline-variant/40 pb-sm">
                    <h2 className="font-headline-md text-headline-lg-mobile font-bold">Submit Rent Payment</h2>
                    <p className="text-sm text-on-surface-variant">
                      Initiate a UPI transfer or submit transaction verification details to the house owner.
                    </p>
                  </div>
                  <form onSubmit={handlePaymentSubmit} className="flex flex-col gap-lg">
                    {/* Behalf Toggle */}
                    <div className="flex items-center gap-2 border-b border-outline-variant/30 pb-md">
                      <input
                        type="checkbox"
                        id="behalf-toggle"
                        checked={payBehalf}
                        onChange={(e) => {
                          setPayBehalf(e.target.checked);
                          if (!e.target.checked) {
                            // Reset back to self payment
                            const myPayment = data.month?.rentPayments.find(
                              (p) => p.memberId === data.account.memberId
                            );
                            if (myPayment) {
                              setPayTargetPaymentId(myPayment.id);
                              setPayTargetMemberId(myPayment.memberId);
                              setPayAmount(String(myPayment.amountDue - myPayment.amountPaid));
                            }
                          } else {
                            // Default to first other member
                            const otherPayment = data.month?.rentPayments.find(
                              (p) => p.memberId !== data.account.memberId
                            );
                            if (otherPayment) {
                              setPayTargetPaymentId(otherPayment.id);
                              setPayTargetMemberId(otherPayment.memberId);
                              setPayAmount(String(otherPayment.amountDue - otherPayment.amountPaid));
                            }
                          }
                        }}
                        className="rounded text-primary focus:ring-primary"
                      />
                      <label htmlFor="behalf-toggle" className="text-sm font-semibold text-on-surface cursor-pointer">
                        Pay on behalf of another member
                      </label>
                    </div>

                    {/* Member target (if Behalf) */}
                    {payBehalf && (
                      <div className="flex flex-col gap-sm">
                        <label className="font-label-md text-label-md text-on-surface-variant" htmlFor="pay-target">
                          Choose Tenant
                        </label>
                        <div className="relative">
                          <select
                            className="w-full px-4 py-3 bg-surface border border-outline-variant rounded-xl font-body-md text-body-md appearance-none"
                            id="pay-target"
                            value={payTargetPaymentId}
                            onChange={(e) => {
                              const paymentId = e.target.value;
                              const payment = data.month?.rentPayments.find((p) => p.id === paymentId);
                              if (payment) {
                                setPayTargetPaymentId(payment.id);
                                setPayTargetMemberId(payment.memberId);
                                setPayAmount(String(payment.amountDue - payment.amountPaid));
                              }
                            }}
                          >
                            {data.month?.rentPayments
                              .filter((p) => p.memberId !== data.account.memberId)
                              .map((p) => (
                                <option key={p.id} value={p.id}>
                                  {p.member.name} (Due: {formatMoney(p.amountDue - p.amountPaid)})
                                </option>
                              ))}
                          </select>
                          <span className="material-symbols-outlined absolute right-4 top-1/2 -translate-y-1/2 text-outline pointer-events-none">
                            expand_more
                          </span>
                        </div>
                      </div>
                    )}

                    {/* Amount */}
                    <div className="flex flex-col gap-sm">
                      <label className="font-label-md text-label-md text-on-surface-variant" htmlFor="pay-amount">
                        Amount to Pay
                      </label>
                      <div className="relative">
                        <span className="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-outline">
                          payments
                        </span>
                        <input
                          required
                          className="w-full pl-12 pr-4 py-3 bg-surface border border-outline-variant rounded-xl font-numeric-data text-body-md"
                          id="pay-amount"
                          placeholder="e.g. 3000"
                          type="number"
                          value={payAmount}
                          onChange={(e) => setPayAmount(e.target.value)}
                        />
                      </div>
                    </div>

                    {/* Method */}
                    <div className="flex flex-col gap-sm">
                      <label className="font-label-md text-label-md text-on-surface-variant" htmlFor="pay-method">
                        Payment Method
                      </label>
                      <div className="relative">
                        <select
                          className="w-full px-4 py-3 bg-surface border border-outline-variant rounded-xl font-body-md text-body-md appearance-none"
                          id="pay-method"
                          value={payMethod}
                          onChange={(e) => setPayMethod(e.target.value)}
                        >
                          <option value="UPI">UPI Payment</option>
                          <option value="Cash">Cash</option>
                          <option value="Bank Transfer">Bank Transfer</option>
                          <option value="Card">Card</option>
                          <option value="Other">Other</option>
                        </select>
                        <span className="material-symbols-outlined absolute right-4 top-1/2 -translate-y-1/2 text-outline pointer-events-none">
                          expand_more
                        </span>
                      </div>
                    </div>

                    {/* UPI Deep Link Payment Section */}
                    {payMethod === "UPI" && data.house && (
                      <div className="bg-surface-container-low border border-outline-variant/60 rounded-xl p-md space-y-md setup-card-shadow">
                        <div className="flex items-center gap-xs">
                          <span className="material-symbols-outlined text-primary">qr_code_2</span>
                          <span className="font-label-md text-label-md font-bold text-on-surface">
                            UPI Gateway Integration
                          </span>
                        </div>
                        <div className="space-y-1">
                          <p className="text-xs text-on-surface-variant">UPI Payer Name: {data.house.ownerName}</p>
                          <div className="flex items-center justify-between bg-surface border border-outline-variant rounded-lg p-2 mt-1">
                            <span className="font-numeric-data text-sm font-semibold">{data.house.upiId}</span>
                            <button
                              type="button"
                              onClick={() => {
                                navigator.clipboard.writeText(data.house?.upiId ?? "");
                                toast.success("Owner UPI ID copied to clipboard!");
                              }}
                              className="text-primary flex items-center gap-xs hover:text-emerald-700 text-xs font-bold"
                            >
                              <Copy size={12} /> Copy
                            </button>
                          </div>
                        </div>
                        {payAmount && Number(payAmount) > 0 && (
                          <a
                            href={`upi://pay?pa=${data.house.upiId}&pn=${encodeURIComponent(
                              data.house.ownerName
                            )}&am=${payAmount}&cu=${data.house.currency}&tn=RentFlow%20Payment`}
                            className="w-full bg-primary hover:bg-emerald-700 text-white font-label-md text-label-md py-3 rounded-lg font-bold shadow transition-all active:scale-[0.98] flex items-center justify-center gap-sm mt-md"
                          >
                            <span>Pay via App (₹{payAmount})</span>
                            <span className="material-symbols-outlined">launch</span>
                          </a>
                        )}
                      </div>
                    )}

                    {/* Reference / Note */}
                    <div className="flex flex-col gap-sm">
                      <label className="font-label-md text-label-md text-on-surface-variant" htmlFor="pay-ref">
                        Transaction Reference / Note
                      </label>
                      <input
                        className="w-full px-4 py-3 bg-surface border border-outline-variant rounded-xl font-body-md text-body-md"
                        id="pay-ref"
                        placeholder="UPI Ref No., Cash note, or Bank Tx ID"
                        type="text"
                        value={payReference}
                        onChange={(e) => setPayReference(e.target.value)}
                      />
                    </div>

                    {/* Submit */}
                    <div className="mt-md">
                      <button
                        disabled={busy}
                        className="w-full bg-primary hover:bg-emerald-700 text-white font-headline-md text-headline-md py-4 rounded-xl shadow-lg active:scale-95 transition-transform duration-150 flex items-center justify-center gap-2 disabled:opacity-50"
                        type="submit"
                      >
                        {busy ? (
                          <>
                            <Loader2 className="animate-spin" size={20} />
                            <span>Submitting verification...</span>
                          </>
                        ) : (
                          <>
                            <span>Submit Payment Claim</span>
                            <span className="material-symbols-outlined">send</span>
                          </>
                        )}
                      </button>
                    </div>
                  </form>
                </section>
              )
            )}
          </div>
        )}

        {/* HISTORY TAB */}
        {activeTab === "history" && (
          <section className="space-y-md">
            <h2 className="font-headline-md text-headline-lg-mobile font-bold px-1">Payment Ledger History</h2>
            <div className="bg-surface-container-lowest border border-outline-variant rounded-xl divide-y divide-outline-variant/30 shadow-sm overflow-hidden">
              {data.recentActivity && data.recentActivity.length > 0 ? (
                data.recentActivity.map((tx) => (
                  <div key={tx.id} className="p-md flex items-center justify-between hover:bg-surface-container-low transition-colors duration-150">
                    <div className="flex items-center gap-md">
                      <div
                        className={`w-10 h-10 rounded-full flex items-center justify-center ${
                          tx.status === "CONFIRMED"
                            ? "bg-primary-container/20 text-primary"
                            : tx.status === "REJECTED"
                            ? "bg-error-container text-on-error-container"
                            : "bg-secondary-fixed text-on-secondary-fixed"
                        }`}
                      >
                        <span className="material-symbols-outlined">
                          {tx.method === "Cash" ? "payments" : tx.method === "UPI" ? "qr_code_2" : "account_balance"}
                        </span>
                      </div>
                      <div>
                        <p className="font-label-md text-label-md font-semibold text-on-surface">
                          {tx.rentPayment?.member.name}
                        </p>
                        <p className="font-label-sm text-label-sm text-on-surface-variant">
                          via {tx.method} • {formatDate(tx.paidAt)}
                        </p>
                        {tx.payer && tx.payer.id !== tx.rentPayment?.memberId && (
                          <p className="text-[10px] text-secondary font-bold">Paid on behalf by {tx.payer.name}</p>
                        )}
                        {tx.reference && <p className="text-xs text-on-surface-variant mt-0.5">Ref: {tx.reference}</p>}
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="font-numeric-data text-numeric-data font-bold text-on-surface">
                        {formatMoney(tx.amount)}
                      </p>
                      <span
                        className={`text-[10px] font-bold uppercase tracking-wider ${
                          tx.status === "CONFIRMED"
                            ? "text-primary"
                            : tx.status === "REJECTED"
                            ? "text-error"
                            : "text-secondary"
                        }`}
                      >
                        {tx.status}
                      </span>
                    </div>
                  </div>
                ))
              ) : (
                <div className="p-xl text-center">
                  <p className="font-label-sm text-label-sm text-outline italic">No transactions found in system history.</p>
                </div>
              )}
            </div>
          </section>
        )}

        {/* PROFILE TAB */}
        {activeTab === "profile" && (
          <div className="space-y-lg">
            <section className="bg-surface-container-lowest border border-outline-variant rounded-xl p-lg shadow-sm">
              <h2 className="font-headline-md text-headline-lg-mobile font-bold mb-md border-b border-outline-variant/30 pb-sm">
                User Details
              </h2>
              <div className="space-y-sm text-sm">
                <div className="flex justify-between border-b border-outline-variant/20 py-2">
                  <span className="text-on-surface-variant">Email Address</span>
                  <span className="font-semibold">{data.account.name}</span>
                </div>
                <div className="flex justify-between border-b border-outline-variant/20 py-2">
                  <span className="text-on-surface-variant">System Role</span>
                  <span className="font-bold text-primary">{data.account.role}</span>
                </div>
                {data.account.memberId && (
                  <div className="flex justify-between py-2">
                    <span className="text-on-surface-variant">Linked Member ID</span>
                    <span className="font-numeric-data text-xs">{data.account.memberId}</span>
                  </div>
                )}
              </div>
            </section>

            {data.house && (
              <section className="bg-surface-container-lowest border border-outline-variant rounded-xl p-lg shadow-sm">
                <h2 className="font-headline-md text-headline-lg-mobile font-bold mb-md border-b border-outline-variant/30 pb-sm text-on-surface">
                  House Settings
                </h2>
                <div className="space-y-sm text-sm">
                  <div className="flex justify-between border-b border-outline-variant/20 py-2">
                    <span className="text-on-surface-variant">House Name</span>
                    <span className="font-semibold">{data.house.name}</span>
                  </div>
                  <div className="flex justify-between border-b border-outline-variant/20 py-2">
                    <span className="text-on-surface-variant">Monthly Rent</span>
                    <span className="font-bold text-primary">{formatMoney(data.house.rent)}</span>
                  </div>
                  <div className="flex justify-between border-b border-outline-variant/20 py-2">
                    <span className="text-on-surface-variant">Cycle Due Date</span>
                    <span className="font-semibold">{data.house.dueDate}th of the month</span>
                  </div>
                  <div className="flex justify-between border-b border-outline-variant/20 py-2">
                    <span className="text-on-surface-variant">Owner Name</span>
                    <span className="font-semibold">{data.house.ownerName}</span>
                  </div>
                  <div className="flex justify-between py-2">
                    <span className="text-on-surface-variant">Owner UPI ID</span>
                    <span className="font-semibold">{data.house.upiId}</span>
                  </div>
                </div>
              </section>
            )}
          </div>
        )}
      </main>

      {/* BottomNavBar */}
      <nav className="fixed bottom-0 w-full z-50 rounded-t-xl bg-surface border-t border-outline-variant shadow-md">
        <div className="flex justify-around items-center w-full h-16 pb-safe px-4 max-w-container_max_width mx-auto">
          {/* Home */}
          <button
            onClick={() => setActiveTab("home")}
            className={`flex flex-col items-center justify-center px-4 py-1 transition-all duration-200 ${
              activeTab === "home"
                ? "bg-primary-container/20 text-primary rounded-xl font-bold scale-105"
                : "text-on-surface-variant hover:text-primary active:scale-90"
            }`}
          >
            <Home size={20} />
            <span className="font-label-sm text-[10px] mt-0.5">Home</span>
          </button>
          {/* Members */}
          <button
            onClick={() => setActiveTab("members")}
            className={`flex flex-col items-center justify-center px-4 py-1 transition-all duration-200 ${
              activeTab === "members"
                ? "bg-primary-container/20 text-primary rounded-xl font-bold scale-105"
                : "text-on-surface-variant hover:text-primary active:scale-90"
            }`}
          >
            <Users size={20} />
            <span className="font-label-sm text-[10px] mt-0.5">Members</span>
          </button>
          {/* Payments / Verify Queue */}
          <button
            onClick={() => setActiveTab("payments")}
            className={`flex flex-col items-center justify-center px-4 py-1 transition-all duration-200 ${
              activeTab === "payments"
                ? "bg-primary-container/20 text-primary rounded-xl font-bold scale-105"
                : "text-on-surface-variant hover:text-primary active:scale-90"
            }`}
          >
            <CreditCard size={20} />
            <span className="font-label-sm text-[10px] mt-0.5">
              {isAdmin ? "Verification" : "Pay Rent"}
            </span>
          </button>
          {/* History */}
          <button
            onClick={() => setActiveTab("history")}
            className={`flex flex-col items-center justify-center px-4 py-1 transition-all duration-200 ${
              activeTab === "history"
                ? "bg-primary-container/20 text-primary rounded-xl font-bold scale-105"
                : "text-on-surface-variant hover:text-primary active:scale-90"
            }`}
          >
            <HistoryIcon size={20} />
            <span className="font-label-sm text-[10px] mt-0.5">History</span>
          </button>
          {/* Profile */}
          <button
            onClick={() => setActiveTab("profile")}
            className={`flex flex-col items-center justify-center px-4 py-1 transition-all duration-200 ${
              activeTab === "profile"
                ? "bg-primary-container/20 text-primary rounded-xl font-bold scale-105"
                : "text-on-surface-variant hover:text-primary active:scale-90"
            }`}
          >
            <UserIcon size={20} />
            <span className="font-label-sm text-[10px] mt-0.5">Profile</span>
          </button>
        </div>
      </nav>
    </div>
  );
}
