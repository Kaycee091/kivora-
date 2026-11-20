import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/kivora_service.dart';

class ManagerBranchTransferScreen extends StatefulWidget {
  const ManagerBranchTransferScreen({super.key});

  @override
  State<ManagerBranchTransferScreen> createState() =>
      _ManagerBranchTransferScreenState();
}

class _ManagerBranchTransferScreenState
    extends State<ManagerBranchTransferScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _pendingTransfers = [];
  final List<Map<String, dynamic>> _historyTransfers = [];

  final List<Map<String, dynamic>> _demoPendingTransfers = [
    {
      'id': 'tr-demo-1',
      'name': 'Ama Sarpong',
      'avatar': 'AS',
      'role': 'Student',
      'fromBranch': 'West Campus',
      'toBranch': 'Main Campus',
      'reason': 'Moving to a new neighbourhood closer to main campus.',
      'submittedAgo': '3 hours ago',
    },
    {
      'id': 'tr-demo-2',
      'name': 'Kofi Acheampong',
      'avatar': 'KA',
      'role': 'Teacher',
      'fromBranch': 'West Campus',
      'toBranch': 'East Campus',
      'reason': 'Better facilities for my department at East Campus.',
      'submittedAgo': '1 day ago',
    },
  ];

  final List<Map<String, dynamic>> _demoHistoryTransfers = [
    {
      'id': 'tr-demo-3',
      'name': 'Grace Asante',
      'avatar': 'GA',
      'role': 'Student',
      'fromBranch': 'West Campus',
      'toBranch': 'Main Campus',
      'status': 'Completed',
      'statusColor': const Color(0xFF10B981),
      'date': 'Oct 15, 2026',
    },
    {
      'id': 'tr-demo-4',
      'name': 'Emmanuel Boateng',
      'avatar': 'EB',
      'role': 'Staff',
      'fromBranch': 'West Campus',
      'toBranch': 'North Annex',
      'status': 'Rejected',
      'statusColor': const Color(0xFFEF4444),
      'date': 'Oct 10, 2026',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (AuthService().isDemoMode) {
      _pendingTransfers.addAll(_demoPendingTransfers);
      _historyTransfers.addAll(_demoHistoryTransfers);
    } else {
      _loadLiveTransfers();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLiveTransfers() async {
    final branchId = KivoraService().currentBranchId;
    if (branchId == null) return;

    setState(() => _isLoading = true);
    try {
      final client = Supabase.instance.client;
      final res = await client
          .from('transfer_requests')
          .select('id, reason, status, created_at, reviewed_at, profiles(full_name), source:branches!transfer_requests_source_branch_id_fkey(name), target:branches!transfer_requests_target_branch_id_fkey(name)')
          .or('source_branch_id.eq.$branchId,target_branch_id.eq.$branchId')
          .order('created_at', ascending: false);

      final pending = <Map<String, dynamic>>[];
      final history = <Map<String, dynamic>>[];

      for (final row in (res as List)) {
        final profile = row['profiles'] as Map<String, dynamic>?;
        final name = profile?['full_name'] as String? ?? 'Member';
        final source = row['source'] as Map<String, dynamic>?;
        final target = row['target'] as Map<String, dynamic>?;
        final status = (row['status'] as String? ?? 'pending').toLowerCase();
        final avatar = name.isNotEmpty ? name.split(' ').map((n) => n[0]).take(2).join('').toUpperCase() : 'M';

        final createdAt = DateTime.tryParse(row['created_at']?.toString() ?? '');
        final dateStr = createdAt != null
            ? '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}'
            : 'Recent';

        if (status == 'pending') {
          pending.add({
            'id': row['id']?.toString() ?? '',
            'name': name,
            'avatar': avatar,
            'role': 'Member',
            'fromBranch': source?['name'] as String? ?? 'Origin',
            'toBranch': target?['name'] as String? ?? 'Target',
            'reason': row['reason']?.toString() ?? 'Transfer requested',
            'submittedAgo': dateStr,
          });
        } else {
          final isCompleted = status == 'approved' || status == 'completed';
          history.add({
            'id': row['id']?.toString() ?? '',
            'name': name,
            'avatar': avatar,
            'role': 'Member',
            'fromBranch': source?['name'] as String? ?? 'Origin',
            'toBranch': target?['name'] as String? ?? 'Target',
            'status': isCompleted ? 'Completed' : 'Rejected',
            'statusColor': isCompleted ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            'date': dateStr,
          });
        }
      }

      if (mounted) {
        setState(() {
          _pendingTransfers.clear();
          _pendingTransfers.addAll(pending);
          _historyTransfers.clear();
          _historyTransfers.addAll(history);
        });
      }
    } catch (e) {
      debugPrint('[Kivora] Error loading manager transfers: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDecision(String id, String decision) async {
    if (AuthService().isLiveMode) {
      try {
        final client = Supabase.instance.client;
        final currentUserId = AuthService().currentUserId;
        await client.from('transfer_requests').update({
          'status': decision.toLowerCase(),
          'reviewed_by': currentUserId,
          'reviewed_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', id);

        await _loadLiveTransfers();
      } catch (e) {
        debugPrint('[Kivora] Error updating transfer decision: $e');
      }
    } else {
      setState(() {
        _pendingTransfers.removeWhere((t) => t['id'] == id);
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transfer petition $decision.'),
          backgroundColor: decision == 'Approved' ? const Color(0xFF0D9488) : const Color(0xFFEF4444),
        ),
      );
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
          'Branch Transfers',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0D9488),
          unselectedLabelColor: const Color(0xFF94A3B8),
          indicatorColor: const Color(0xFF0D9488),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: [
            Tab(text: 'Pending (${_pendingTransfers.length})'),
            Tab(text: 'Transfer History (${_historyTransfers.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)))
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
    if (_pendingTransfers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horiz, size: 64, color: Color(0xFFCBD5E1)),
            SizedBox(height: 16),
            Text('No pending transfer requests', style: TextStyle(fontSize: 15, color: Color(0xFF64748B))),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingTransfers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _buildPendingCard(_pendingTransfers[i]),
    );
  }

  Widget _buildPendingCard(Map<String, dynamic> transfer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFE0F2F1),
                child: Text(transfer['avatar'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transfer['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    Text(transfer['role'], style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Pending', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Transfer Route
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCCFBF1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('From', style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(transfer['fromBranch'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Color(0xFF0D9488), size: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('To', style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(transfer['toBranch'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)), textAlign: TextAlign.right),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Reason
          Text(
            transfer['reason'],
            style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4),
          ),

          const SizedBox(height: 14),

          // Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleDecision(transfer['id'], 'Approved'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Approve', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleDecision(transfer['id'], 'Rejected'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Reject', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_historyTransfers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Color(0xFFCBD5E1)),
            SizedBox(height: 16),
            Text('No transfer history found', style: TextStyle(fontSize: 15, color: Color(0xFF64748B))),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _historyTransfers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _buildHistoryCard(_historyTransfers[i]),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
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
            child: Text(item['avatar'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                Text('${item['fromBranch']} → ${item['toBranch']}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                Text(item['date'], style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (item['statusColor'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item['status'],
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: item['statusColor']),
            ),
          ),
        ],
      ),
    );
  }
}
