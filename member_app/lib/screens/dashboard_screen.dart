import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../models/models.dart';
import 'login_screen.dart';
import '../features/food_splitter/presentation/screens/scanner_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 1;

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
        backgroundColor: const Color(0xFFF9FBF9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF1E4620)),
          onPressed: () {},
        ),
        title: Text(
          "RentFlow Splitter",
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0D7B49),
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1E4620)),
            onPressed: () => dashboard.loadDashboard(silent: false),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: _handleSignOut,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFE3F6F1),
                child: Text(
                  auth.currentUser?.email.substring(0, 1).toUpperCase() ?? "U",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E4620),
                  ),
                ),
              ),
            ),
          ),
        ],
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
                    index: _currentIndex == 0 ? 1 : _currentIndex, // Prevent 0 from being accessed as a tab
                    children: [
                      const SizedBox.shrink(), // Index 0 is Scan
                      _HomeTab(
                        month: dashboard.currentMonth!,
                        currentUser: auth.currentUser,
                        formatCurrency: _formatCurrency,
                        dashboard: dashboard,
                      ),
                      _SharedBillsTab(
                        month: dashboard.currentMonth!,
                        members: dashboard.members,
                        currentUser: auth.currentUser,
                        formatCurrency: _formatCurrency,
                      ),
                      _SettlementsTab(
                        members: dashboard.members,
                        debts: dashboard.debts,
                        currentUser: auth.currentUser,
                        formatCurrency: _formatCurrency,
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (index == 0) {
            // Scan action
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScannerScreen()),
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE3F6F1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: Color(0xFF0D7B49)),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check, color: Color(0xFF0D7B49)),
            label: 'Review',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_add_alt_1_outlined),
            selectedIcon: Icon(Icons.person_add_alt_1, color: Color(0xFF0D7B49)),
            label: 'Assign',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments, color: Color(0xFF0D7B49)),
            label: 'Settlement',
          ),
        ],
      ),
    );
  }
}

// ============================================
// HOME TAB
// ============================================
class _HomeTab extends StatelessWidget {
  final RentMonth month;
  final UserAccount? currentUser;
  final String Function(int) formatCurrency;
  final DashboardProvider dashboard;

  const _HomeTab({
    required this.month,
    required this.currentUser,
    required this.formatCurrency,
    required this.dashboard,
  });

  @override
  Widget build(BuildContext context) {
    final memberId = currentUser?.memberId;
    final totalOutstanding = dashboard.getUserTotalOutstanding(memberId);
    final recentActivities = dashboard.getRecentActivity(memberId);

    // Calculate overall rent progress
    final totalRent = month.rent;
    final collectedRent = month.rentPayments.fold(0, (sum, p) => sum + p.amountPaid);
    final rentProgress = totalRent > 0 ? collectedRent / totalRent : 0.0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Total Outstanding Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0D7B49),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      "Total Outstanding",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      "Due in 4 days", // TODO: dynamically calculate days until rent due
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatCurrency(totalOutstanding),
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "Rent + Bills",
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to details or scroll to bottom
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0D7B49),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: Text(
                        "View Details",
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                         // Action for Pay Now
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: Text(
                        "Pay Now",
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Quick Actions
        Text(
          "Quick Actions",
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1C1C1E),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _QuickActionCard(
              title: "Pay Rent",
              icon: Icons.home_work_outlined,
              isPrimary: true,
              onTap: () {
              },
            ),
            _QuickActionCard(
              title: "Split Food Bill",
              icon: Icons.restaurant_outlined,
              isPrimary: false,
              iconColor: const Color(0xFF8B5A2B),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScannerScreen()),
                );
              },
            ),
            _QuickActionCard(
              title: "Utilities",
              icon: Icons.bolt_outlined,
              isPrimary: false,
              onTap: () {
              },
            ),
            _QuickActionCard(
              title: "Expenses",
              icon: Icons.receipt_long_outlined,
              isPrimary: false,
              onTap: () {
              },
            ),
          ],
        ),
        const SizedBox(height: 32),
        
        // Status Overview
        Text(
          "Status Overview",
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1C1C1E),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Rent Progress Card
              Container(
                width: 240,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF2F2F7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Rent Progress",
                              style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF8E8E93)),
                            ),
                            Text(
                              "${DateFormat('MMMM').format(month.startsOn)} Rent",
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0D7B49)),
                            ),
                          ],
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 36,
                              height: 36,
                              child: CircularProgressIndicator(
                                value: rentProgress,
                                backgroundColor: const Color(0xFFE3F6F1),
                                color: const Color(0xFF0D7B49),
                                strokeWidth: 4,
                              ),
                            ),
                            Text(
                              "${(rentProgress * 100).round()}%",
                              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF0D7B49)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Collected", style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF1C1C1E))),
                        Text("${formatCurrency(collectedRent)} / ${formatCurrency(totalRent)}", style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: rentProgress,
                      backgroundColor: const Color(0xFFE3F6F1),
                      color: const Color(0xFF0D7B49),
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Savings / Expenses Card placeholder
              Container(
                width: 120,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF2F2F7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFAF1E3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.savings_outlined, color: Color(0xFF8B5A2B), size: 20),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      formatCurrency(month.expenses.fold(0, (sum, e) => sum + e.amount)),
                      style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF8B5A2B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        
        // Recent Activity
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Activity",
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1C1C1E),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                "View All",
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0D7B49)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF2F2F7)),
          ),
          child: recentActivities.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(child: Text("No recent activity.", style: GoogleFonts.inter(color: Colors.grey))),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentActivities.length > 3 ? 3 : recentActivities.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF2F2F7)),
                  itemBuilder: (context, index) {
                    final item = recentActivities[index];
                    
                    Color iconColor = const Color(0xFF0D7B49);
                    Color iconBg = const Color(0xFFE3F6F1);
                    IconData iconData = Icons.home_outlined;
                    
                    if (item['type'] == 'EXPENSE') {
                      iconColor = const Color(0xFF8B5A2B);
                      iconBg = const Color(0xFFFAF1E3);
                      iconData = Icons.shopping_basket_outlined;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: iconBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(iconData, color: iconColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'],
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1C1C1E),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${item['subtitle']} • ${DateFormat('MMMM').format(item['date'])}",
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: const Color(0xFF8E8E93),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "-${formatCurrency(item['amount'])}",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1C1C1E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: item['status'] == 'SETTLED' ? const Color(0xFFE3F6F1) : const Color(0xFFFAF1E3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item['status'].toString().toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: item['status'] == 'SETTLED' ? const Color(0xFF0D7B49) : const Color(0xFF8B5A2B),
                                  ),
                                ),
                              ),
                            ],
                          ),
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

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isPrimary;
  final Color? iconColor;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    this.isPrimary = false,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF0D7B49) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? null : Border.all(color: const Color(0xFFF2F2F7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : (iconColor ?? const Color(0xFF1C1C1E)),
              size: 28,
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isPrimary ? Colors.white : const Color(0xFF1C1C1E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// RENT TAB
// ============================================
class _RentTab extends StatelessWidget {
  final RentMonth month;
  final HouseInfo? house;
  final UserAccount? currentUser;
  final String Function(int) formatCurrency;

  const _RentTab({
    required this.month,
    this.house,
    required this.currentUser,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final selfPayment = month.rentPayments.firstWhere(
      (p) => currentUser != null && p.memberId == currentUser!.memberId,
      orElse: () => month.rentPayments.first, // fallback if admin or not found
    );
    final isAdmin = currentUser?.role == 'ADMIN';
    final isSelfPaymentValid = currentUser != null && currentUser!.memberId != null && selfPayment.memberId == currentUser!.memberId;
    
    final otherPayments = month.rentPayments.where(
      (p) => currentUser == null || p.memberId != currentUser!.memberId
    ).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (isSelfPaymentValid) ...[
          Text(
            "Your Rent Due",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E4620), Color(0xFF2A5C2D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E4620).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(month.startsOn),
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        letterSpacing: 1,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: selfPayment.status == 'PAID' ? Colors.white24 : const Color(0xFFFDE68A).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selfPayment.status.toUpperCase(),
                        style: GoogleFonts.inter(
                          color: selfPayment.status == 'PAID' ? Colors.white : const Color(0xFFFDE68A),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  formatCurrency(selfPayment.amountDue - selfPayment.amountPaid),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${formatCurrency(selfPayment.amountPaid)} paid of ${formatCurrency(selfPayment.amountDue)} total",
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                if (selfPayment.status != 'PAID') ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: Builder(
                      builder: (context) {
                        final hasPendingRequest = selfPayment.transactions.any((t) => t.status == 'SUBMITTED');
                        if (hasPendingRequest) {
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Request Sent - Pending Verification",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }
                        return ElevatedButton(
                          onPressed: () => _showPayRentDialog(context, selfPayment),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1E4620),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text(
                            "Pay Rent Now",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        );
                      }
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],

        if (otherPayments.isNotEmpty || isAdmin) ...[
          Text(
            isSelfPaymentValid ? "Other Residents" : "House Residents",
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
              itemCount: otherPayments.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF2F2F7)),
              itemBuilder: (context, index) {
                final payment = otherPayments[index];
                final hasPendingRequest = payment.transactions.any((t) => t.status == 'SUBMITTED');
                final canPayAsAdmin = isAdmin && payment.status != 'PAID';

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
                            Text(
                              payment.member?.name ?? "Unknown Resident",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1C1C1E),
                              ),
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
                      if (hasPendingRequest) ...[ 
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDE68A).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFDE68A).withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            "PENDING",
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ] else ...[
                        _StatusBadge(status: payment.status),
                        if (canPayAsAdmin) ...[
                          const SizedBox(width: 6),
                          SizedBox(
                            height: 28,
                            child: ElevatedButton(
                              onPressed: () => _showPayRentDialog(context, payment),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E4620),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
                          ),
                        ],
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  void _showPayRentDialog(BuildContext context, RentPayment payment) {
    final amountDue = payment.amountDue - payment.amountPaid;
    bool isUpi = true;
    final methodController = TextEditingController(text: "UPI");

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                "Pay Rent",
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Amount Due: ${formatCurrency(amountDue)}",
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C1E)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text("Pay via UPI"),
                          selected: isUpi,
                          onSelected: (val) => setModalState(() { isUpi = true; methodController.text = "UPI"; }),
                          selectedColor: const Color(0xFFE3F6F1),
                          labelStyle: TextStyle(color: isUpi ? const Color(0xFF1E4620) : Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text("Paid Manually"),
                          selected: !isUpi,
                          onSelected: (val) => setModalState(() { isUpi = false; methodController.text = "Cash"; }),
                          selectedColor: const Color(0xFFE3F6F1),
                          labelStyle: TextStyle(color: !isUpi ? const Color(0xFF1E4620) : Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (isUpi) ...[
                    Text("Owner UPI ID: ${house?.upiId ?? 'Not configured'}", style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF8E8E93))),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: house?.upiId != null ? () async {
                          final upiId = house!.upiId!;
                          final ownerName = house?.ownerName ?? 'House Owner';
                          final uri = Uri.parse("upi://pay?pa=$upiId&pn=$ownerName&am=$amountDue&cu=INR");
                          try {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } catch (e) {
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No UPI app installed on this device.")));
                          }
                        } : null,
                        icon: const Icon(Icons.payment),
                        label: Text("Open GPay / PhonePe", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E4620),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    "After payment, confirm below:",
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  if (!isUpi) ...[
                    TextField(
                      controller: methodController,
                      decoration: InputDecoration(
                        labelText: "Payment Method (Cash/Bank)",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        isDense: true,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: GoogleFonts.inter(color: const Color(0xFF8B2D21))),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final dashboard = context.read<DashboardProvider>();
                    final success = await dashboard.payRent(
                      paymentId: payment.id,
                      amountPaid: amountDue,
                      method: methodController.text.trim(),
                    );

                    if (success && context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Payment marked as pending verification!")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E4620),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text("I Have Paid", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
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
class _SharedBillsTab extends StatelessWidget {
  final RentMonth month;
  final List<Member> members;
  final UserAccount? currentUser;
  final String Function(int) formatCurrency;

  const _SharedBillsTab({
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
                "Utilities & Bills",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1C1C1E),
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
                      final myPayment = utility.payments.where((p) => p.memberId == currentUser?.memberId).firstOrNull;

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
                          "Status: $paidByStr\nYour share: ${myPayment != null ? formatCurrency(myPayment.amountDue) : '₹0'}",
                          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF8E8E93)),
                        ),
                        isThreeLine: true,
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
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Shared Member Expenses",
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

                      final mySplit = expense.splits.where((s) => s.memberId == currentUser?.memberId).firstOrNull;

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
                          "Paid by ${expense.paidBy?.name ?? 'Unknown'}\nYour share: ${mySplit != null ? formatCurrency(mySplit.amount) : '₹0'}",
                          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF8E8E93)),
                        ),
                        isThreeLine: true,
                        trailing: FittedBox(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  formatCurrency(expense.amount),
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1C1C1E),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5E5EA),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "TOTAL",
                                    style: GoogleFonts.inter(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF636366),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Delete Expense"),
                                    content: const Text("Are you sure you want to delete this expense?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                                
                                if (confirm == true && context.mounted) {
                                  final dashboard = context.read<DashboardProvider>();
                                  final success = await dashboard.deleteExpense(expense.id);
                                  if (success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Expense deleted.")),
                                    );
                                  } else if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Failed to delete expense.")),
                                    );
                                  }
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.delete_outline, color: Color(0xFFDC3545), size: 20),
                              ),
                            ),
                          ],
                        ),
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
        bool isSubmitting = false;
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
                    onPressed: isSubmitting ? null : () async {
                      final title = titleController.text.trim();
                      final amt = int.tryParse(amountController.text) ?? 0;
                      if (title.isEmpty || amt <= 0) return;

                      setModalState(() {
                        isSubmitting = true;
                      });

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
                      } else if (context.mounted) {
                        setModalState(() {
                          isSubmitting = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Failed to log expense.")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E4620),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text("Save Expense", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
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
    // Calculate Net Balances for current user
    final Map<String, int> netBalances = {};
    for (final debt in debts) {
      if (debt.status != 'OPEN') continue;
      
      if (debt.creditorId == currentUser?.memberId) {
        // Someone owes currentUser
        netBalances[debt.debtorId] = (netBalances[debt.debtorId] ?? 0) + (debt.amount - debt.settledAmount);
      } else if (debt.debtorId == currentUser?.memberId) {
        // currentUser owes someone
        netBalances[debt.creditorId] = (netBalances[debt.creditorId] ?? 0) - (debt.amount - debt.settledAmount);
      }
    }

    final youOwe = netBalances.entries.where((e) => e.value < 0).toList();
    final peopleOweYou = netBalances.entries.where((e) => e.value > 0).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Balances & Room Settlements",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1C1C1E),
                  ),
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
          const SizedBox(height: 16),

          // Net Balances Summary
          if (currentUser?.memberId != null) ...[
            if (youOwe.isNotEmpty) ...[
              Text("You Owe", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF8B2D21))),
              const SizedBox(height: 8),
              ...youOwe.map((entry) {
                final member = members.firstWhere((m) => m.id == entry.key, orElse: () => Member(id: '', name: 'Unknown', active: false));
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD9D4).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFD9D4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(member.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                      Text(formatCurrency(entry.value.abs()), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF8B2D21))),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            if (peopleOweYou.isNotEmpty) ...[
              Text("People Owe You", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E4620))),
              const SizedBox(height: 8),
              ...peopleOweYou.map((entry) {
                final member = members.firstWhere((m) => m.id == entry.key, orElse: () => Member(id: '', name: 'Unknown', active: false));
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F6F1).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE3F6F1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(member.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                      Text(formatCurrency(entry.value), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF1E4620))),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],
          ],

          Text("Ledger History", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
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

// ============================================
// PROFILE TAB
// ============================================
class _ProfileTab extends StatelessWidget {
  final UserAccount? currentUser;

  const _ProfileTab({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          "Profile & Settings",
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1C1C1E),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E5EA)),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF1E4620),
                child: Text(
                  (currentUser?.email != null && currentUser!.email.isNotEmpty)
                      ? currentUser!.email.substring(0, 1).toUpperCase()
                      : "U",
                  style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                (currentUser?.email != null && currentUser!.email.contains('@'))
                    ? currentUser!.email.split('@')[0]
                    : "Unknown User",
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                currentUser?.email ?? "No email",
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF8E8E93)),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F6F1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  currentUser?.role ?? "MEMBER",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E4620),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Account Options",
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
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFF8B2D21)),
                title: Text("Log Out", style: GoogleFonts.inter(color: const Color(0xFF8B2D21), fontWeight: FontWeight.w600)),
                onTap: () async {
                  await context.read<AuthProvider>().signOut();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
