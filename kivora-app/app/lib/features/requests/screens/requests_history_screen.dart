import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';

class RequestsHistoryScreen extends StatefulWidget {
  const RequestsHistoryScreen({super.key});

  @override
  State<RequestsHistoryScreen> createState() => _RequestsHistoryScreenState();
}

class _RequestsHistoryScreenState extends State<RequestsHistoryScreen> {
  int _selectedTabIndex = 0; // 0: All, 1: Leave, 2: Correction, 3: Other
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadUserRequests();
  }

  Future<void> _loadUserRequests() async {
    final userId = AuthService().currentUserId;
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No active user session. Please sign in to view request history.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = Supabase.instance.client;
      final List<Map<String, dynamic>> items = [];

      // 1. Leave Requests
      try {
        final leaveRes = await client
            .from('leave_requests')
            .select('id, leave_type, reason, status, start_date, end_date, created_at')
            .eq('user_id', userId)
            .order('created_at', ascending: false);

        for (final row in (leaveRes as List)) {
          final status = (row['status']?.toString() ?? 'pending').toLowerCase();
          final typeRaw = row['leave_type']?.toString() ?? 'annual';
          final title = _formatLeaveTitle(typeRaw);
          final start = DateTime.tryParse(row['start_date']?.toString() ?? '');
          final end = DateTime.tryParse(row['end_date']?.toString() ?? '');
          final dates = _formatDateRange(start, end);
          final createdAt = DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now();

          items.add({
            'id': row['id']?.toString() ?? '',
            'title': title,
            'dates': dates,
            'status': _capitalize(status),
            'type': 'leave',
            'icon': _getLeaveIcon(typeRaw),
            'color': _getStatusColor(status),
            'createdAt': createdAt,
          });
        }
      } catch (e) {
        debugPrint('[Kivora] Error loading user leave requests: $e');
      }

      // 2. Correction Requests
      try {
        final corrRes = await client
            .from('correction_requests')
            .select('id, reason, status, created_at')
            .eq('user_id', userId)
            .order('created_at', ascending: false);

        for (final row in (corrRes as List)) {
          final status = (row['status']?.toString() ?? 'pending').toLowerCase();
          final createdAt = DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now();
          final dateStr = _formatSingleDate(createdAt);

          items.add({
            'id': row['id']?.toString() ?? '',
            'title': 'Attendance Correction',
            'dates': dateStr,
            'status': _capitalize(status),
            'type': 'correction',
            'icon': Icons.edit_calendar_outlined,
            'color': _getStatusColor(status),
            'createdAt': createdAt,
          });
        }
      } catch (e) {
        debugPrint('[Kivora] Error loading user correction requests: $e');
      }

      // 3. Transfer Requests
      try {
        final transRes = await client
            .from('transfer_requests')
            .select('id, reason, status, created_at')
            .eq('user_id', userId)
            .order('created_at', ascending: false);

        for (final row in (transRes as List)) {
          final status = (row['status']?.toString() ?? 'pending').toLowerCase();
          final createdAt = DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now();
          final dateStr = _formatSingleDate(createdAt);

          items.add({
            'id': row['id']?.toString() ?? '',
            'title': 'Branch Transfer',
            'dates': dateStr,
            'status': _capitalize(status),
            'type': 'other',
            'icon': Icons.swap_horiz_outlined,
            'color': _getStatusColor(status),
            'createdAt': createdAt,
          });
        }
      } catch (e) {
        debugPrint('[Kivora] Error loading user transfer requests: $e');
      }

      items.sort((a, b) => (b['createdAt'] as DateTime).compareTo(a['createdAt'] as DateTime));

      if (mounted) {
        setState(() {
          _requests = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[Kivora] Error loading all user requests: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not load requests: $e';
        });
      }
    }
  }

  String _formatLeaveTitle(String raw) {
    switch (raw.toLowerCase()) {
      case 'annual':
        return 'Annual Leave';
      case 'sick':
        return 'Sick Leave';
      case 'casual':
        return 'Casual Leave';
      case 'early_departure':
        return 'Early Departure';
      default:
        return 'Personal Leave';
    }
  }

  IconData _getLeaveIcon(String raw) {
    switch (raw.toLowerCase()) {
      case 'sick':
        return Icons.medical_services_outlined;
      case 'casual':
        return Icons.event_busy_outlined;
      default:
        return Icons.calendar_today_outlined;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'completed':
        return const Color(0xFF10B981);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  String _formatSingleDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null) return 'Recent';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final startStr = '${months[start.month - 1]} ${start.day}';
    if (end == null || (start.year == end.year && start.month == end.month && start.day == end.day)) {
      return '$startStr, ${start.year}';
    }
    final endStr = '${months[end.month - 1]} ${end.day}, ${end.year}';
    return '$startStr – $endStr';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _requests.where((r) {
      if (_selectedTabIndex == 1) return r['type'] == 'leave';
      if (_selectedTabIndex == 2) return r['type'] == 'correction';
      if (_selectedTabIndex == 3) return r['type'] == 'other';
      return true;
    }).toList();

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
          'Request History',
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
                _buildTab('All', 0),
                const SizedBox(width: 8),
                _buildTab('Leave', 1),
                const SizedBox(width: 8),
                _buildTab('Correction', 2),
                const SizedBox(width: 8),
                _buildTab('Other', 3),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Body
          Expanded(
            child: _isLoading
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
                                onPressed: _loadUserRequests,
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
                        onRefresh: _loadUserRequests,
                        color: const Color(0xFF0D9488),
                        child: filtered.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: const [
                                  SizedBox(height: 120),
                                  Center(
                                    child: Column(
                                      children: [
                                        Icon(Icons.inbox_outlined, size: 48, color: Color(0xFF94A3B8)),
                                        SizedBox(height: 12),
                                        Text(
                                          'No requests found',
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'Your leave, correction, and transfer petitions will appear here.',
                                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(20),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = filtered[index];
                                  final isApproved = item['status'] == 'Approved' || item['status'] == 'Completed';
                                  final isPending = item['status'] == 'Pending';

                                  return Container(
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
                                            color: (item['color'] as Color).withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 22),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['title'] as String,
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                item['dates'] as String,
                                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isApproved
                                                ? const Color(0xFFECFDF5)
                                                : isPending
                                                    ? const Color(0xFFFEF3C7)
                                                    : const Color(0xFFFEE2E2),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            item['status'] as String,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: isApproved
                                                  ? const Color(0xFF059669)
                                                  : isPending
                                                      ? const Color(0xFFD97706)
                                                      : const Color(0xFFDC2626),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCBD5E1)),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
