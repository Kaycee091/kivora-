import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateBranchDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const CreateBranchDetailsScreen({super.key, this.initialData});

  @override
  State<CreateBranchDetailsScreen> createState() => _CreateBranchDetailsScreenState();
}

class _CreateBranchDetailsScreenState extends State<CreateBranchDetailsScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _locCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  String _orgType = 'School';

  String? _nameError;
  String? _locError;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      if (widget.initialData!['branchName'] != null) {
        _nameCtrl.text = widget.initialData!['branchName'];
      }
      if (widget.initialData!['description'] != null) {
        _descCtrl.text = widget.initialData!['description'];
      }
      if (widget.initialData!['address'] != null) {
        _locCtrl.text = widget.initialData!['address'];
      }
      if (widget.initialData!['contactPhone'] != null) {
        _phoneCtrl.text = widget.initialData!['contactPhone'];
      }
      if (widget.initialData!['orgType'] != null) {
        _orgType = widget.initialData!['orgType'];
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _locCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    bool isValid = true;
    setState(() {
      _nameError = null;
      _locError = null;
    });

    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _nameError = 'Branch name is required.');
      isValid = false;
    }

    if (_locCtrl.text.trim().isEmpty) {
      setState(() => _locError = 'Branch location or address is required.');
      isValid = false;
    }

    return isValid;
  }

  void _handleNext() {
    if (!_validate()) return;

    context.push(
      '/manager/branch/new/admin',
      extra: {
        'branchName': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'address': _locCtrl.text.trim(),
        'contactPhone': _phoneCtrl.text.trim(),
        'orgType': _orgType,
      },
    );
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
          'Create Branch - Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Branch Information',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              const Text(
                'Fill in the required information to establish a new branch workspace.',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 28),

              // Branch Name
              const Text('Branch Name *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  hintText: 'e.g. West Campus, Downtown HQ',
                  prefixIcon: const Icon(Icons.apartment, size: 20, color: Color(0xFF0D9488)),
                  errorText: _nameError,
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                ),
                onChanged: (_) {
                  if (_nameError != null) setState(() => _nameError = null);
                },
              ),

              const SizedBox(height: 18),

              // Organization Type Dropdown
              const Text('Organization Type *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
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
                    value: _orgType,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'School', child: Text('School')),
                      DropdownMenuItem(value: 'University', child: Text('University')),
                      DropdownMenuItem(value: 'College', child: Text('College')),
                      DropdownMenuItem(value: 'Company', child: Text('Company')),
                      DropdownMenuItem(value: 'Organization', child: Text('Organization')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _orgType = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Address / Location
              const Text('Address / Location *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              TextField(
                controller: _locCtrl,
                decoration: InputDecoration(
                  hintText: 'Enter full branch address',
                  prefixIcon: const Icon(Icons.location_on_outlined, size: 20, color: Color(0xFF0D9488)),
                  errorText: _locError,
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                ),
                onChanged: (_) {
                  if (_locError != null) setState(() => _locError = null);
                },
              ),

              const SizedBox(height: 18),

              // Contact Phone
              const Text('Branch Contact Phone (Optional)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'e.g. +234 801 234 5678',
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: Color(0xFF0D9488)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                ),
              ),

              const SizedBox(height: 18),

              // Description
              const Text('Description (Optional)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              TextField(
                controller: _descCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Brief summary of this branch and its scope',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                ),
              ),

              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Next', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
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
