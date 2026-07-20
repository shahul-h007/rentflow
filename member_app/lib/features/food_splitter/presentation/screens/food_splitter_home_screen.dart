import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'manual_bill_entry_screen.dart';

class FoodSplitterHomeScreen extends StatelessWidget {
  const FoodSplitterHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        title: const Text('Food Splitter'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E4620)),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1E4620),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'How would you like to add the bill?',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E4620),
              ),
            ),
            const SizedBox(height: 32),
            _buildOptionCard(
              context: context,
              title: 'Manual Entry',
              description: 'Create a new bill by manually entering items, taxes, and assigning them to members.',
              icon: Icons.edit_document,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ManualBillEntryScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context: context,
              title: 'Scan Receipt',
              description: 'Automatically scan and split a restaurant receipt.',
              icon: Icons.document_scanner,
              badge: 'Coming Soon',
              isEnabled: false,
              onTap: null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    String? badge,
    bool isEnabled = true,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: isEnabled ? 2 : 0,
      color: isEnabled ? Colors.white : Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isEnabled
            ? BorderSide.none
            : BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isEnabled
                      ? const Color(0xFF1E4620).withOpacity(0.1)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: isEnabled ? const Color(0xFF1E4620) : Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isEnabled
                                ? const Color(0xFF1E4620)
                                : Colors.grey,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badge,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isEnabled
                            ? const Color(0xFF8E8E93)
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isEnabled)
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF1E4620),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
