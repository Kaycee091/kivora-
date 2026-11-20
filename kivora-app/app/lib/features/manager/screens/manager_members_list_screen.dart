import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/kivora_service.dart';

class ManagerMembersListScreen extends StatefulWidget {
  const ManagerMembersListScreen({super.key});

  @override
  State<ManagerMembersListScreen> createState() => _ManagerMembersListScreenState();
}

class _ManagerMembersListScreenState extends State<ManagerMembersListScreen> {
  int _selectedRoleIndex = 0; // 0: All, 1: Students, 2: Teachers, 3: Staff
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isLoading = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final branchId = KivoraService().currentBranchId;
    if (branchId == null) {
      setState(() => _errorMessage = 'No active session. Please sign in.');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      await KivoraService().fetchBranchMembers(branchId);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Failed to load members. Tap to retry.');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  List<Map<String, String>> get _effectiveMembers {
    final svcMembers = KivoraService().members;
    return svcMembers.map((m) => {
      'id': m.memberId,
      'name': m.name,
      'role': m.role,
      'status': m.status,
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final search = _searchCtrl.text.trim().toLowerCase();
    final all = _effectiveMembers;

    final filtered = all.where((m) {
      if (search.isNotEmpty && !m['name']!.toLowerCase().contains(search)) {
        return false;
      }
      final role = (m['role'] ?? '').toLowerCase();
      if (_selectedRoleIndex == 1) return role.contains('student') || role.contains('member');
      if (_selectedRoleIndex == 2) return role.contains('teacher') || role.contains('admin');
      if (_selectedRoleIndex == 3) return role.contains('staff') || role.contains('manager');
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)))
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.wifi_off_outlined, size: 48, color: Color(0xFF94A3B8)),
                              const SizedBox(height: 12),
                              Text(_errorMessage!, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)), textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton(onPressed: _loadMembers, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488)), child: const Text('Retry', style: TextStyle(color: Colors.white))),
                            ],
                          ),
                        ),
                      )
                    : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF0FDFA),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.people_outline, size: 48, color: Color(0xFF0D9488)),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'No Members Found',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Approved members will appear in this branch roster.',
                              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
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
