import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  final List<Map<String, dynamic>> _pendingTransfers = [
    {
      'name': 'Ama Sarpong',
      'avatar': 'AS',
      'role': 'Student',
      'fromBranch': 'West Campus',
      'toBranch': 'Main Campus',
      'reason': 'Moving to a new neighbourhood closer to main campus.',
      'submittedAgo': '3 hours ago',
    },
    {
      'name': 'Kofi Acheampong',
      'avatar': 'KA',
      'role': 'Teacher',
      'fromBranch': 'West Campus',
      'toBranch': 'East Campus',
      'reason': 'Better facilities for my department at East Campus.',
      'submittedAgo': '1 day ago',
    },
  ];

  final List<Map<String, dynamic>> _historyTransfers = [
    {
      'name': 'Grace Asante',
      'avatar': 'GA',
      'role': 'Student',
      'fromBranch': 'West Campus',
      'toBranch': 'Main Campus',
      'status': 'Completed',
      'statusColor': Color(0xFF10B981),
      'date': 'Oct 15, 2026',
    },
    {
      'name': 'Emmanuel Boateng',
      'avatar': 'EB',
      'role': 'Staff',
      'fromBranch': 'West Campus',
      'toBranch': 'North Annex',
      'status': 'Rejected',
      'statusColor': Color(0xFFEF4444),
      'date': 'Oct 10, 2026',
    },
    {
      'name': 'Abena Mensah',
      'avatar': 'AM',
      'role': 'Teacher',
      'fromBranch': 'West Campus',
      'toBranch': 'East Campus',
      'status': 'Completed',
      'statusColor': Color(0xFF10B981),
      'date': 'Sep 28, 2026',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            const Tab(text: 'Transfer History'),
          ],
        ),
      ),
      body: TabBarView(
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.notes_outlined, size: 14, color: Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  transfer['reason'],
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Text('Submitted ${transfer['submittedAgo']}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleDecision(transfer['name'], false),
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
                  onPressed: () => _handleDecision(transfer['name'], true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Approve Transfer', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _historyTransfers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _buildHistoryCard(_historyTransfers[i]),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> transfer) {
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
            child: Text(transfer['avatar'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transfer['name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                Row(
                  children: [
                    Text(transfer['fromBranch'], style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    const Icon(Icons.arrow_forward, size: 12, color: Color(0xFF94A3B8)),
                    Text(transfer['toBranch'], style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
                Text(transfer['date'], style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (transfer['statusColor'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              transfer['status'],
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: transfer['statusColor'] as Color),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDecision(String name, bool isApprove) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isApprove ? 'Approve Transfer' : 'Reject Transfer'),
        content: Text(isApprove
            ? 'Approve the branch transfer request for $name?'
            : 'Reject the branch transfer request for $name?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isApprove ? 'Transfer approved for $name' : 'Transfer rejected for $name'),
                  backgroundColor: isApprove ? const Color(0xFF0D9488) : const Color(0xFFEF4444),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? const Color(0xFF0D9488) : const Color(0xFFEF4444),
            ),
            child: Text(isApprove ? 'Approve' : 'Reject', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
