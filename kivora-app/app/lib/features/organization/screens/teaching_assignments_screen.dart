import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TeachingAssignmentsScreen extends StatefulWidget {
  const TeachingAssignmentsScreen({super.key});

  @override
  State<TeachingAssignmentsScreen> createState() => _TeachingAssignmentsScreenState();
}

class _TeachingAssignmentsScreenState extends State<TeachingAssignmentsScreen> {
  int _selectedTab = 0; // 0: Assigned Classes, 1: Past

  final List<Map<String, dynamic>> _assignedClasses = [
    {
      'title': 'Computer Science 201',
      'schedule': 'CS 201 • Mon, Wed 9:00 AM',
      'icon': Icons.code,
      'color': const Color(0xFF0D9488),
    },
    {
      'title': 'Mathematics 101',
      'schedule': 'MTH 101 • Tue, Thu 11:00 AM',
      'icon': Icons.calculate_outlined,
      'color': const Color(0xFF0F766E),
    },
    {
      'title': 'Physics 101',
      'schedule': 'PHY 101 • Fri 2:00 PM',
      'icon': Icons.science_outlined,
      'color': const Color(0xFF0284C7),
    },
    {
      'title': 'Programming Fundamentals',
      'schedule': 'CS 101 • Mon, Wed, Fri 1:00 PM',
      'icon': Icons.terminal,
      'color': const Color(0xFF14B8A6),
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
          'Teaching Assignments',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Assigned Classes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            const Text(
              'View the classes you are currently teaching',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),

            // Tabs
            Row(
              children: [
                _buildTab('Assigned Classes', 0),
                const SizedBox(width: 8),
                _buildTab('Past', 1),
              ],
            ),
            const SizedBox(height: 20),

            // Classes list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _assignedClasses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final c = _assignedClasses[index];
                return GestureDetector(
                  onTap: () => context.push('/member/classes/cs-201'),
                  child: Container(
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
                            color: (c['color'] as Color).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(c['icon'] as IconData, color: c['color'] as Color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c['title'] as String,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                c['schedule'] as String,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 20, color: Color(0xFFCBD5E1)),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 28),

            // View full schedule button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.push('/member/schedule'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text(
                  'View Full Schedule',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
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
