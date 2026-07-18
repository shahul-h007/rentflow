import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../models/models.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  String _formatCurrency(int amount) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(amount);
  }

  void _handleSignOut() async {
    final auth = context.read<AuthProvider>();
    await auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dashboard = context.watch<DashboardProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "RentFlow Member",
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E4620),
              ),
            ),
            if (auth.currentUser != null)
              Text(
                "Logged in as: ${auth.currentUser!.email}",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF8E8E93),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1E4620)),
            onPressed: () => dashboard.loadDashboard(silent: false),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Color(0xFF8B2D21)),
            onPressed: _handleSignOut,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFE5E5EA),
            height: 1.0,
          ),
        ),
      ),
      body: dashboard.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF1E4620)),
              ),
            )
          : dashboard.errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Color(0xFF8B2D21)),
                        const SizedBox(height: 16),
                        Text(
                          "Error: ${dashboard.errorMessage}",
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: const Color(0xFF8B2D21),
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => dashboard.loadDashboard(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E4620),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                )
              : dashboard.currentMonth == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          "No active month has been created by the administrator.",
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: const Color(0xFF8E8E93),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
              : RefreshIndicator(
                  onRefresh: () => dashboard.loadDashboard(silent: true),
                  color: const Color(0xFF1E4620),
                  child: IndexedStack(
                    index: _currentIndex,
                    children: [
                      _OverviewTab(
                        month: dashboard.currentMonth!,
                        currentUser: auth.currentUser,
                        formatCurrency: _formatCurrency,
                      ),
                      _ExpensesTab(
                        month: dashboard.currentMonth!,
                        members: dashboard.members,
                        currentUser: auth.currentUser,
                        formatCurrency: _formatCurrency,
                      ),
                      _UtilitiesTab(
                        month: dashboard.currentMonth!,
                        formatCurrency: _formatCurrency,
                      ),
                      _SettlementsTab(
                        members: dashboard.members,
                        debts: dashboard.currentMonth!.debts,
                        currentUser: auth.currentUser,
                        formatCurrency: _formatCurrency,
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1E4620),
        unselectedItemColor: const Color(0xFF8E8E93),
        selectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bolt_outlined),
            activeIcon: Icon(Icons.bolt),
            label: 'Utilities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handshake_outlined),
            activeIcon: Icon(Icons.handshake),
            label: 'Settlements',
          ),
        ],
      ),
    );
  }
}

// ============================================
// OVERVIEW TAB
// ============================================
class _OverviewTab extends StatelessWidget {
  final RentMonth month;
  final UserAccount? currentUser;
  final String Function(int) formatCurrency;

  const _OverviewTab({
    required this.month,
    required this.currentUser,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final collected = month.rentPayments.fold(0, (sum, p) => sum + p.amountPaid);
    final remaining = month.rent - collected;
    final totalUtilities = month.utilities.fold(0, (sum, u) => sum + u.amount);
    final totalExpenses = month.expenses.fold(0, (sum, e) => sum + e.amount);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Date / Status header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "July 2026 Billing Status",
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E4620),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F6F1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                month.status,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E4620),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Grid of Stats
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _MetricCard(
              title: "Rent Collected",
              value: formatCurrency(collected),
              badgeText: "${((collected / month.rent) * 100).round()}% Recv",
              badgeColor: const Color(0xFFE3F6F1),
              textColor: const Color(0xFF1E4620),
            ),
            _MetricCard(
              title: "Rent Remaining",
              value: formatCurrency(remaining),
              badgeText: "${month.rentPayments.where((p) => p.status != 'PAID').length} Open",
              badgeColor: const Color(0xFFFFE4A3),
              textColor: const Color(0xFF875B00),
            ),
            _MetricCard(
              title: "Utilities Dues",
              value: formatCurrency(totalUtilities),
              badgeText: "${month.utilities.length} Bills",
              badgeColor: const Color(0xFFE5DDFF),
              textColor: const Color(0xFF4A3AFF),
            ),
            _MetricCard(
              title: "Shared Expenses",
              value: formatCurrency(totalExpenses),
              badgeText: "${month.expenses.length} Records",
              badgeColor: const Color(0xFFFFD9D4),
              textColor: const Color(0xFF8B2D21),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Dues / Roster List
        Text(
          "House Rent Payment Board",
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1C1C1E),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E5EA)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: month.rentPayments.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF2F2F7)),
            itemBuilder: (context, index) {
              final payment = month.rentPayments[index];
              final isSelf = currentUser != null && currentUser!.memberId == payment.memberId;
              final canPay = isSelf && payment.status != 'PAID';

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFE3F6F1),
                      radius: 18,
                      child: Text(
                        payment.member?.name[0] ?? "U",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E4620),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                payment.member?.name ?? "Unknown Resident",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1C1C1E),
                                ),
                              ),
                              if (isSelf) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E4620),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "YOU",
                                    style: GoogleFonts.inter(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${formatCurrency(payment.amountPaid)} paid of ${formatCurrency(payment.amountDue)}",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF8E8E93),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusBadge(status: payment.status),
                    if (canPay) ...[
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _showPayRentDialog(context, payment),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E4620),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Pay",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showPayRentDialog(BuildContext context, RentPayment payment) {
    final methodController = TextEditingController(text: "UPI");
    final amountController = TextEditingController(text: (payment.amountDue - payment.amountPaid).toString());
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Quick Rent Payment",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Paying rent for ${payment.member?.name}",
                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF8E8E93)),
              ),
              const SizedBox(height: 16),
              Text(
                "Payment Method",
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: methodController,
                decoration: InputDecoration(
                  hintText: "UPI / Cash / Bank Transfer",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Amount Paid (₹)",
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter amount",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: GoogleFonts.inter(color: const Color(0xFF8B2D21))),
            ),
            ElevatedButton(
              onPressed: () async {
                final amt = int.tryParse(amountController.text) ?? 0;
                if (amt <= 0) return;
                
                final dashboard = context.read<DashboardProvider>();
                final success = await dashboard.payRent(
                  paymentId: payment.id,
                  amountPaid: amt,
                  method: methodController.text,
                );

                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Rent payment recorded successfully!")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E4620),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text("Mark Paid", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String badgeText;
  final Color badgeColor;
  final Color textColor;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.badgeText,
    required this.badgeColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E5EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF8E8E93),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1C1C1E),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// EXPENSES TAB
// ============================================
class _ExpensesTab extends StatelessWidget {
  final RentMonth month;
  final List<Member> members;
  final UserAccount? currentUser;
  final String Function(int) formatCurrency;

  const _ExpensesTab({
    required this.month,
    required this.members,
    required this.currentUser,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Shared Household Expenses",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1C1C1E),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddExpenseDialog(context),
                icon: const Icon(Icons.add, size: 16),
                label: Text(
                  "Log",
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E4620),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E5EA)),
            ),
            child: month.expenses.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        "No shared expenses logged this month yet.",
                        style: GoogleFonts.inter(color: const Color(0xFF8E8E93)),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: month.expenses.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF2F2F7)),
                    itemBuilder: (context, index) {
                      final expense = month.expenses[index];
                      final dateStr = DateFormat('MMM d, h:mm a').format(expense.createdAt);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFFFD9D4),
                          child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF8B2D21)),
                        ),
                        title: Text(
                          expense.title,
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(
                          "Paid by ${expense.paidBy?.name ?? 'Unknown'} · $dateStr",
                          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF8E8E93)),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatCurrency(expense.amount),
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1C1C1E),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E5EA),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "SPLIT",
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF636366),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    String selectedMemberId = currentUser?.memberId ?? members.first.id;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Log Shared Expense",
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1C1C1E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "This expense will be divided equally among all house members.",
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF8E8E93)),
                  ),
                  const SizedBox(height: 20),

                  // Title Input
                  Text("Expense Title", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: "e.g. WiFi, Groceries, Maid",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Amount Input
                  Text("Amount (₹)", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter total amount",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Paid By Selector
                  Text("Paid By", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedMemberId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: members.map((m) {
                      return DropdownMenuItem<String>(
                        value: m.id,
                        child: Text(m.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          selectedMemberId = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Notes Input
                  Text("Notes (Optional)", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      hintText: "Add additional notes",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: () async {
                      final title = titleController.text.trim();
                      final amt = int.tryParse(amountController.text) ?? 0;
                      if (title.isEmpty || amt <= 0) return;

                      final dashboard = context.read<DashboardProvider>();
                      final success = await dashboard.addExpense(
                        title: title,
                        amount: amt,
                        paidById: selectedMemberId,
                        notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                      );

                      if (success && context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Expense logged and split successfully!")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E4620),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Save Expense", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ============================================
// UTILITIES TAB
// ============================================
class _UtilitiesTab extends StatelessWidget {
  final RentMonth month;
  final String Function(int) formatCurrency;

  const _UtilitiesTab({
    required this.month,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          "Monthly Bills & Utilities",
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1C1C1E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "These bills are set up and managed by the administrator.",
          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF8E8E93)),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E5EA)),
          ),
          child: month.utilities.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      "No utility bills added this month yet.",
                      style: GoogleFonts.inter(color: const Color(0xFF8E8E93)),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: month.utilities.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF2F2F7)),
                  itemBuilder: (context, index) {
                    final utility = month.utilities[index];
                    final paidByStr = utility.paidBy?.name ?? "Not marked paid";

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFE5DDFF),
                        child: const Icon(Icons.bolt, color: Color(0xFF4A3AFF)),
                      ),
                      title: Text(
                        utility.name,
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        "Status: $paidByStr",
                        style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF8E8E93)),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formatCurrency(utility.amount),
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1C1C1E),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusBadge(status: utility.status),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ============================================
// SETTLEMENTS TAB
// ============================================
class _SettlementsTab extends StatelessWidget {
  final List<Member> members;
  final List<Debt> debts;
  final UserAccount? currentUser;
  final String Function(int) formatCurrency;

  const _SettlementsTab({
    required this.members,
    required this.debts,
    required this.currentUser,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Balances & Room Settlements",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1C1C1E),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddSettlementDialog(context),
                icon: const Icon(Icons.payment, size: 16),
                label: Text(
                  "Settle",
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E4620),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E5EA)),
            ),
            child: debts.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        "No room debts recorded yet.",
                        style: GoogleFonts.inter(color: const Color(0xFF8E8E93)),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: debts.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF2F2F7)),
                    itemBuilder: (context, index) {
                      final debt = debts[index];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFE3F6F1),
                          child: const Icon(Icons.handshake_outlined, color: Color(0xFF1E4620)),
                        ),
                        title: Text(
                          "${debt.debtor?.name} → ${debt.creditor?.name}",
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(
                          debt.reason,
                          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF8E8E93)),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatCurrency(debt.amount),
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1C1C1E),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _StatusBadge(status: debt.status),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddSettlementDialog(BuildContext context) {
    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    
    // Filter active members
    final activeMembers = members.where((m) => m.active).toList();
    if (activeMembers.length < 2) return;

    String selectedDebtorId = currentUser?.memberId ?? activeMembers[0].id;
    String selectedCreditorId = activeMembers.firstWhere((m) => m.id != selectedDebtorId).id;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Record Room Settlement",
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1C1C1E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Manually record a payment made to settle a roommate debt.",
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF8E8E93)),
                  ),
                  const SizedBox(height: 20),

                  // Debtor Selector
                  Text("Who Pays (Debtor)", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedDebtorId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: activeMembers.map((m) {
                      return DropdownMenuItem<String>(
                        value: m.id,
                        child: Text(m.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          selectedDebtorId = val;
                          if (selectedDebtorId == selectedCreditorId) {
                            selectedCreditorId = activeMembers.firstWhere((m) => m.id != selectedDebtorId).id;
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Creditor Selector
                  Text("Who Receives (Creditor)", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedCreditorId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: activeMembers.where((m) => m.id != selectedDebtorId).map((m) {
                      return DropdownMenuItem<String>(
                        value: m.id,
                        child: Text(m.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          selectedCreditorId = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Amount Input
                  Text("Settlement Amount (₹)", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter amount",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Reason Input
                  Text("Reason/Description", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reasonController,
                    decoration: InputDecoration(
                      hintText: "e.g. Settle grocery dues, rent coverage repay",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: () async {
                      final amt = int.tryParse(amountController.text) ?? 0;
                      final reason = reasonController.text.trim();
                      if (amt <= 0 || reason.isEmpty) return;

                      final dashboard = context.read<DashboardProvider>();
                      final success = await dashboard.recordSettlement(
                        debtorId: selectedDebtorId,
                        creditorId: selectedCreditorId,
                        amount: amt,
                        reason: reason,
                      );

                      if (success && context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Settlement logged successfully!")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E4620),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Save Settlement", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ============================================
// HELPER BADGE WIDGET
// ============================================
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status.toUpperCase()) {
      case 'PAID':
      case 'SETTLED':
        bg = const Color(0xFFE3F6F1);
        fg = const Color(0xFF1E4620);
        break;
      case 'PARTIAL':
        bg = const Color(0xFFFFE4A3);
        fg = const Color(0xFF875B00);
        break;
      default: // PENDING / OPEN / etc.
        bg = const Color(0xFFFFD9D4);
        fg = const Color(0xFF8B2D21);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status.toLowerCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}
