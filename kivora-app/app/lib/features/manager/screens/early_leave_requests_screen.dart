import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/kivora_service.dart';

class EarlyLeaveRequestsScreen extends StatefulWidget {
  const EarlyLeaveRequestsScreen({super.key});

  @override
  State<EarlyLeaveRequestsScreen> createState() => _EarlyLeaveRequestsScreenState();
}

class _EarlyLeaveRequestsScreenState extends State<EarlyLeaveRequestsScreen> {
  int _selectedTabIndex = 0; // 0: Pending, 1: History
  bool _isLoading = false;
  String? _errorMessage;

  final List<Map<String, dynamic>> _allRequests = [];

  @override
  void initState() {
    super.initState();
    _loadLiveLeaveRequests();
  }

  Future<void> _loadLiveLeaveRequests() async {
    final branchId = KivoraService().currentBranchId;
    if (branchId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No active branch selected.';
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
          .select('id, user_id, leave_type, reason, status, start_date, created_at, profiles(full_name)')
          .eq('branch_id', branchId)
          .order('created_at', ascending: false);

      final list = (res as List).map((row) {
        final profile = row['profiles'] as Map<String, dynamic>?;
        final name = profile?['full_name'] as String? ?? 'Member';
        final createdAt = DateTime.tryParse(row['created_at']?.toString() ?? '');
        final dateStr = createdAt != null
            ? '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}'
            : 'Recent';

        return {
          'id': row['id']?.toString() ?? '',
          'name': name,
          'role': row['leave_type']?.toString().replaceAll('_', ' ') ?? 'Leave',
          'date': dateStr,
          'reason': row['reason']?.toString() ?? 'No reason provided',
          'status': (row['status']?.toString() ?? 'pending').toLowerCase(),
        };
      }).toList();

      if (mounted) {
        setState(() {
          _allRequests.clear();
          _allRequests.addAll(list);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[Kivora] Error loading leave requests: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Database connection error: $e';
        });
      }
    }
  }

  Future<void> _handleDecision(String id, String decision) async {
    try {
      final client = Supabase.instance.client;
      final currentUserId = AuthService().currentUserId;
      await client.from('leave_requests').update({
        'status': decision.toLowerCase(),
        'reviewed_by': currentUserId,
        'reviewed_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', id);

      await _loadLiveLeaveRequests();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request $decision in database.'),
            backgroundColor: decision == 'Approved' ? const Color(0xFF0D9488) : const Color(0xFFEF4444),
          ),
        );
      }
    } catch (e) {
      debugPrint('[Kivora] Error updating leave request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update leave request in Supabase: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingRequests = _allRequests.where((r) => r['status'] == 'pending').toList();
    final historyRequests = _allRequests.where((r) => r['status'] != 'pending').toList();
    final displayRequests = _selectedTabIndex == 0 ? pendingRequests : historyRequests;

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
          'Leave Requests',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _buildTab('Pending (${pendingRequests.length})', 0),
                const SizedBox(width: 8),
                _buildTab('History (${historyRequests.length})', 1),
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
                    : RefreshIndicator(
                        onRefresh: _loadLiveLeaveRequests,
                        color: const Color(0xFF0D9488),
                        child: displayRequests.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  const SizedBox(height: 120),
                                  Center(
                                    child: Column(
                                      children: [
                                        const Icon(Icons.inbox_outlined, size: 48, color: Color(0xFF94A3B8)),
                                        const SizedBox(height: 12),
                                        Text(
                                          _selectedTabIndex == 0 ? 'No pending leave requests' : 'No leave history records',
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(20),
                                itemCount: displayRequests.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final req = displayRequests[index];
                                  final isPending = req['status'] == 'pending';
                                  final isApproved = req['status'] == 'approved';

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
                                          children: [
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundColor: const Color(0xFFE0F2F1),
                                              child: Text(
                                                (req['name'] as String).split(' ').map((n) => n.isNotEmpty ? n[0] : '').join(''),
                                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    req['name'] as String,
                                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                                  ),
                                                  Text(
                                                    '${req['role']} • ${req['date']}',
                                                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (!isPending)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: isApproved ? const Color(0xFFECFDF5) : const Color(0xFFFEE2E2),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  isApproved ? 'Approved' : 'Rejected',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: isApproved ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF8FAFC),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            req['reason'] as String,
                                            style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                                          ),
                                        ),
                                        if (isPending) ...[
                                          const SizedBox(height: 14),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton(
                                                  onPressed: () => _handleDecision(req['id'] as String, 'Rejected'),
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor: const Color(0xFFEF4444),
                                                    side: const BorderSide(color: Color(0xFFEF4444)),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                  ),
                                                  child: const Text('Reject'),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () => _handleDecision(req['id'] as String, 'Approved'),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF0D9488),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                  ),
                                                  child: const Text('Approve', style: TextStyle(color: Colors.white)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
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
