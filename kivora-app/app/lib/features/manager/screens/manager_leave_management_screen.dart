import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/kivora_service.dart';

class ManagerLeaveManagementScreen extends StatefulWidget {
  const ManagerLeaveManagementScreen({super.key});

  @override
  State<ManagerLeaveManagementScreen> createState() =>
      _ManagerLeaveManagementScreenState();
}

class _ManagerLeaveManagementScreenState
    extends State<ManagerLeaveManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> _pendingLeaves = [];
  List<Map<String, dynamic>> _historyLeaves = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLiveLeaveRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLiveLeaveRequests() async {
    final branchId = KivoraService().currentBranchId;
    if (branchId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No active branch selected. Please select a branch to view leave requests.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = Supabase.instance.client;
      final res = await client
          .from('leave_requests')
          .select('id, user_id, leave_type, reason, status, start_date, end_date, created_at, reviewed_at, profiles(full_name, role)')
          .eq('branch_id', branchId)
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> pending = [];
      final List<Map<String, dynamic>> history = [];

      for (final row in (res as List)) {
        final profile = row['profiles'] as Map<String, dynamic>?;
        final name = profile?['full_name'] as String? ?? 'Member';
        final role = profile?['role'] as String? ?? 'Student';
        final initials = name.split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join('').toUpperCase();
        final typeRaw = row['leave_type']?.toString() ?? 'other';
        final typeFormatted = _formatLeaveType(typeRaw);
        final color = _getLeaveColor(typeRaw);
        final startDate = DateTime.tryParse(row['start_date']?.toString() ?? '');
        final endDate = DateTime.tryParse(row['end_date']?.toString() ?? '');
        final datesStr = _formatDateRange(startDate, endDate);
        final daysStr = _calculateDays(startDate, endDate);
        final createdAt = DateTime.tryParse(row['created_at']?.toString() ?? '');
        final submittedAgo = _formatSubmittedAgo(createdAt);
        final status = (row['status']?.toString() ?? 'pending').toLowerCase();

        final item = {
          'id': row['id']?.toString() ?? '',
          'name': name,
          'role': role,
          'avatar': initials.isEmpty ? 'M' : initials,
          'type': typeFormatted,
          'dates': datesStr,
          'days': daysStr,
          'reason': row['reason']?.toString() ?? 'No reason provided',
          'submittedAgo': submittedAgo,
          'color': color,
          'status': status == 'approved' ? 'Approved' : (status == 'rejected' ? 'Rejected' : 'Pending'),
          'statusColor': status == 'approved' ? const Color(0xFF10B981) : (status == 'rejected' ? const Color(0xFFEF4444) : const Color(0xFFF59E0B)),
          'decidedBy': 'Branch Manager',
        };

        if (status == 'pending') {
          pending.add(item);
        } else {
          history.add(item);
        }
      }

      if (mounted) {
        setState(() {
          _pendingLeaves = pending;
          _historyLeaves = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[Kivora] Error loading leave management requests: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load leave requests from database: $e';
        });
      }
    }
  }

  String _formatLeaveType(String raw) {
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

  Color _getLeaveColor(String raw) {
    switch (raw.toLowerCase()) {
      case 'annual':
        return const Color(0xFF3B82F6);
      case 'sick':
        return const Color(0xFFEF4444);
      case 'casual':
        return const Color(0xFF10B981);
      case 'early_departure':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null) return 'Date unspecified';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final startStr = '${months[start.month - 1]} ${start.day}';
    if (end == null || (start.year == end.year && start.month == end.month && start.day == end.day)) {
      return '$startStr, ${start.year}';
    }
    final endStr = '${months[end.month - 1]} ${end.day}, ${end.year}';
    return '$startStr – $endStr';
  }

  String _calculateDays(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '1 day';
    final diff = end.difference(start).inDays.abs() + 1;
    return diff <= 1 ? '1 day' : '$diff days';
  }

  String _formatSubmittedAgo(DateTime? created) {
    if (created == null) return 'recently';
    final diff = DateTime.now().difference(created);
    if (diff.inMinutes < 60) {
      final mins = diff.inMinutes.clamp(1, 59);
      return '$mins min${mins > 1 ? 's' : ''} ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF0F172A)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Leave Management',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0D9488),
          unselectedLabelColor: const Color(0xFF94A3B8),
          indicatorColor: const Color(0xFF0D9488),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: [
            Tab(text: 'Pending (${_pendingLeaves.length})'),
            Tab(text: 'History (${_historyLeaves.length})'),
          ],
        ),
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
                          onPressed: _loadLiveLeaveRequests,
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
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPendingTab(),
                    _buildHistoryTab(),
                  ],
                ),
    );
  }

  Widget _buildPendingTab() {
    if (_pendingLeaves.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadLiveLeaveRequests,
        color: const Color(0xFF0D9488),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Color(0xFF10B981)),
                  SizedBox(height: 16),
                  Text(
                    'No pending leave requests',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'All member leave petitions for this branch have been processed.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadLiveLeaveRequests,
      color: const Color(0xFF0D9488),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingLeaves.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _buildPendingCard(_pendingLeaves[i]),
      ),
    );
  }

  Widget _buildPendingCard(Map<String, dynamic> leave) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFE0F2F1),
                child: Text(leave['avatar'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(leave['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    Text(leave['role'], style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (leave['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  leave['type'],
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: leave['color'] as Color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _buildInfoRow(Icons.calendar_today_outlined, 'Dates', leave['dates']),
                const SizedBox(height: 6),
                _buildInfoRow(Icons.timer_outlined, 'Duration', leave['days']),
                const SizedBox(height: 6),
                _buildInfoRow(Icons.notes_outlined, 'Reason', leave['reason']),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Submitted ${leave['submittedAgo']}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showDecisionDialog(leave, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showDecisionDialog(leave, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Approve', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        Text('$label: ', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A)))),
      ],
    );
  }

  Widget _buildHistoryTab() {
    if (_historyLeaves.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadLiveLeaveRequests,
        color: const Color(0xFF0D9488),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(
              child: Column(
                children: [
                  Icon(Icons.history, size: 48, color: Color(0xFF94A3B8)),
                  SizedBox(height: 12),
                  Text('No historical leave records', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  SizedBox(height: 6),
                  Text('Processed leave requests will be cataloged here.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadLiveLeaveRequests,
      color: const Color(0xFF0D9488),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _historyLeaves.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) => _buildHistoryCard(_historyLeaves[i]),
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> leave) {
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
            radius: 18,
            backgroundColor: const Color(0xFFE0F2F1),
            child: Text(leave['avatar'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(leave['name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                Text('${leave['type']} · ${leave['dates']}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                Text('Decided by: ${leave['decidedBy']}', style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (leave['statusColor'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              leave['status'],
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: leave['statusColor'] as Color),
            ),
          ),
        ],
      ),
    );
  }

  void _showDecisionDialog(Map<String, dynamic> leave, bool isApprove) {
    final name = leave['name'] as String;
    final leaveId = leave['id'] as String;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isApprove ? 'Approve Leave' : 'Reject Leave', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          isApprove
              ? 'Approve the leave request for $name?'
              : 'Reject the leave request for $name?',
          style: const TextStyle(color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final client = Supabase.instance.client;
                final currentUserId = AuthService().currentUserId;
                await client.from('leave_requests').update({
                  'status': isApprove ? 'approved' : 'rejected',
                  'reviewed_by': currentUserId,
                  'reviewed_at': DateTime.now().toUtc().toIso8601String(),
                }).eq('id', leaveId);

                await _loadLiveLeaveRequests();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isApprove ? 'Leave approved for $name' : 'Leave rejected for $name'),
                      backgroundColor: isApprove ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    ),
                  );
                }
              } catch (e) {
                debugPrint('[Kivora] Error updating leave decision: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update leave request in database: $e'),
                      backgroundColor: const Color(0xFFEF4444),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? const Color(0xFF0D9488) : const Color(0xFFEF4444),
            ),
            child: Text(isApprove ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }
}
