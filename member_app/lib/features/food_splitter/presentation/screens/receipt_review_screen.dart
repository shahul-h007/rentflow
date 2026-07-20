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
                onPressed: () {}, // TODO: Edit merchant
              ),
            ),
          ),
          
          // Items List
          const SizedBox(height: 16),
          const Text('Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...parsedReceipt.items.map((item) {
            return Card(
              child: ListTile(
                title: Text(item.name),
                subtitle: Text('Qty: ${item.quantity}  @ ₹${item.unitPrice.toStringAsFixed(2)}'),
                trailing: Text('₹${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  _buildTotalRow('GST', parsedReceipt.gst ?? 0.0),
                  const Divider(),
                  _buildTotalRow('Grand Total', parsedReceipt.grandTotal ?? 0.0, isBold: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text('₹${amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}
