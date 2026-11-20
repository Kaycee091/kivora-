import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/kivora_service.dart';

class ManagerMemberDetailScreen extends StatefulWidget {
  final String memberId;
  const ManagerMemberDetailScreen({super.key, this.memberId = 'usr-001'});

  @override
  State<ManagerMemberDetailScreen> createState() => _ManagerMemberDetailScreenState();
}

class _ManagerMemberDetailScreenState extends State<ManagerMemberDetailScreen> {
  int _selectedTabIndex = 0; // 0: Identification Profile, 1: Activity & Attendance

  @override
  Widget build(BuildContext context) {
    final member = KivoraService().getMemberById(widget.memberId) ??
        MemberProfileModel(
          memberId: widget.memberId,
          name: 'Member (${widget.memberId.length > 8 ? widget.memberId.substring(0, 8) : widget.memberId})',
          email: '',
          phone: '',
          branchId: KivoraService().currentBranchId ?? '',
          branchName: KivoraService().currentBranch?.name ?? 'Branch',
          role: 'Member',
          status: 'Active',
          photoAttached: false,
          submittedFields: {},
          joinedAt: DateTime.now(),
        );

    // Fetch this member's actual sign-ins
    final memberSignIns = KivoraService()
        .attendanceRecords
        .where((r) => r.memberId == widget.memberId || r.memberName.toLowerCase() == member.name.toLowerCase())
        .toList();

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
          'Member Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header card
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: const Color(0xFFE0F2F1),
                    child: Text(
                      member.name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').join(''),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    member.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${member.role} • ${member.branchName}',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: member.status == 'Active' ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Membership: ${member.status}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: member.status == 'Active' ? const Color(0xFF059669) : const Color(0xFFD97706),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  _buildTab('Submitted Identification', 0),
                  const SizedBox(width: 8),
                  _buildTab('Actual Sign-Ins (${memberSignIns.length})', 1),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            if (_selectedTabIndex == 0) ...[
              // Submitted Identification Details
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Identification Details',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Stored securely and configured by branch management.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      const Divider(height: 24, color: Color(0xFFE2E8F0)),

                      _buildRow('Member ID', member.memberId),
                      const Divider(height: 20, color: Color(0xFFF1F5F9)),
                      _buildRow('Full Name', member.name),
                      const Divider(height: 20, color: Color(0xFFF1F5F9)),
                      _buildRow('Email Address', member.email),
                      const Divider(height: 20, color: Color(0xFFF1F5F9)),
                      _buildRow('Phone Number', member.phone),
                      const Divider(height: 20, color: Color(0xFFF1F5F9)),
                      _buildRow('Photo Verified', member.photoAttached ? 'Yes (Attached & Verified)' : 'Not Provided'),
                      const Divider(height: 20, color: Color(0xFFF1F5F9)),
                      _buildRow('Branch Workspace', member.branchName),
                      const Divider(height: 20, color: Color(0xFFF1F5F9)),
                      _buildRow('Join Date', '${member.joinedAt.day}/${member.joinedAt.month}/${member.joinedAt.year}'),

                      // Render custom submitted fields
                      ...member.submittedFields.entries.where((e) =>
                          e.key != 'full_name' &&
                          e.key != 'email' &&
                          e.key != 'phone' &&
                          e.key != 'Full Name' &&
                          e.key != 'Email Address' &&
                          e.key != 'Full Legal Name' &&
                          e.key != 'Institutional Email' &&
                          e.key != 'Phone Number').map((entry) {
                        return Column(
                          children: [
                            const Divider(height: 20, color: Color(0xFFF1F5F9)),
                            _buildRow(
                              _formatFieldLabel(entry.key),
                              entry.value?.toString() ?? '—',
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Actual Sign-Ins for this Member
              Padding(
                padding: const EdgeInsets.all(20),
                child: memberSignIns.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('No attendance records logged for this member yet.'),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: memberSignIns.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, idx) {
                          final rec = memberSignIns[idx];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${rec.signInTime.day}/${rec.signInTime.month}/${rec.signInTime.year}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      rec.verificationMethod,
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0FDFA),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${rec.signInTime.hour.toString().padLeft(2, '0')}:${rec.signInTime.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0D9488)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatFieldLabel(String key) {
    if (key.contains('_')) {
      return key.split('_').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
    }
    return key;
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
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

  Widget _buildRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }
}
