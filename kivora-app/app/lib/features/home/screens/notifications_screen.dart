import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedTabIndex = 0; // 0: All, 1: Attendance, 2: System

  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Attendance Confirmed',
      'body': 'Your check-in was successful',
      'time': '08:02 AM',
      'type': 'attendance',
      'icon': Icons.check_circle_outline,
      'color': Color(0xFF10B981),
      'isUnread': true,
    },
    {
      'title': 'Welcome to Kivora',
      'body': 'Thanks for being part of our community!',
      'time': 'Yesterday',
      'type': 'system',
      'icon': Icons.celebration_outlined,
      'color': Color(0xFF3B82F6),
      'isUnread': false,
    },
    {
      'title': 'Schedule Update',
      'body': 'Your class schedule has been updated',
      'time': 'Recently',
      'type': 'system',
      'icon': Icons.calendar_month_outlined,
      'color': Color(0xFFF59E0B),
      'isUnread': false,
    },
    {
      'title': 'Branch Notice',
      'body': 'The library will be closed this Friday',
      'time': '2 days ago',
      'type': 'system',
      'icon': Icons.location_city_outlined,
      'color': Color(0xFF0D9488),
      'isUnread': false,
    },
    {
      'title': 'System Update',
      'body': 'App performance improvements have been released',
      'time': '3 days ago',
      'type': 'system',
      'icon': Icons.verified_user_outlined,
      'color': Color(0xFF10B981),
      'isUnread': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _notifications.where((n) {
      if (_selectedTabIndex == 1) return n['type'] == 'attendance';
      if (_selectedTabIndex == 2) return n['type'] == 'system';
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
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Color(0xFF64748B)),
            onPressed: () => context.push('/member/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented filter tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _buildTab('All', 0),
                const SizedBox(width: 8),
                _buildTab('Attendance', 1),
                const SizedBox(width: 8),
                _buildTab('System', 2),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Notifications List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = filtered[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: item['isUnread'] ? const Color(0xFFCCFBF1) : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: (item['color'] as Color).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 22),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: item['isUnread'] ? FontWeight.bold : FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        if (item['isUnread'] == true)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0D9488),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          item['body'] as String,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['time'] as String,
                          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCBD5E1)),
                    onTap: () {},
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
