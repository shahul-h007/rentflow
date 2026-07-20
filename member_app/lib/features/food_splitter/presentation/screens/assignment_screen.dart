import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/calculation/calculation_engine.dart';
import '../../domain/models/expense_assignment.dart';
import '../../domain/models/parsed_receipt.dart';
import '../../providers/parsed_receipt_provider.dart';
import '../../providers/receipt_provider.dart';

class AssignmentScreen extends ConsumerStatefulWidget {
  const AssignmentScreen({super.key});

  @override
  ConsumerState<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends ConsumerState<AssignmentScreen> {
  final List<ExpenseAssignment> _assignments = [];
  final _uuid = const Uuid();

  // Mock members for now (Phase 6 UI mock)
  final List<Map<String, String>> _houseMembers = [
    {'id': 'm1', 'name': 'Alice'},
    {'id': 'm2', 'name': 'Bob'},
    {'id': 'm3', 'name': 'Charlie'},
  ];

  void _assignItem(String itemId, String memberId, SplitMethod method) {
    setState(() {
      _assignments.removeWhere((a) => a.receiptItemId == itemId && a.memberId == memberId);
      _assignments.add(ExpenseAssignment(
        id: _uuid.v4(),
        receiptItemId: itemId,
        memberId: memberId,
        splitMethod: method,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final parsedReceipt = ref.watch(parsedReceiptProvider);

    if (parsedReceipt == null) {
      return const Scaffold(
        body: Center(child: Text('No receipt parsed')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate),
            onPressed: () => _showCalculationPreview(context, parsedReceipt),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: parsedReceipt.items.length,
        itemBuilder: (context, index) {
          final item = parsedReceipt.items[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      const SizedBox(width: 8),
                      Text('₹${item.totalPrice.toStringAsFixed(2)}'),
                    ],
                  ),
                  const Divider(),
                  Wrap(
                    spacing: 8,
                    children: _houseMembers.map((m) {
                      final isAssigned = _assignments.any((a) => a.receiptItemId == item.id && a.memberId == m['id']!);
                      return FilterChip(
                        label: Text(m['name']!),
                        selected: isAssigned,
                        onSelected: (selected) {
                          if (selected) {
                            _assignItem(item.id, m['id']!, SplitMethod.equal);
                          } else {
                            setState(() {
                              _assignments.removeWhere((a) => a.receiptItemId == item.id && a.memberId == m['id']!);
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCalculationPreview(context, parsedReceipt),
        label: const Text('Calculate'),
        icon: const Icon(Icons.check),
      ),
    );
  }

  void _showCalculationPreview(BuildContext context, ParsedReceipt receipt) {
    final result = CalculationEngine.calculate(receipt: receipt, assignments: _assignments);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Calculation Preview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (!result.isValid)
                const Text('Errors detected!', style: TextStyle(color: Colors.red)),
              ...result.members.map((m) {
                final name = _houseMembers.firstWhere((hm) => hm['id'] == m.memberId, orElse: () => {'name': m.memberId})['name'];
                return ListTile(
                  title: Text(name!),
                  subtitle: Text('Food: ₹${m.food.toStringAsFixed(2)} | Tax: ₹${m.gst.toStringAsFixed(2)}'),
                  trailing: Text('₹${m.finalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                );
              }),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    try {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(child: CircularProgressIndicator()),
                      );
                      
                      await ref.read(receiptRepositoryProvider).saveExpense(
                        receipt: receipt,
                        assignments: _assignments,
                      );
                      
                      if (context.mounted) {
                        Navigator.pop(context); // pop loading
                        Navigator.pop(context); // pop bottom sheet
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Saved successfully!')),
                        );
                        // Navigate back to home or history
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
                  child: const Text('Confirm & Save'),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
