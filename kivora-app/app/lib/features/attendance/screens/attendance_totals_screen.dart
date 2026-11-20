import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/kivora_service.dart';

class AttendanceTotalsScreen extends StatefulWidget {
  const AttendanceTotalsScreen({super.key});

  @override
  State<AttendanceTotalsScreen> createState() => _AttendanceTotalsScreenState();
}

class _AttendanceTotalsScreenState extends State<AttendanceTotalsScreen> {
  int _selectedPeriod = 0; // 0: Month, 1: Term, 2: Year
  bool _isLoading = false;
  String? _errorMessage;

  int _daysPresent = 0;
  int _daysAbsent = 0;
  int _halfDays = 0;
  int _totalSessions = 0;
  double _attendanceRate = 0.0;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    final userId = AuthService().currentUserId;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      int present = 0;
      int absent = 0;
      int half = 0;
      int total = 0;

      if (AuthService().isLiveMode && AuthService().checkSupabaseReady() && userId != null) {
        final client = Supabase.instance.client;
        final res = await client
            .from('attendance_records')
            .select('status, overall_verification_status, check_in_time')
            .eq('user_id', userId);

        final records = res as List;
        total = records.length;
        for (final row in records) {
          final status = (row['status'] as String? ?? 'present').toLowerCase();
          if (status == 'present') {
            present++;
          } else if (status == 'absent') {
            absent++;
          } else if (status == 'half_day' || status == 'late') {
            half++;
          }
        }
      } else {
        // Compute from in-memory records
        final records = KivoraService().attendanceRecords.where((r) => userId == null || r.memberId == userId).toList();
        total = records.length;
        present = records.length; // all verified sign-ins are present
      }

      final rate = total > 0 ? (present / total) : 0.0;

      if (mounted) {
        setState(() {
          _daysPresent = present;
          _daysAbsent = absent;
          _halfDays = half;
          _totalSessions = total;
          _attendanceRate = rate;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not calculate attendance totals: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pctString = '${(_attendanceRate * 100).round()}%';

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
          'Attendance Totals',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
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
                          onPressed: _loadMetrics,
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
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Member Info Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: const Color(0xFFE0F2F1),
                              child: Text(
                                KivoraService().currentUserName.isNotEmpty
                                    ? KivoraService().currentUserName.split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join('').toUpperCase()
                                    : 'M',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    KivoraService().currentUserName.isNotEmpty
                                        ? KivoraService().currentUserName
                                        : 'Member',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${KivoraService().currentRole.toUpperCase()} • ${KivoraService().currentBranch?.name ?? "Branch"}',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.3),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Period Selector Tabs
                      Row(
                        children: [
                          _buildPeriodTab('This Month', 0),
                          const SizedBox(width: 10),
                          _buildPeriodTab('This Term', 1),
                          const SizedBox(width: 10),
                          _buildPeriodTab('This Year', 2),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Circular Rate Gauge Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 140,
                                    height: 140,
                                    child: CircularProgressIndicator(
                                      value: _attendanceRate > 0 ? _attendanceRate : 0.001,
                                      strokeWidth: 12,
                                      backgroundColor: const Color(0xFFE2E8F0),
                                      color: const Color(0xFF0D9488),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        pctString,
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      const Text(
                                        'Attendance Rate',
                                        style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Legend (Computed directly from genuine records)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildLegendItem('$_daysPresent', 'Days Present', const Color(0xFF059669)),
                                _buildLegendItem('$_daysAbsent', 'Days Absent', const Color(0xFFEF4444)),
                                _buildLegendItem('$_halfDays', 'Half Day', const Color(0xFFF59E0B)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Total Sessions Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDFA),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.class_outlined, color: Color(0xFF0D9488)),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Sessions',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                                Text(
                                  '$_totalSessions',
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPeriodTab(String title, int index) {
    final isSelected = _selectedPeriod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0D9488) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0)),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String count, String label, Color color) {
    return Column(
      children: [
        Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
      ],
    );
  }
}
