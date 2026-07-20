import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart' as provider;
import '../../../../providers/dashboard_provider.dart';
import '../../../../core/calculation/calculation_engine.dart';
import '../../domain/models/expense_assignment.dart';
import '../../providers/parsed_receipt_provider.dart';
import '../../providers/receipt_provider.dart';

class BillReviewScreen extends ConsumerStatefulWidget {
  final List<ExpenseAssignment> assignments;
  const BillReviewScreen({super.key, required this.assignments});

  @override
  ConsumerState<BillReviewScreen> createState() => _BillReviewScreenState();
}

class _BillReviewScreenState extends ConsumerState<BillReviewScreen> {
  String _getPayerId(DashboardProvider dashboard) {
    // For MVP: assume the current logged-in member paid the whole bill
    // In a future update, we can add a "Who Paid?" selector here.
    return dashboard.members.first.id; // Just taking the first for MVP
  }

  @override
  Widget build(BuildContext context) {
    final parsedReceipt = ref.watch(parsedReceiptProvider);
    final dashboardProvider = provider.Provider.of<DashboardProvider>(context);

    if (parsedReceipt == null) {
      return const Scaffold(body: Center(child: Text('No receipt parsed')));
    }

    final result = CalculationEngine.calculate(receipt: parsedReceipt, assignments: widget.assignments);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        title: const Text('Review & Settlement'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E4620)),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1E4620),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Warning if invalid
          if (!result.isValid)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.red.shade100,
              child: const Text(
                'Warning: The calculation has errors. Some items may not be fully assigned.',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            
          const SizedBox(height: 16),
          
          Text('Final Breakdown', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          ...result.members.map((m) {
            String name = m.memberId;
            // Lookup name
            try {
              name = dashboardProvider.members.firstWhere((hm) => hm.id == m.memberId).name;
            } catch (e) {
              // Might be external
              try {
                name = parsedReceipt.externalMembers.firstWhere((em) => em['id'] == m.memberId)['name']!;
              } catch (_) {}
            }
            
            return Card(
              elevation: 1,
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('₹${m.finalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E4620))),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Food:', style: TextStyle(color: Colors.grey)),
                        Text('₹${m.food.toStringAsFixed(2)}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tax/Charges:', style: TextStyle(color: Colors.grey)),
                        Text('₹${(m.gst + m.serviceCharge + m.delivery + m.tip + m.roundOff).toStringAsFixed(2)}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Discounts:', style: TextStyle(color: Colors.grey)),
                        Text('-₹${m.discount.toStringAsFixed(2)}'),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          
          const SizedBox(height: 32),
          
          FilledButton(
            onPressed: () async {
              try {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );
                
                await ref.read(receiptRepositoryProvider).saveExpense(
                  receipt: parsedReceipt,
                  assignments: widget.assignments,
                );
                
                if (context.mounted) {
                  Navigator.pop(context); // pop loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Expense Saved successfully!')),
                  );
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // pop loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving: $e')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1E4620),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save Expense', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}
