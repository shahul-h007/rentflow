import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/receipt_provider.dart';
import '../../domain/models/parsed_receipt.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late Future<List<ParsedReceipt>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  void _fetchHistory() {
    _historyFuture = ref.read(receiptRepositoryProvider).getReceiptHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _fetchHistory();
              });
            },
          )
        ],
      ),
      body: FutureBuilder<List<ParsedReceipt>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading history: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No receipts found.\nScan a receipt to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final receipts = snapshot.data!;
          return ListView.builder(
            itemCount: receipts.length,
            itemBuilder: (context, index) {
              final receipt = receipts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.receipt, color: Colors.white),
                  ),
                  title: Text(receipt.merchant ?? 'Unknown Merchant'),
                  subtitle: Text(receipt.date ?? 'Unknown Date'),
                  trailing: Text(
                    '₹${receipt.grandTotal?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onTap: () {
                    // TODO: Navigate to Receipt Detail Screen
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate back to Scanner
          Navigator.pop(context);
        },
        label: const Text('Scan New'),
        icon: const Icon(Icons.camera_alt),
      ),
    );
  }
}
