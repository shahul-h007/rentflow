import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart' as provider;
import '../../../../providers/dashboard_provider.dart';
import '../../domain/models/parsed_receipt.dart';
import '../../domain/models/receipt_item.dart';
import '../../providers/parsed_receipt_provider.dart';
import 'assignment_screen.dart';

class ManualBillEntryScreen extends ConsumerStatefulWidget {
  const ManualBillEntryScreen({super.key});

  @override
  ConsumerState<ManualBillEntryScreen> createState() => _ManualBillEntryScreenState();
}

class _ManualBillEntryScreenState extends ConsumerState<ManualBillEntryScreen> {
  final _uuid = const Uuid();
  
  final _restaurantController = TextEditingController();
  final _discountController = TextEditingController();
  final _tipController = TextEditingController();
  final _deliveryController = TextEditingController();
  final _packingController = TextEditingController();
  final _roundOffController = TextEditingController();

  List<ReceiptItem> _items = [];
  
  // GST Section (0: No GST, 1: GST, 2: CGST+SGST)
  int _gstOption = 0;
  final _gstController = TextEditingController();
  final _cgstController = TextEditingController();
  final _sgstController = TextEditingController();

  List<String> _selectedHouseMemberIds = [];
  List<Map<String, String>> _externalMembers = [];

  @override
  void initState() {
    super.initState();
    // Add listeners to auto-recalculate total when optional charges change
    _discountController.addListener(() => setState(() {}));
    _tipController.addListener(() => setState(() {}));
    _deliveryController.addListener(() => setState(() {}));
    _packingController.addListener(() => setState(() {}));
    _roundOffController.addListener(() => setState(() {}));
    _gstController.addListener(() => setState(() {}));
    _cgstController.addListener(() => setState(() {}));
    _sgstController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _restaurantController.dispose();
    _discountController.dispose();
    _tipController.dispose();
    _deliveryController.dispose();
    _packingController.dispose();
    _roundOffController.dispose();
    _gstController.dispose();
    _cgstController.dispose();
    _sgstController.dispose();
    super.dispose();
  }

  double _parseAmt(TextEditingController ctrl) {
    return double.tryParse(ctrl.text) ?? 0.0;
  }

  double get _subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get _gstAmount {
    if (_gstOption == 1) {
      // Treat as direct amount or percentage? User said "GST % [18] or GST amount"
      // Let's assume they enter exact amount for simplicity as discussed
      return _parseAmt(_gstController);
    } else if (_gstOption == 2) {
      return _parseAmt(_cgstController) + _parseAmt(_sgstController);
    }
    return 0.0;
  }

  double get _grandTotal {
    return _subtotal +
        _gstAmount +
        _parseAmt(_deliveryController) +
        _parseAmt(_packingController) +
        _parseAmt(_tipController) -
        _parseAmt(_discountController) +
        _parseAmt(_roundOffController);
  }

  void _showAddItemDialog({ReceiptItem? existingItem, int? index}) {
    final nameCtrl = TextEditingController(text: existingItem?.name);
    final qtyCtrl = TextEditingController(text: existingItem?.quantity.toString() ?? '1');
    final priceCtrl = TextEditingController(text: existingItem?.unitPrice.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existingItem == null ? 'Add Item' : 'Edit Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Item Name'),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: qtyCtrl,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: priceCtrl,
                    decoration: const InputDecoration(labelText: 'Unit Price (₹)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
              final qty = double.tryParse(qtyCtrl.text) ?? 1.0;
              final price = double.tryParse(priceCtrl.text) ?? 0.0;
              
              final newItem = ReceiptItem(
                id: existingItem?.id ?? _uuid.v4(),
                name: nameCtrl.text,
                quantity: qty,
                unitPrice: price,
                totalPrice: qty * price,
              );

              setState(() {
                if (index != null) {
                  _items[index] = newItem;
                } else {
                  _items.add(newItem);
                }
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddExternalPersonDialog() {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add External Person'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'e.g. Arjun',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _externalMembers.add({
                    'id': _uuid.v4(),
                    'name': nameCtrl.text.trim(),
                  });
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _proceedToAssignment() {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }
    if (_selectedHouseMemberIds.isEmpty && _externalMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one person who ate')),
      );
      return;
    }

    final restaurantName = _restaurantController.text.trim().isEmpty 
        ? 'Food Bill #${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'
        : _restaurantController.text.trim();

    final parsedReceipt = ParsedReceipt(
      id: _uuid.v4(),
      merchant: restaurantName,
      items: _items,
      subtotal: _subtotal,
      gst: _gstAmount,
      discount: _parseAmt(_discountController),
      tip: _parseAmt(_tipController),
      deliveryCharge: _parseAmt(_deliveryController),
      roundOff: _parseAmt(_roundOffController),
      grandTotal: _grandTotal,
      houseMemberIds: _selectedHouseMemberIds,
      externalMembers: _externalMembers,
    );

    ref.read(parsedReceiptProvider.notifier).setReceipt(parsedReceipt);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AssignmentScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = provider.Provider.of<DashboardProvider>(context);
    final houseMembers = dashboardProvider.members;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        title: const Text('Manual Food Bill'),
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
          // 1. Restaurant Name
          _buildSectionCard(
            title: 'Restaurant (Optional)',
            child: TextField(
              controller: _restaurantController,
              decoration: const InputDecoration(
                hintText: 'Restaurant #001',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Items
          _buildSectionCard(
            title: 'Items',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No items added yet.',
                      style: TextStyle(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ..._items.asMap().entries.map((e) {
                  final index = e.key;
                  final item = e.value;
                  return Card(
                    elevation: 0,
                    color: Colors.grey.shade50,
                    child: ListTile(
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Qty: ${item.quantity.toStringAsFixed(1)} @ ₹${item.unitPrice.toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('₹${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                            onPressed: () => _showAddItemDialog(existingItem: item, index: index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _items.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _showAddItemDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E4620),
                    side: const BorderSide(color: Color(0xFF1E4620)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. GST Section
          _buildSectionCard(
            title: 'GST Section',
            child: Column(
              children: [
                RadioListTile<int>(
                  title: const Text('No GST'),
                  value: 0,
                  groupValue: _gstOption,
                  onChanged: (v) => setState(() => _gstOption = v!),
                  contentPadding: EdgeInsets.zero,
                  activeColor: const Color(0xFF1E4620),
                ),
                RadioListTile<int>(
                  title: const Text('GST'),
                  value: 1,
                  groupValue: _gstOption,
                  onChanged: (v) => setState(() => _gstOption = v!),
                  contentPadding: EdgeInsets.zero,
                  activeColor: const Color(0xFF1E4620),
                ),
                if (_gstOption == 1)
                  Padding(
                    padding: const EdgeInsets.only(left: 32, bottom: 8),
                    child: TextField(
                      controller: _gstController,
                      decoration: const InputDecoration(labelText: 'GST Amount (₹)', isDense: true, border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                RadioListTile<int>(
                  title: const Text('CGST + SGST'),
                  value: 2,
                  groupValue: _gstOption,
                  onChanged: (v) => setState(() => _gstOption = v!),
                  contentPadding: EdgeInsets.zero,
                  activeColor: const Color(0xFF1E4620),
                ),
                if (_gstOption == 2)
                  Padding(
                    padding: const EdgeInsets.only(left: 32, bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _cgstController,
                            decoration: const InputDecoration(labelText: 'CGST Amount (₹)', isDense: true, border: OutlineInputBorder()),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _sgstController,
                            decoration: const InputDecoration(labelText: 'SGST Amount (₹)', isDense: true, border: OutlineInputBorder()),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Optional Charges
          Card(
            elevation: 1,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              title: const Text('Additional Charges', style: TextStyle(fontWeight: FontWeight.bold)),
              childrenPadding: const EdgeInsets.all(16),
              children: [
                _buildAmountField('Discount (₹)', _discountController),
                const SizedBox(height: 12),
                _buildAmountField('Tip (₹)', _tipController),
                const SizedBox(height: 12),
                _buildAmountField('Delivery Charge (₹)', _deliveryController),
                const SizedBox(height: 12),
                _buildAmountField('Packing Charge (₹)', _packingController),
                const SizedBox(height: 12),
                _buildAmountField('Round Off (₹)', _roundOffController),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 5. Grand Total (Read-only)
          _buildSectionCard(
            title: 'Grand Total',
            child: Column(
              children: [
                _buildTotalRow('Subtotal', _subtotal),
                if (_gstAmount > 0) _buildTotalRow('GST', _gstAmount),
                if (_parseAmt(_discountController) > 0) _buildTotalRow('Discount', -_parseAmt(_discountController)),
                if (_parseAmt(_tipController) > 0) _buildTotalRow('Tip', _parseAmt(_tipController)),
                if (_parseAmt(_deliveryController) > 0) _buildTotalRow('Delivery', _parseAmt(_deliveryController)),
                if (_parseAmt(_packingController) > 0) _buildTotalRow('Packing', _parseAmt(_packingController)),
                if (_parseAmt(_roundOffController) != 0) _buildTotalRow('Round Off', _parseAmt(_roundOffController)),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Grand Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('₹${_grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E4620))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 6. Members
          _buildSectionCard(
            title: 'People Who Ate',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // House Members
                ...houseMembers.map((m) {
                  final isSelected = _selectedHouseMemberIds.contains(m.id);
                  return CheckboxListTile(
                    title: Text(m.name),
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedHouseMemberIds.add(m.id);
                        } else {
                          _selectedHouseMemberIds.remove(m.id);
                        }
                      });
                    },
                    activeColor: const Color(0xFF1E4620),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }),
                
                // External Members
                ..._externalMembers.map((em) {
                  return CheckboxListTile(
                    title: Row(
                      children: [
                        Text(em['name']!),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('External', style: TextStyle(fontSize: 10, color: Colors.orange.shade800)),
                        ),
                      ],
                    ),
                    value: true, // Always true if it exists in the list for this session
                    onChanged: (val) {
                      if (val == false) {
                        setState(() {
                          _externalMembers.removeWhere((e) => e['id'] == em['id']);
                        });
                      }
                    },
                    activeColor: const Color(0xFF1E4620),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }),
                
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _showAddExternalPersonDialog,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add External Person'),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF1E4620)),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Proceed Button
          FilledButton(
            onPressed: _proceedToAssignment,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1E4620),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Proceed to Assignment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
    );
  }

  Widget _buildTotalRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text('₹${amount.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}
