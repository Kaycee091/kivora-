import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AttendanceRecordDetailScreen extends StatelessWidget {
  final String recordId;
  const AttendanceRecordDetailScreen({super.key, this.recordId = 'rec-001'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Record Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Main Record Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Status Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Color(0xFF059669), size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Present',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Key Details Rows
                  _buildDetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: 'Today, 25 Apr 2025',
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  _buildDetailRow(
                    icon: Icons.login_outlined,
                    label: 'Check-in Time',
                    value: '08:02 AM',
                    valueColor: const Color(0xFF0D9488),
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  _buildDetailRow(
                    icon: Icons.logout_outlined,
                    label: 'Check-out Time',
                    value: '04:15 PM',
                    valueColor: const Color(0xFF0D9488),
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  _buildDetailRow(
                    icon: Icons.timelapse_outlined,
                    label: 'Duration',
                    value: '8h 13m',
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  _buildDetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    value: 'Main Campus',
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  _buildDetailRow(
                    icon: Icons.verified_user_outlined,
                    label: 'Verification Method',
                    value: 'Biometric • GPS • Wi-Fi',
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  _buildDetailRow(
                    icon: Icons.notes_outlined,
                    label: 'Notes',
                    value: 'No additional notes',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Report Issue link
            TextButton.icon(
              onPressed: () => context.push('/member/requests/correction/new'),
              icon: const Icon(Icons.help_outline, size: 18, color: Color(0xFF64748B)),
              label: const Text(
                'Have an issue with this record? Request correction',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color valueColor = const Color(0xFF0F172A),
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: valueColor),
        ),
      ],
    );
  }
}
