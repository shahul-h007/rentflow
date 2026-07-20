import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/receipt/scanner_service.dart';
import '../../providers/scanner_state_provider.dart';
import 'parsing_screen.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final ScannerService _scannerService = ScannerService();
  bool _isLoading = false;

  Future<void> _pickImage(bool fromCamera) async {
    setState(() => _isLoading = true);
    try {
      final File? image = fromCamera 
        ? await _scannerService.pickImageFromCamera()
        : await _scannerService.pickImageFromGallery();
        
      if (image != null) {
        ref.read(scannerFileProvider.notifier).setFile(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _removeImage() {
    ref.read(scannerFileProvider.notifier).setFile(null);
  }

  void _proceedToOCR() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ParsingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedFile = ref.watch(scannerFileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Receipt'),
        actions: [
          if (selectedFile != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _proceedToOCR,
            )
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : selectedFile == null 
              ? _buildPickerUI() 
              : _buildPreviewUI(selectedFile),
    );
  }

  Widget _buildPickerUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          const Text(
            'Upload a Restaurant Receipt',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please ensure the total and items are visible.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImage(true),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () => _pickImage(false),
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPreviewUI(File file) {
    return Column(
      children: [
        Expanded(
          child: InteractiveViewer(
            child: Image.file(
              file,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _removeImage,
                    child: const Text('Retake'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _proceedToOCR,
                    child: const Text('Process Receipt'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
