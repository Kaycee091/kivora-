import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/kivora_service.dart';

class ManagerAttendanceLogsScreen extends StatefulWidget {
  final String branchId;
  const ManagerAttendanceLogsScreen({super.key, this.branchId = 'branch-west'});

  @override
  State<ManagerAttendanceLogsScreen> createState() => _ManagerAttendanceLogsScreenState();
}

class _ManagerAttendanceLogsScreenState extends State<ManagerAttendanceLogsScreen> {
  int _selectedPeriod = 0; // 0: Today, 1: This Week, 2: All Records

  String _formatTime(DateTime dt) {
    final rawHour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final hour = rawHour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final allRecords = KivoraService().attendanceRecords.where((r) => r.branchId == widget.branchId).toList();
    final now = DateTime.now();

    List<AttendanceRecordModel> filteredRecords;
    if (_selectedPeriod == 0) {
      // Today's sign-ins
      filteredRecords = allRecords.where((r) {
        return r.signInTime.year == now.year &&
            r.signInTime.month == now.month &&
            r.signInTime.day == now.day;
      }).toList();
    } else if (_selectedPeriod == 1) {
      // Past 7 days
      final weekAgo = now.subtract(const Duration(days: 7));
      filteredRecords = allRecords.where((r) => r.signInTime.isAfter(weekAgo)).toList();
    } else {
      filteredRecords = allRecords;
    }

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
          'Attendance Logs',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _buildPeriodTab('Today', 0),
                const SizedBox(width: 8),
                _buildPeriodTab('Past 7 Days', 1),
                const SizedBox(width: 8),
                _buildPeriodTab('All Sign-Ins', 2),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Sign-In Count Summary Card (Showing actual sign-ins count, no present/late/absent labels)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDFA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.access_time_filled, color: Color(0xFF0D9488), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${filteredRecords.length} Verified Sign-Ins',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Actual recorded sign-in timestamps. Tap any member to view full profile.',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Actual Sign-Ins List
          Expanded(
            child: filteredRecords.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.event_busy, size: 48, color: Color(0xFF94A3B8)),
                        SizedBox(height: 12),
                        Text(
                          'No sign-in records for this period',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredRecords.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final record = filteredRecords[index];

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(0xFFE0F2F1),
                              child: Text(
                                record.memberName.split(' ').map((n) => n.isNotEmpty ? n[0] : '').join(''),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Clickable Member Name & Sign-in details
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  // Clickable member name opens that member's full identification profile
                                  context.push('/manager/members/${record.memberId}');
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          record.memberName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F172A),
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(Icons.open_in_new, size: 13, color: Color(0xFF0D9488)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 12, color: Color(0xFF64748B)),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatDate(record.signInTime),
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                        ),
                                        const SizedBox(width: 10),
                                        const Icon(Icons.verified_user, size: 12, color: Color(0xFF0D9488)),
                                        const SizedBox(width: 4),
                                        Text(
                                          record.verificationMethod,
                                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Actual Sign-in Time (Formatted timestamp, no present/late/absent labels)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.schedule, size: 13, color: Color(0xFF334155)),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatTime(record.signInTime),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String title, int index) {
    final isSelected = _selectedPeriod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
