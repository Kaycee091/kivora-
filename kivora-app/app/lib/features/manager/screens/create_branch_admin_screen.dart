import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/kivora_service.dart';

class CreateBranchAdminScreen extends StatefulWidget {
  final Map<String, dynamic>? branchData;
  const CreateBranchAdminScreen({super.key, this.branchData});

  @override
  State<CreateBranchAdminScreen> createState() => _CreateBranchAdminScreenState();
}

class _CreateBranchAdminScreenState extends State<CreateBranchAdminScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _phoneError;

  String _role = 'Branch Manager';
  bool _isCreating = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    bool isValid = true;
    setState(() {
      _nameError = null;
      _emailError = null;
      _phoneError = null;
    });

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty) {
      setState(() => _nameError = 'Administrator name is required.');
      isValid = false;
    }

    if (email.isEmpty) {
      setState(() => _emailError = 'Administrator email is required.');
      isValid = false;
    } else if (!email.contains('@') || !email.contains('.')) {
      setState(() => _emailError = 'Please enter a valid email address.');
      isValid = false;
    }

    if (phone.isNotEmpty && phone.replaceAll(RegExp(r'[\s\-\+\(\)]'), '').length < 7) {
      setState(() => _phoneError = 'Please enter a valid phone number.');
      isValid = false;
    }

    return isValid;
  }

  Future<void> _handleCreate() async {
    if (!_validate()) return;

    setState(() => _isCreating = true);

    final branchName = widget.branchData?['branchName'] ?? 'New Branch';
    final orgType = widget.branchData?['orgType'] ?? 'School';
    final address = widget.branchData?['address'] ?? 'Main Campus';
    final contactPhone = (widget.branchData?['contactPhone'] as String?)?.isNotEmpty == true
        ? widget.branchData!['contactPhone']
        : _phoneCtrl.text.trim();
    final description = widget.branchData?['description'] ?? '';
    final adminEmail = _emailCtrl.text.trim();
    final adminName = _nameCtrl.text.trim();

    try {
      final createdBranch = await KivoraService().createBranch(
        name: branchName,
        organizationType: orgType,
        address: address,
        contactPhone: contactPhone,
        contactEmail: adminEmail,
        description: description,
      );

      KivoraService().setCurrentUser(
        email: adminEmail,
        name: adminName,
        role: 'manager',
        branchId: createdBranch.id,
      );

      if (!mounted) return;
      setState(() => _isCreating = false);

      context.push(
        '/manager/branch/new/success',
        extra: {
          'branchId': createdBranch.id,
          'branchName': createdBranch.name,
          'inviteCode': createdBranch.inviteCode,
          'orgType': createdBranch.organizationType,
          'address': createdBranch.address,
          'contactPhone': createdBranch.contactPhone,
          'contactEmail': createdBranch.contactEmail,
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCreating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save branch: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
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
          'Create Branch - Add Admin',
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
              const Text(
                'Branch Administrator',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              const Text(
                'Assign the primary administrator or branch manager responsible for governance.',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 28),

              // Full Name
              const Text('Administrator Full Name *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  hintText: 'Enter administrator full name',
                  errorText: _nameError,
                  prefixIcon: const Icon(Icons.person_outline, size: 20, color: Color(0xFF0D9488)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                ),
                onChanged: (_) {
                  if (_nameError != null) setState(() => _nameError = null);
                },
              ),

              const SizedBox(height: 16),

              // Email
              const Text('Email Address *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'admin@organization.org',
                  errorText: _emailError,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20, color: Color(0xFF0D9488)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                ),
                onChanged: (_) {
                  if (_emailError != null) setState(() => _emailError = null);
                },
              ),

              const SizedBox(height: 16),

              // Phone Number
              const Text('Phone Number (Optional)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'e.g. +234 801 234 5678',
                  errorText: _phoneError,
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: Color(0xFF0D9488)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                ),
                onChanged: (_) {
                  if (_phoneError != null) setState(() => _phoneError = null);
                },
              ),

              const SizedBox(height: 16),

              // Role Dropdown
              const Text('Role', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _role,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'Branch Manager', child: Text('Branch Manager')),
                      DropdownMenuItem(value: 'Branch Admin', child: Text('Branch Admin')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _role = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isCreating ? null : _handleCreate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isCreating
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Create Branch', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
