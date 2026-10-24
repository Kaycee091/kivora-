import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClassInfoScreen extends StatefulWidget {
  final String classId;
  const ClassInfoScreen({super.key, this.classId = 'cs-201'});

  @override
  State<ClassInfoScreen> createState() => _ClassInfoScreenState();
}

class _ClassInfoScreenState extends State<ClassInfoScreen> {
  int _selectedTabIndex = 0; // 0: Overview, 1: Schedule, 2: Students

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
          'Class Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header summary
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Computer Science 201',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'CS 201 • Department of Computer Science',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  _buildTab('Overview', 0),
                  const SizedBox(width: 8),
                  _buildTab('Schedule', 1),
                  const SizedBox(width: 8),
                  _buildTab('Students', 2),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: _selectedTabIndex == 0
                  ? _buildOverviewTab()
                  : _selectedTabIndex == 1
                      ? _buildScheduleTab()
                      : _buildStudentsTab(),
            ),
          ],
        ),
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

  Widget _buildOverviewTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _buildInfoItem(Icons.class_outlined, 'Class Name', 'Computer Science 201'),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          _buildInfoItem(Icons.domain, 'Department', 'Computer Science'),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          _buildInfoItem(Icons.school_outlined, 'Level', 'Year 2'),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          _buildInfoItem(Icons.meeting_room_outlined, 'Room', 'Block B - Room 203'),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          _buildInfoItem(Icons.person_outline, 'Lecturer', 'Dr. Samuel Adeyemi'),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          _buildInfoItem(
            Icons.description_outlined,
            'Description',
            'Introduction to computer systems, data structures, algorithm design and problem solving methodologies.',
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: const [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.access_time, color: Color(0xFF0D9488)),
            title: Text('Monday: 08:00 AM – 10:00 AM', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            subtitle: Text('Block B - Room 203', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ),
          Divider(color: Color(0xFFF1F5F9)),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.access_time, color: Color(0xFF0D9488)),
            title: Text('Wednesday: 08:00 AM – 10:00 AM', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            subtitle: Text('Block B - Room 203', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Enrolled Roster (48 Students)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('Sarah Johnson • STU00123\nJames Wilson • STU00124\nDavid Wilson • STU00125', style: TextStyle(fontSize: 12, height: 1.6, color: Color(0xFF475569))),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0D9488)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            SizedBox(
              width: 250,
              child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            ),
          ],
        ),
      ],
    );
  }
}
