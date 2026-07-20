import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScannerStateNotifier extends Notifier<File?> {
  @override
  File? build() => null;
  
  void setFile(File? file) {
    state = file;
  }
}

final scannerFileProvider = NotifierProvider<ScannerStateNotifier, File?>(
  () => ScannerStateNotifier(),
);
