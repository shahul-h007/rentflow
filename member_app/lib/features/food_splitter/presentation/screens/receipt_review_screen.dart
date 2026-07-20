import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/parsed_receipt_provider.dart';
import 'assignment_screen.dart';

class ReceiptReviewScreen extends ConsumerStatefulWidget {
  const ReceiptReviewScreen({super.key});

  @override
  ConsumerState<ReceiptReviewScreen> createState() => _ReceiptReviewScreenState();
}

class _ReceiptReviewScreenState extends ConsumerState<ReceiptReviewScreen> {
  Future<void> _editMerchant(BuildContext context, String? currentMerchant) async {
    final controller = TextEditingController(text: currentMerchant);
    final newMerchant = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Merchant'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Merchant Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Save')),
        ],
      ),
    );
    if (newMerchant != null && newMerchant.isNotEmpty) {
      final current = ref.read(parsedReceiptProvider);
      if (current != null) {
        ref.read(parsedReceiptProvider.notifier).setReceipt(current.copyWith(merchant: newMerchant));
      }
    }
  }

  Future<void> _editItem(BuildContext context, int index) async {
    final current = ref.read(parsedReceiptProvider);
    if (current == null) return;
    
    final item = current.items[index];
    final nameCtrl = TextEditingController(text: item.name);
    final qtyCtrl = TextEditingController(text: item.quantity.toString());
    final priceCtrl = TextEditingController(text: item.unitPrice.toString());

    final updated = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Item Name')),
            Row(
              children: [
                Expanded(child: TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Unit Price'), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );

    if (updated == true) {
      final qty = int.tryParse(qtyCtrl.text) ?? 1;
      final price = double.tryParse(priceCtrl.text) ?? 0.0;
      final newItem = item.copyWith(
        name: nameCtrl.text,
        quantity: qty,
        unitPrice: price,
        totalPrice: qty * price,
      );
      
      final newItems = List.of(current.items);
      newItems[index] = newItem;
      
      ref.read(parsedReceiptProvider.notifier).setReceipt(current.copyWith(items: newItems));
    }
  }

  Future<void> _editTotal(BuildContext context, String label, double currentValue, Function(double) onSave) async {
    final controller = TextEditingController(text: currentValue.toString());
    final newValue = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Save')),
        ],
      ),
    );
    
    if (newValue != null && newValue.isNotEmpty) {
      final parsed = double.tryParse(newValue);
      if (parsed != null) {
        onSave(parsed);
      }
    }
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
        title: const Text('Review Receipt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AssignmentScreen()),
              );
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Merchant Info
          Card(
            child: ListTile(
              title: const Text('Merchant'),
              subtitle: Text(parsedReceipt.merchant ?? 'Unknown Merchant'),
              trailing: IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => _editMerchant(context, parsedReceipt.merchant),
              ),
            ),
          ),
          
          // Items List
          const SizedBox(height: 16),
          const Text('Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...parsedReceipt.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Card(
              child: ListTile(
                title: Text(item.name),
                subtitle: Text('Qty: ${item.quantity}  @ ₹${item.unitPrice.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('₹${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: () => _editItem(context, index),
                    ),
                  ],
                ),
              ),
            );
          }),

          // Totals
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTotalRow('GST', parsedReceipt.gst ?? 0.0, onEdit: () {
                    _editTotal(context, 'GST', parsedReceipt.gst ?? 0.0, (val) {
                      ref.read(parsedReceiptProvider.notifier).setReceipt(parsedReceipt.copyWith(gst: val));
                    });
                  }),
                  const Divider(),
                  _buildTotalRow('Grand Total', parsedReceipt.grandTotal ?? 0.0, isBold: true, onEdit: () {
                    _editTotal(context, 'Grand Total', parsedReceipt.grandTotal ?? 0.0, (val) {
                      ref.read(parsedReceiptProvider.notifier).setReceipt(parsedReceipt.copyWith(grandTotal: val));
                    });
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isBold = false, VoidCallback? onEdit}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Row(
          children: [
            Text('₹${amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
            if (onEdit != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onEdit,
              )
            ]
          ],
        ),
      ],
    );
  }
}
