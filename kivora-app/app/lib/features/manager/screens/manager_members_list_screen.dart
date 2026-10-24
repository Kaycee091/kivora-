import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ManagerMembersListScreen extends StatefulWidget {
  const ManagerMembersListScreen({super.key});

  @override
  State<ManagerMembersListScreen> createState() => _ManagerMembersListScreenState();
}

class _ManagerMembersListScreenState extends State<ManagerMembersListScreen> {
  int _selectedRoleIndex = 0; // 0: All, 1: Students, 2: Teachers, 3: Staff
  final TextEditingController _searchCtrl = TextEditingController();

  final List<Map<String, String>> _members = [
    {'name': 'Sarah Johnson', 'role': 'Student', 'status': 'Active'},
    {'name': 'Michael Brown', 'role': 'Teacher', 'status': 'Active'},
    {'name': 'Emily Davis', 'role': 'Staff', 'status': 'Pending'},
    {'name': 'James Wilson', 'role': 'Student', 'status': 'Active'},
    {'name': 'Olivia Martinez', 'role': 'Teacher', 'status': 'Active'},
    {'name': 'Daniel Taylor', 'role': 'Staff', 'status': 'Active'},
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _members.where((m) {
      if (_selectedRoleIndex == 1) return m['role'] == 'Student';
      if (_selectedRoleIndex == 2) return m['role'] == 'Teacher';
      if (_selectedRoleIndex == 3) return m['role'] == 'Staff';
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
          'Members',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF94A3B8)),
                    hintText: 'Search members...',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Role filter tabs
                Row(
                  children: [
                    _buildTab('All', 0),
                    const SizedBox(width: 8),
                    _buildTab('Students', 1),
                    const SizedBox(width: 8),
                    _buildTab('Teachers', 2),
                    const SizedBox(width: 8),
                    _buildTab('Staff', 3),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Member List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final m = filtered[index];
                final isPending = m['status'] == 'Pending';

                return GestureDetector(
                  onTap: () => context.push('/manager/members/usr-001'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFFE0F2F1),
                          child: Text(
                            m['name']!.split(' ').map((n) => n[0]).join(''),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m['name']!,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                m['role']!,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPending ? const Color(0xFFFEF3C7) : const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            m['status']!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isPending ? const Color(0xFFD97706) : const Color(0xFF059669),
                            ),
                          ),
                        ),
                      ],
                    ),
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
    final isSelected = _selectedRoleIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRoleIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
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
