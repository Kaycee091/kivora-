import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/kivora_service.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadAttendanceHistory();
  }

  Future<void> _loadAttendanceHistory() async {
    final userId = AuthService().currentUserId;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<Map<String, dynamic>> items = [];

      if (AuthService().isLiveMode && AuthService().checkSupabaseReady() && userId != null) {
        final client = Supabase.instance.client;
        final res = await client
            .from('attendance_records')
            .select('id, check_in_time, check_out_time, status, overall_verification_status, schedule_sessions(id, title, start_time, end_time)')
            .eq('user_id', userId)
            .order('check_in_time', ascending: false);

        for (final row in (res as List)) {
          final session = row['schedule_sessions'] as Map<String, dynamic>?;
          final title = session?['title'] as String? ?? 'Verified Session';
          final checkIn = DateTime.tryParse(row['check_in_time']?.toString() ?? '');
          final timeStr = checkIn != null ? _formatRecordTime(checkIn) : 'Recorded';
          final status = (row['status']?.toString() ?? 'present').toUpperCase();

          items.add({
            'id': row['id']?.toString() ?? '',
            'title': title,
            'time': timeStr,
            'status': status == 'PRESENT' ? 'Present' : (status == 'LATE' ? 'Late' : 'Absent'),
            'isVerified': row['overall_verification_status'] == 'passed',
          });
        }
      }

      // Also incorporate in-memory records from this active session for the authenticated user
      final localRecords = KivoraService().attendanceRecords.where((r) => userId == null || r.memberId == userId).toList();
      for (final rec in localRecords) {
        if (!items.any((i) => i['id'] == rec.id)) {
          final hour = rec.signInTime.hour % 12 == 0 ? 12 : rec.signInTime.hour % 12;
          final ampm = rec.signInTime.hour >= 12 ? 'PM' : 'AM';
          final min = rec.signInTime.minute.toString().padLeft(2, '0');
          items.insert(0, {
            'id': rec.id,
            'title': 'Session Check-In',
            'time': '$hour:$min $ampm (${rec.verificationMethod})',
            'status': 'Present',
            'isVerified': true,
          });
        }
      }

      if (mounted) {
        setState(() {
          _sessions = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[Kivora] Error loading attendance history: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load attendance records: $e';
        });
      }
    }
  }

  String _formatRecordTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateDisplay = 'Today, ${now.day} ${months[now.month - 1]} ${now.year}';

    final presentCount = _sessions.where((s) => s['status'] == 'Present').length;
    final totalCount = _sessions.length;
    final percentage = totalCount > 0 ? ((presentCount / totalCount) * 100).round() : 0;

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
          'Attendance History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Color(0xFF64748B)),
            onPressed: () => context.push('/member/schedule'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off, size: 48, color: Color(0xFFEF4444)),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadAttendanceHistory,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Retry Connection'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D9488),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAttendanceHistory,
                  color: const Color(0xFF0D9488),
                  child: _sessions.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 120),
                            Center(
                              child: Column(
                                children: [
                                  Icon(Icons.event_busy, size: 48, color: Color(0xFF94A3B8)),
                                  SizedBox(height: 12),
                                  Text(
                                    'No attendance records found',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Your check-in records will appear here after verification.',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              // Date Switcher Header
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Icon(Icons.chevron_left, color: Color(0xFF64748B)),
                                    Text(
                                      dateDisplay,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: Color(0xFF64748B)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECFDF5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '$percentage%',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF059669),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Session List
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _sessions.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final s = _sessions[index];
                                  final isPresent = s['status'] == 'Present';

                                  return GestureDetector(
                                    onTap: () => context.push('/member/attendance/records/${s['id']}'),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF0FDFA),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(Icons.calendar_today_outlined, color: Color(0xFF0D9488), size: 20),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  s['title'] as String,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF0F172A),
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  s['time'] as String,
                                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: isPresent ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              s['status'] as String,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isPresent ? const Color(0xFF059669) : const Color(0xFFD97706),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 24),

                              // Progress Bar
                              Container(
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
                                        const Text(
                                          'Session Progress',
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                        ),
                                        Text(
                                          '$presentCount/$totalCount Sessions',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: totalCount > 0 ? (presentCount / totalCount).clamp(0.0, 1.0) : 0.0,
                                        minHeight: 8,
                                        backgroundColor: const Color(0xFFE2E8F0),
                                        color: const Color(0xFF0D9488),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
    );
  }
}
