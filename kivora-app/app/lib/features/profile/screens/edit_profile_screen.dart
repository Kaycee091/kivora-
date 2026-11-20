import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/kivora_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _studentIdCtrl;
  String _department = 'Computer Science';
  String _level = 'Year 2';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final svc = KivoraService();
    _nameCtrl = TextEditingController(
      text: svc.currentUserName.isNotEmpty ? svc.currentUserName : '',
    );
    _emailCtrl = TextEditingController(
      text: svc.currentUserEmail.isNotEmpty ? svc.currentUserEmail : '',
    );
    _phoneCtrl = TextEditingController(text: '');
    _studentIdCtrl = TextEditingController(text: '');
  }

  void _handleSave() async {
    setState(() => _isSaving = true);
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final studentId = _studentIdCtrl.text.trim();

    await KivoraService().updateUserProfile(
      name: name.isNotEmpty ? name : 'Member',
      phone: phone,
      studentId: studentId,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile details updated successfully.'),
          backgroundColor: Color(0xFF0D9488),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with camera icon
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE0F2F1),
                        border: Border.all(color: const Color(0xFF0D9488), width: 3),
                      ),
                      child: const Center(
                        child: Icon(Icons.person, size: 54, color: Color(0xFF0D9488)),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0D9488),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 15),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              _buildField('Full Name', _nameCtrl),
              const SizedBox(height: 16),
              _buildField('Email Address', _emailCtrl),
              const SizedBox(height: 16),
              _buildField('Phone Number', _phoneCtrl),
              const SizedBox(height: 16),
              _buildField('Student ID', _studentIdCtrl),
              const SizedBox(height: 16),

              // Department dropdown
              const Text('Department', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _department,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'Computer Science', child: Text('Computer Science')),
                      DropdownMenuItem(value: 'Mathematics', child: Text('Mathematics')),
                      DropdownMenuItem(value: 'Physics', child: Text('Physics')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _department = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Level dropdown
              const Text('Level', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _level,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'Year 1', child: Text('Year 1')),
                      DropdownMenuItem(value: 'Year 2', child: Text('Year 2')),
                      DropdownMenuItem(value: 'Year 3', child: Text('Year 3')),
                      DropdownMenuItem(value: 'Year 4', child: Text('Year 4')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _level = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2)),
          ),
        ),
      ],
    );
  }
}
