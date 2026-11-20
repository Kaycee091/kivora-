import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/kivora_service.dart';

class ManagerAuditHistoryScreen extends StatefulWidget {
  const ManagerAuditHistoryScreen({super.key});

  @override
  State<ManagerAuditHistoryScreen> createState() => _ManagerAuditHistoryScreenState();
}

class _ManagerAuditHistoryScreenState extends State<ManagerAuditHistoryScreen> {
  int _selectedFilter = 0; // 0: All, 1: Admins, 2: Members
  bool _isLoading = false;

  final List<Map<String, dynamic>> _audit = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLiveAuditLogs();
  }

  Future<void> _loadLiveAuditLogs() async {
    final branchId = KivoraService().currentBranchId;
    if (branchId == null) return;

    setState(() => _isLoading = true);
    try {
      final client = Supabase.instance.client;
      final res = await client
          .from('audit_logs')
          .select('id, action, target_entity, changes, created_at, profiles(full_name)')
          .eq('branch_id', branchId)
          .order('created_at', ascending: false);

      final list = (res as List).map((row) {
        final profile = row['profiles'] as Map<String, dynamic>?;
        final actorName = profile?['full_name'] as String? ?? 'System';
        final action = row['action'] as String? ?? 'Action';
        final entity = row['target_entity'] as String? ?? '';
        final createdAt = DateTime.tryParse(row['created_at']?.toString() ?? '');
        final dateStr = createdAt != null
            ? '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}'
            : 'Recent';

        return {
          'id': row['id']?.toString() ?? '',
          'title': '$action ${entity.isNotEmpty ? "($entity)" : ""}',
          'detail': 'By $actorName • $dateStr',
          'category': action.toLowerCase().contains('member') ? 'member' : 'admin',
          'icon': _getIconForAction(action),
        };
      }).toList();

      if (mounted) {
        setState(() {
          _audit.clear();
          _audit.addAll(list);
        });
      }
    } catch (e) {
      debugPrint('[Kivora] Error loading audit logs: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  IconData _getIconForAction(String action) {
    final a = action.toLowerCase();
    if (a.contains('member') || a.contains('approval')) return Icons.person_add_alt_1_outlined;
    if (a.contains('role') || a.contains('permission')) return Icons.vpn_key_outlined;
    if (a.contains('code') || a.contains('invite')) return Icons.qr_code;
    if (a.contains('message') || a.contains('announcement')) return Icons.campaign_outlined;
    if (a.contains('attendance') || a.contains('check')) return Icons.fingerprint;
    return Icons.tune;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _audit.where((item) {
      if (_selectedFilter == 1) return item['category'] == 'admin';
      if (_selectedFilter == 2) return item['category'] == 'member';
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
          'Audit History',
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
                _buildFilterTab('All', 0),
                const SizedBox(width: 8),
                _buildFilterTab('Admins', 1),
                const SizedBox(width: 8),
                _buildFilterTab('Members', 2),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Audit Stream
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)))
                : filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.history_toggle_off, size: 48, color: Color(0xFF94A3B8)),
                              SizedBox(height: 12),
                              Text(
                                'No audit events recorded',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Administrative decisions, role changes, and member approvals will appear here.',
                                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
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
                                  child: Icon(item['icon'] as IconData, color: const Color(0xFF0D9488), size: 22),
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
                                        item['detail'] as String,
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
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

  Widget _buildFilterTab(String title, int index) {
    final isSelected = _selectedFilter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = index),
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
