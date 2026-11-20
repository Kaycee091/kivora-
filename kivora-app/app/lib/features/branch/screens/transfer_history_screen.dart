import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';

class TransferHistoryScreen extends StatefulWidget {
  const TransferHistoryScreen({super.key});

  @override
  State<TransferHistoryScreen> createState() => _TransferHistoryScreenState();
}

class _TransferHistoryScreenState extends State<TransferHistoryScreen> {
  bool _isLoading = false;
  final List<Map<String, String>> _transfers = [];

  final List<Map<String, String>> _demoTransfers = [
    {
      'from': 'West Campus',
      'to': 'East Campus',
      'date': 'Apr 10, 2025',
      'status': 'Completed',
    },
    {
      'from': 'East Campus',
      'to': 'North Campus',
      'date': 'Feb 18, 2025',
      'status': 'Completed',
    },
    {
      'from': 'North Campus',
      'to': 'West Campus',
      'date': 'Jan 05, 2025',
      'status': 'Completed',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (AuthService().isDemoMode) {
      _transfers.addAll(_demoTransfers);
    } else {
      _loadLiveTransfers();
    }
  }

  Future<void> _loadLiveTransfers() async {
    final userId = AuthService().currentUserId;
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      final client = Supabase.instance.client;
      final res = await client
          .from('transfer_requests')
          .select('id, reason, status, created_at, source:branches!transfer_requests_source_branch_id_fkey(name), target:branches!transfer_requests_target_branch_id_fkey(name)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final list = (res as List).map((row) {
        final source = row['source'] as Map<String, dynamic>?;
        final target = row['target'] as Map<String, dynamic>?;
        final createdAt = DateTime.tryParse(row['created_at']?.toString() ?? '');
        final dateStr = createdAt != null
            ? '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}'
            : 'Recent';

        return {
          'from': source?['name'] as String? ?? 'Origin Branch',
          'to': target?['name'] as String? ?? 'Target Branch',
          'date': dateStr,
          'status': (row['status'] as String? ?? 'pending').toUpperCase(),
        };
      }).toList();

      if (mounted) {
        setState(() {
          _transfers.clear();
          _transfers.addAll(list);
        });
      }
    } catch (e) {
      debugPrint('[Kivora] Error loading user transfers: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Transfer History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)))
          : _transfers.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.swap_horiz, size: 48, color: Color(0xFF94A3B8)),
                        SizedBox(height: 12),
                        Text(
                          'No transfer requests yet',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'When you submit a branch transfer request, its status and history will appear here.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _transfers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final t = _transfers[index];
                    final status = t['status'] ?? 'PENDING';
                    final isApproved = status == 'APPROVED' || status == 'COMPLETED';

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
                              color: const Color(0xFFF0FDFA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.swap_horiz, color: Color(0xFF0D9488)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${t['from']} →\n${t['to']}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), height: 1.2),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  t['date']!,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isApproved ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isApproved ? const Color(0xFF059669) : const Color(0xFFD97706),
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
    );
  }
}
