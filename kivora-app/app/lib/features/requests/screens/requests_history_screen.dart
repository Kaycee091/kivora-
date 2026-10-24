import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RequestsHistoryScreen extends StatefulWidget {
  const RequestsHistoryScreen({super.key});

  @override
  State<RequestsHistoryScreen> createState() => _RequestsHistoryScreenState();
}

class _RequestsHistoryScreenState extends State<RequestsHistoryScreen> {
  int _selectedTabIndex = 0; // 0: All, 1: Leave, 2: Correction, 3: Other

  final List<Map<String, dynamic>> _requests = [
    {
      'title': 'Annual Leave',
      'dates': 'Apr 21 – Apr 25, 2025',
      'status': 'Approved',
      'type': 'leave',
      'icon': Icons.calendar_today_outlined,
      'color': Color(0xFF10B981),
    },
    {
      'title': 'Attendance Correction',
      'dates': 'Apr 15, 2025',
      'status': 'Pending',
      'type': 'correction',
      'icon': Icons.edit_calendar_outlined,
      'color': Color(0xFFF59E0B),
    },
    {
      'title': 'Sick Leave',
      'dates': 'Apr 10 – Apr 11, 2025',
      'status': 'Approved',
      'type': 'leave',
      'icon': Icons.medical_services_outlined,
      'color': Color(0xFF10B981),
    },
    {
      'title': 'Casual Leave',
      'dates': 'Mar 28, 2025',
      'status': 'Rejected',
      'type': 'leave',
      'icon': Icons.event_busy_outlined,
      'color': Color(0xFFEF4444),
    },
    {
      'title': 'Attendance Correction',
      'dates': 'Mar 20, 2025',
      'status': 'Approved',
      'type': 'correction',
      'icon': Icons.edit_calendar_outlined,
      'color': Color(0xFF10B981),
    },
    {
      'title': 'Annual Leave',
      'dates': 'Mar 10 – Mar 14, 2025',
      'status': 'Approved',
      'type': 'leave',
      'icon': Icons.calendar_today_outlined,
      'color': Color(0xFF10B981),
    },
  ];

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

          // List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = filtered[index];
                final isApproved = item['status'] == 'Approved';
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
