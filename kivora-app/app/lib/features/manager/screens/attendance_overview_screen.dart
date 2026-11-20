import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/services/kivora_service.dart';

class AttendanceOverviewScreen extends StatelessWidget {
  const AttendanceOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kivora = KivoraService();
    final activeBranchId = kivora.currentBranchId;
    final branchRecords = kivora.attendanceRecords.where((r) => activeBranchId == null || r.branchId == activeBranchId).toList();
    final now = DateTime.now();
    final todayRecords = branchRecords.where((r) => r.signInTime.year == now.year && r.signInTime.month == now.month && r.signInTime.day == now.day).toList();
    final presentCount = todayRecords.length;
    final totalMembers = kivora.members.where((m) => activeBranchId == null || m.branchId == activeBranchId).length;
    final absentCount = (totalMembers - presentCount).clamp(0, totalMembers);
    final lateCount = todayRecords.where((r) => r.signInTime.hour > 9).length;
    final double attendancePct = totalMembers > 0 ? (presentCount / totalMembers).clamp(0.0, 1.0) : 0.0;
    final String pctStr = '${(attendancePct * 100).toStringAsFixed(0)}%';
    final todayStr = DateFormat('MMM d, yyyy').format(now);

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
          'Attendance Overview',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date picker
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
                  Text(todayStr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const Icon(Icons.calendar_month, color: Color(0xFF0D9488), size: 20),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Attendance Gauge Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: attendancePct > 0 ? attendancePct : 0.001,
                            strokeWidth: 10,
                            backgroundColor: const Color(0xFFE2E8F0),
                            color: const Color(0xFF0D9488),
                          ),
                        ),
                        Text(pctStr, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStat(presentCount.toString(), 'Present', const Color(0xFF10B981)),
                        const SizedBox(height: 8),
                        _buildStat(lateCount.toString(), 'Late', const Color(0xFFF59E0B)),
                        const SizedBox(height: 8),
                        _buildStat(absentCount.toString(), 'Absent', const Color(0xFFEF4444)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Active Members Breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 14),

            // Progress by role
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildRoleBar('All Members', '$presentCount/$totalMembers', pctStr, attendancePct),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String count, String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(count, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildRoleBar(String role, String count, String pct, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(role, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            Text('$count  $pct', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: const Color(0xFFE2E8F0),
            color: const Color(0xFF0D9488),
          ),
        ),
      ],
    );
  }
}
