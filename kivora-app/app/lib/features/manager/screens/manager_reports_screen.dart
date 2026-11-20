import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/services/kivora_service.dart';

class ManagerReportsScreen extends StatelessWidget {
  const ManagerReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kivora = KivoraService();
    final activeBranchId = kivora.currentBranchId;
    final totalMembers = kivora.members.where((m) => activeBranchId == null || m.branchId == activeBranchId).length;
    final branchRecords = kivora.attendanceRecords.where((r) => activeBranchId == null || r.branchId == activeBranchId).toList();
    final now = DateTime.now();
    final thisMonthRecords = branchRecords.where((r) => r.signInTime.year == now.year && r.signInTime.month == now.month).toList();
    final totalSignIns = thisMonthRecords.length;
    final attendanceRate = totalMembers > 0 && totalSignIns > 0 ? '${((totalSignIns / (totalMembers * 20)).clamp(0.0, 1.0) * 100).toStringAsFixed(0)}%' : (totalMembers > 0 ? '100%' : '0%');
    final lateCount = thisMonthRecords.where((r) => r.signInTime.hour > 9).length;
    final dateRangeStr = DateFormat('MMM 1 – MMM d, yyyy').format(now);

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
          'Reports',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateRangeStr,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2x2 Metrics Cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'Attendance Rate',
                    value: attendanceRate,
                    icon: Icons.pie_chart_outline,
                    color: const Color(0xFF0D9488),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Total Members',
                    value: totalMembers.toString(),
                    icon: Icons.people_outline,
                    color: const Color(0xFF0284C7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'Late Arrivals',
                    value: lateCount.toString(),
                    icon: Icons.access_time,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Total Records',
                    value: totalSignIns.toString(),
                    icon: Icons.verified_outlined,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              'Reports',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),

            // Reports navigation list
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildReportTile(Icons.assignment_outlined, 'Attendance Report'),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildReportTile(Icons.people_outline, 'Member Report'),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildReportTile(Icons.event_note_outlined, 'Leave Report'),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildReportTile(Icons.tune, 'Custom Report'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget _buildReportTile(IconData icon, String title) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDFA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF0D9488), size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Color(0xFFCBD5E1)),
      onTap: () {},
    );
  }
}
