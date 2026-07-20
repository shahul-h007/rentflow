
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/receipt/ocr_service.dart';
import '../../../../core/parser/regex_receipt_parser.dart';
import '../../providers/scanner_state_provider.dart';
import '../../providers/parsed_receipt_provider.dart';
import 'receipt_review_screen.dart';

class ParsingScreen extends ConsumerStatefulWidget {
  const ParsingScreen({super.key});

  @override
  ConsumerState<ParsingScreen> createState() => _ParsingScreenState();
}

class _ParsingScreenState extends ConsumerState<ParsingScreen> {
  final OCRService _ocrService = OCRService();
  String _statusMessage = 'Extracting text...';
  double _progress = 0.2;

  @override
  void initState() {
    super.initState();
    _processReceipt();
  }

  Future<void> _processReceipt() async {
    try {
      final imageFile = ref.read(scannerFileProvider);
      if (imageFile == null) {
        throw Exception("No receipt image selected.");
      }

      // Step 1: OCR Extraction
      setState(() {
        _statusMessage = 'Reading receipt...';
        _progress = 0.4;
      });
      final rawOcrText = await _ocrService.extractText(imageFile);
      
      // Step 2: Parser Execution
      setState(() {
        _statusMessage = 'Analyzing items...';
        _progress = 0.7;
      });
      
      // Call Parser Engine here (Phase 4)
      final parsedReceipt = RegexReceiptParser.parse(rawOcrText);
      ref.read(parsedReceiptProvider.notifier).setReceipt(parsedReceipt);
      
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _statusMessage = 'Done!';
        _progress = 1.0;
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ReceiptReviewScreen()),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        Navigator.pop(context); // Go back on error
      }
    }
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 32),
              Text(
                _statusMessage,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(value: _progress),
            ],
          ),
        ),
      ),
    );
  }
}
