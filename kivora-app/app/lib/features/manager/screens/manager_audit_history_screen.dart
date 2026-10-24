import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ManagerAuditHistoryScreen extends StatefulWidget {
  const ManagerAuditHistoryScreen({super.key});

  @override
  State<ManagerAuditHistoryScreen> createState() => _ManagerAuditHistoryScreenState();
}

class _ManagerAuditHistoryScreenState extends State<ManagerAuditHistoryScreen> {
  int _selectedFilter = 0; // 0: All, 1: Admins, 2: Members

  final List<Map<String, dynamic>> _audit = [
    {
      'title': 'Settings updated',
      'detail': 'By Alex Johnson • Apr 16, 2025',
      'icon': Icons.tune,
    },
    {
      'title': 'Member approved',
      'detail': 'By Sarah Wilson • Apr 15, 2025',
      'icon': Icons.person_add_alt_1_outlined,
    },
    {
      'title': 'Role changed',
      'detail': 'By Alex Johnson • Apr 14, 2025',
      'icon': Icons.vpn_key_outlined,
    },
    {
      'title': 'Code generated',
      'detail': 'By Sarah Wilson • Apr 13, 2025',
      'icon': Icons.qr_code,
    },
    {
      'title': 'Message sent',
      'detail': 'By Alex Johnson • Apr 12, 2025',
      'icon': Icons.chat_bubble_outline,
    },
  ];

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
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _audit.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _audit[index];
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
