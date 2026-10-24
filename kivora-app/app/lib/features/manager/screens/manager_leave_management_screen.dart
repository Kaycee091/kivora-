import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  final List<Map<String, dynamic>> _pendingLeaves = [
    {
      'name': 'Amara Osei',
      'role': 'Student',
      'avatar': 'AO',
      'type': 'Sick Leave',
      'dates': 'Oct 23 – Oct 24, 2026',
      'days': '2 days',
      'reason': 'Feeling unwell, will see a doctor tomorrow.',
      'submittedAgo': '2 hours ago',
      'color': Color(0xFFEF4444),
    },
    {
      'name': 'Kwame Asante',
      'role': 'Teacher',
      'avatar': 'KA',
      'type': 'Personal Leave',
      'dates': 'Oct 25, 2026',
      'days': '1 day',
      'reason': 'Family commitment that cannot be rescheduled.',
      'submittedAgo': '5 hours ago',
      'color': Color(0xFF8B5CF6),
    },
    {
      'name': 'Fatima Al-Hassan',
      'role': 'Staff',
      'avatar': 'FA',
      'type': 'Annual Leave',
      'dates': 'Oct 27 – Oct 30, 2026',
      'days': '4 days',
      'reason': 'Pre-planned vacation with family.',
      'submittedAgo': '1 day ago',
      'color': Color(0xFF3B82F6),
    },
  ];

  final List<Map<String, dynamic>> _historyLeaves = [
    {
      'name': 'Kofi Mensah',
      'role': 'Student',
      'avatar': 'KM',
      'type': 'Sick Leave',
      'dates': 'Oct 18 – Oct 19, 2026',
      'days': '2 days',
      'status': 'Approved',
      'statusColor': Color(0xFF10B981),
      'decidedBy': 'Branch Manager',
    },
    {
      'name': 'Ama Boateng',
      'role': 'Teacher',
      'avatar': 'AB',
      'type': 'Emergency Leave',
      'dates': 'Oct 15, 2026',
      'days': '1 day',
      'status': 'Rejected',
      'statusColor': Color(0xFFEF4444),
      'decidedBy': 'Branch Manager',
    },
    {
      'name': 'Yaw Darko',
      'role': 'Staff',
      'avatar': 'YD',
      'type': 'Annual Leave',
      'dates': 'Oct 10 – Oct 14, 2026',
      'days': '5 days',
      'status': 'Approved',
      'statusColor': Color(0xFF10B981),
      'decidedBy': 'Branch Manager',
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
            Tab(text: 'History'),
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
    if (_pendingLeaves.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Color(0xFF10B981)),
            SizedBox(height: 16),
            Text('No pending leave requests', style: TextStyle(fontSize: 15, color: Color(0xFF64748B))),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingLeaves.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _buildPendingCard(_pendingLeaves[i]),
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
                  onPressed: () => _showDecisionDialog(leave['name'], false),
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
                  onPressed: () => _showDecisionDialog(leave['name'], true),
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
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _historyLeaves.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _buildHistoryCard(_historyLeaves[i]),
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

  void _showDecisionDialog(String name, bool isApprove) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isApprove ? 'Approve Leave' : 'Reject Leave', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          isApprove
              ? 'Approve the leave request for $name?'
              : 'Reject the leave request for $name? Please provide a reason.',
          style: const TextStyle(color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isApprove ? 'Leave approved for $name' : 'Leave rejected for $name'),
                  backgroundColor: isApprove ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
              );
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
