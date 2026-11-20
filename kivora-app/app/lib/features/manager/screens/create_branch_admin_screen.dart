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
  void initState() {
    super.initState();
    final draft = KivoraService().branchDraft;
    if (draft != null) {
      if (draft.adminName.isNotEmpty) _nameCtrl.text = draft.adminName;
      if (draft.adminEmail.isNotEmpty) _emailCtrl.text = draft.adminEmail;
      if (draft.adminPhone.isNotEmpty) _phoneCtrl.text = draft.adminPhone;
      if (draft.adminRole.isNotEmpty) _role = draft.adminRole;
    }
  }

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
    if (_isCreating) return;
    if (!_validate()) return;

    setState(() => _isCreating = true);

    final draft = KivoraService().branchDraft;
    final branchName = widget.branchData?['branchName'] ?? draft?.name ?? '';
    final orgType = widget.branchData?['orgType'] ?? draft?.organizationType ?? 'School';
    final address = widget.branchData?['address'] ?? draft?.address ?? '';
    final contactPhone = (widget.branchData?['contactPhone'] as String?)?.isNotEmpty == true
        ? widget.branchData!['contactPhone']
        : (_phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : (draft?.contactPhone ?? ''));
    final description = widget.branchData?['description'] ?? draft?.description ?? '';
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
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _handleCreate,
          ),
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
          key: const Key('create_branch_admin_back_btn'),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () {
            // Save admin inputs before going back so they survive Back navigation
            KivoraService().updateBranchDraftAdmin(
              adminName: _nameCtrl.text.trim(),
              adminEmail: _emailCtrl.text.trim(),
              adminPhone: _phoneCtrl.text.trim(),
              adminRole: _role,
            );
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/manager/branch/new');
            }
          },
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
                onChanged: (val) {
                  if (_nameError != null) setState(() => _nameError = null);
                  KivoraService().updateBranchDraftAdmin(
                    adminName: val.trim(),
                    adminEmail: _emailCtrl.text.trim(),
                    adminPhone: _phoneCtrl.text.trim(),
                    adminRole: _role,
                  );
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
                onChanged: (val) {
                  if (_emailError != null) setState(() => _emailError = null);
                  KivoraService().updateBranchDraftAdmin(
                    adminName: _nameCtrl.text.trim(),
                    adminEmail: val.trim(),
                    adminPhone: _phoneCtrl.text.trim(),
                    adminRole: _role,
                  );
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
                onChanged: (val) {
                  if (_phoneError != null) setState(() => _phoneError = null);
                  KivoraService().updateBranchDraftAdmin(
                    adminName: _nameCtrl.text.trim(),
                    adminEmail: _emailCtrl.text.trim(),
                    adminPhone: val.trim(),
                    adminRole: _role,
                  );
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
                      if (val != null) {
                        setState(() => _role = val);
                        KivoraService().updateBranchDraftAdmin(
                          adminName: _nameCtrl.text.trim(),
                          adminEmail: _emailCtrl.text.trim(),
                          adminPhone: _phoneCtrl.text.trim(),
                          adminRole: val,
                        );
                      }
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
