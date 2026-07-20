import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart' as provider;
import '../../../../providers/dashboard_provider.dart';
import '../../domain/models/expense_assignment.dart';
import '../../domain/models/parsed_receipt.dart';
import '../../providers/parsed_receipt_provider.dart';
import 'bill_review_screen.dart';

class AssignmentScreen extends ConsumerStatefulWidget {
  const AssignmentScreen({super.key});

  @override
  ConsumerState<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends ConsumerState<AssignmentScreen> {
  final List<ExpenseAssignment> _assignments = [];
  final _uuid = const Uuid();

  List<Map<String, String>> _getAllMembers(ParsedReceipt receipt, DashboardProvider dashboard) {
    List<Map<String, String>> all = [];
    
    // Add selected house members
    for (String id in receipt.houseMemberIds) {
      final hm = dashboard.members.firstWhere(
        (m) => m.id == id,
        orElse: () => throw Exception('Member not found'),
      );
      all.add({'id': hm.id, 'name': hm.name, 'isExternal': 'false'});
    }
    
    // Add external members
    for (var em in receipt.externalMembers) {
      all.add({'id': em['id']!, 'name': em['name']!, 'isExternal': 'true'});
    }
    
    return all;
  }

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
  
  void _unassignItem(String itemId, String memberId) {
    setState(() {
      _assignments.removeWhere((a) => a.receiptItemId == itemId && a.memberId == memberId);
    });
  }
  
  void _changeMethod(String itemId, SplitMethod newMethod) {
    setState(() {
      final currentItemAssignments = _assignments.where((a) => a.receiptItemId == itemId).toList();
      for (var a in currentItemAssignments) {
        _assignments.remove(a);
        _assignments.add(a.copyWith(splitMethod: newMethod));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final parsedReceipt = ref.watch(parsedReceiptProvider);
    final dashboardProvider = provider.Provider.of<DashboardProvider>(context);

    if (parsedReceipt == null) {
      return const Scaffold(body: Center(child: Text('No receipt parsed')));
    }
    
    final allMembers = _getAllMembers(parsedReceipt, dashboardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        title: const Text('Assign Items'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: parsedReceipt.items.length,
        itemBuilder: (context, index) {
          final item = parsedReceipt.items[index];
          final itemAssignments = _assignments.where((a) => a.receiptItemId == item.id).toList();
          final currentMethod = itemAssignments.isNotEmpty ? itemAssignments.first.splitMethod : SplitMethod.equal;
          
          return Card(
            elevation: 1,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      Text('₹${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E4620))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Split Method Selector
                  Row(
                    children: [
                      const Text('Split Method:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(width: 8),
                      DropdownButton<SplitMethod>(
                        value: currentMethod,
                        isDense: true,
                        underline: const SizedBox(),
                        items: SplitMethod.values.map((m) {
                          return DropdownMenuItem(
                            value: m,
                            child: Text(m.name.toUpperCase(), style: const TextStyle(fontSize: 12)),
                          );
                        }).toList(),
                        onChanged: (newMethod) {
                          if (newMethod != null) {
                            _changeMethod(item.id, newMethod);
                          }
                        },
                      ),
                    ],
                  ),
                  
                  const Divider(),
                  
                  // Members
                  Wrap(
                    spacing: 8,
                    children: allMembers.map((m) {
                      final isAssigned = _assignments.any((a) => a.receiptItemId == item.id && a.memberId == m['id']!);
                      return FilterChip(
                        label: Text(m['name']!),
                        selected: isAssigned,
                        selectedColor: const Color(0xFF1E4620).withOpacity(0.2),
                        checkmarkColor: const Color(0xFF1E4620),
                        onSelected: (selected) {
                          if (selected) {
                            _assignItem(item.id, m['id']!, currentMethod);
                          } else {
                            _unassignItem(item.id, m['id']!);
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BillReviewScreen(assignments: _assignments)),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1E4620),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Review Bill', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
