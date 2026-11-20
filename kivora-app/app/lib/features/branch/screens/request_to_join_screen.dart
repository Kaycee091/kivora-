import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/kivora_service.dart';

/// BO09 — Request to Join (Role selector before submitting a join request)
class RequestToJoinScreen extends StatefulWidget {
  final String? branchName;
  const RequestToJoinScreen({super.key, this.branchName});

  @override
  State<RequestToJoinScreen> createState() => _RequestToJoinScreenState();
}

class _RequestToJoinScreenState extends State<RequestToJoinScreen> {
  String _selectedRole = 'Student';
  final _messageController = TextEditingController();

  final List<Map<String, dynamic>> _roles = [
    {
      'name': 'Student',
      'icon': Icons.school_outlined,
      'description': 'Enrolled as a student member',
    },
    {
      'name': 'Teacher',
      'icon': Icons.cast_for_education_outlined,
      'description': 'Teaching staff and instructors',
    },
    {
      'name': 'Staff',
      'icon': Icons.badge_outlined,
      'description': 'Non-teaching administrative staff',
    },
    {
      'name': 'Other',
      'icon': Icons.person_outline,
      'description': 'Any other organizational role',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
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
          'Request to Join',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Branch context
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFCCFBF1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.domain, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.branchName ??
                              (KivoraService().currentBranchId != null
                                  ? KivoraService().getBranchById(KivoraService().currentBranchId!)?.name
                                  : null) ??
                              'Branch',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const Text('You are requesting to join this branch', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text('Select your role', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 6),
            const Text('Choose the role that best describes your position', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),

            const SizedBox(height: 16),

            // Role cards
            ..._roles.map((role) => GestureDetector(
              onTap: () => setState(() => _selectedRole = role['name']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _selectedRole == role['name']
                      ? const Color(0xFF0D9488).withOpacity(0.05)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _selectedRole == role['name']
                        ? const Color(0xFF0D9488)
                        : const Color(0xFFE2E8F0),
                    width: _selectedRole == role['name'] ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _selectedRole == role['name']
                            ? const Color(0xFF0D9488)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        role['icon'],
                        color: _selectedRole == role['name'] ? Colors.white : const Color(0xFF94A3B8),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(role['name'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _selectedRole == role['name'] ? const Color(0xFF0D9488) : const Color(0xFF0F172A))),
                          Text(role['description'], style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    if (_selectedRole == role['name'])
                      const Icon(Icons.check_circle, color: Color(0xFF0D9488), size: 22),
                  ],
                ),
              ),
            )),

            const SizedBox(height: 20),

            // Optional message
            const Text('Message (optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add a short note for the branch manager...',
                hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final branchId = KivoraService().currentBranchId;
                  final branch = branchId != null ? KivoraService().getBranchById(branchId) : null;
                  final bId = branchId ?? (branch?.id ?? 'techverve-branch');
                  final bName = widget.branchName ?? branch?.name ?? 'Techverve';
                  final invCode = branch?.inviteCode ?? '';

                  KivoraService().submitApplication(
                    branchId: bId,
                    inviteCode: invCode,
                    userName: KivoraService().currentUserName.isNotEmpty
                        ? KivoraService().currentUserName
                        : 'Applicant',
                    userEmail: KivoraService().currentUserEmail,
                    submittedData: {
                      'role': _selectedRole,
                      'message': _messageController.text.trim(),
                    },
                    photoAttached: false,
                  );

                  context.go(
                    '/branch/status',
                    extra: {
                      'branchId': bId,
                      'branchName': bName,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Submit Join Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
