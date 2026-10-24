import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GenerateInviteCodeScreen extends StatefulWidget {
  const GenerateInviteCodeScreen({super.key});

  @override
  State<GenerateInviteCodeScreen> createState() => _GenerateInviteCodeScreenState();
}

class _GenerateInviteCodeScreenState extends State<GenerateInviteCodeScreen> {
  String _code = 'KIV-9F3D-7A2B';
  bool _roleStudent = true;
  bool _roleTeacher = true;
  bool _roleStaff = true;
  bool _roleOther = false;

  void _regenerate() {
    setState(() {
      final rand = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
      _code = 'KIV-$rand-8B3C';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New invitation code generated.')),
    );
  }

  void _copy() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Code $_code copied to clipboard.')),
    );
  }

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
          'Create Invitation Code',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Code Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Text(
                    _code,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0D9488),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Valid for 7 days • Max 50 uses',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 20),

                  // Copy & Regenerate
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _copy,
                      icon: const Icon(Icons.copy, size: 18, color: Colors.white),
                      label: const Text('Copy Code', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _regenerate,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0D9488)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Regenerate Code', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Choose Roles',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),

            // Role Toggles
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildRoleToggle(Icons.school_outlined, 'Student', _roleStudent, (v) => setState(() => _roleStudent = v)),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildRoleToggle(Icons.person_outline, 'Teacher', _roleTeacher, (v) => setState(() => _roleTeacher = v)),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildRoleToggle(Icons.badge_outlined, 'Staff', _roleStaff, (v) => setState(() => _roleStaff = v)),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildRoleToggle(Icons.more_horiz, 'Other', _roleOther, (v) => setState(() => _roleOther = v)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleToggle(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0D9488), size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
      trailing: Switch.adaptive(
        value: value,
        activeColor: const Color(0xFF0D9488),
        onChanged: onChanged,
      ),
    );
  }
}
