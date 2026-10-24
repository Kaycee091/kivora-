import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/kivora_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String? branchId;
  final String? branchName;
  final String? inviteCode;

  const ProfileSetupScreen({
    super.key,
    this.branchId,
    this.branchName,
    this.inviteCode,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  late final String _activeBranchId;
  late final String _activeBranchName;
  late final String _activeInviteCode;

  late final List<IdFormFieldModel> _formFields;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _errors = {};

  bool _photoAttached = true;
  String? _photoError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _activeBranchId = widget.branchId ?? KivoraService().currentBranchId ?? 'branch-west';
    final branch = KivoraService().getBranchById(_activeBranchId);
    _activeBranchName = widget.branchName ?? branch?.name ?? 'West Campus';
    _activeInviteCode = widget.inviteCode ?? branch?.inviteCode ?? 'WEST-2026';

    // Load branch manager's configured identification fields
    _formFields = KivoraService().getIdFormConfig(_activeBranchId).where((f) => f.isEnabled).toList();

    for (var field in _formFields) {
      if (field.type != FieldType.photo) {
        String defaultVal = '';
        if (field.id == 'full_name' || field.label.toLowerCase().contains('name')) {
          defaultVal = KivoraService().currentUserName.isNotEmpty ? KivoraService().currentUserName : 'Alex Johnson';
        } else if (field.id == 'email' || field.label.toLowerCase().contains('email')) {
          defaultVal = KivoraService().currentUserEmail;
        } else if (field.id == 'phone' || field.label.toLowerCase().contains('phone')) {
          defaultVal = '+234 801 234 5678';
        } else if (field.id == 'student_id') {
          defaultVal = 'KIV-2026-0891';
        }
        _controllers[field.id] = TextEditingController(text: defaultVal);
      }
    }
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  bool _validateForm() {
    bool isValid = true;
    setState(() {
      _errors.clear();
      _photoError = null;
    });

    for (var field in _formFields) {
      if (field.type == FieldType.photo) {
        if (field.isRequired && !_photoAttached) {
          setState(() {
            _photoError = 'A valid photo is required by this branch.';
          });
          isValid = false;
        }
      } else {
        final ctrl = _controllers[field.id];
        final val = ctrl?.text.trim() ?? '';

        if (field.isRequired && val.isEmpty) {
          setState(() {
            _errors[field.id] = '${field.label} is required.';
          });
          isValid = false;
        } else if (val.isNotEmpty) {
          if (field.type == FieldType.email && (!val.contains('@') || !val.contains('.'))) {
            setState(() {
              _errors[field.id] = 'Please enter a valid email address.';
            });
            isValid = false;
          } else if (field.type == FieldType.phone && val.replaceAll(RegExp(r'[\s\-\+\(\)]'), '').length < 7) {
            setState(() {
              _errors[field.id] = 'Please enter a valid phone number.';
            });
            isValid = false;
          }
        }
      }
    }

    return isValid;
  }

  void _handleSubmit() {
    if (!_validateForm()) return;

    setState(() => _isSubmitting = true);

    final submittedData = <String, dynamic>{};
    for (var field in _formFields) {
      if (field.type == FieldType.photo) {
        submittedData[field.id] = _photoAttached ? 'attached_photo.jpg' : null;
      } else {
        submittedData[field.id] = _controllers[field.id]?.text.trim();
      }
    }

    final applicantName = submittedData['full_name']?.toString() ??
        submittedData.values.firstWhere((v) => v != null && v.toString().isNotEmpty, orElse: () => 'Applicant').toString();
    final rawApplicantEmail = submittedData['email'] as String?;
    final applicantEmail =
        (rawApplicantEmail != null && rawApplicantEmail.trim().isNotEmpty)
            ? rawApplicantEmail.trim()
            : KivoraService().currentUserEmail;

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;

      // Save application persistently in KivoraService
      KivoraService().submitApplication(
        branchId: _activeBranchId,
        inviteCode: _activeInviteCode,
        userName: applicantName,
        userEmail: applicantEmail,
        submittedData: submittedData,
        photoAttached: _photoAttached,
      );

      setState(() => _isSubmitting = false);

      // Navigate to dedicated Waiting for Approval screen (M08)
      context.go(
        '/branch/status',
        extra: {
          'branchId': _activeBranchId,
          'branchName': _activeBranchName,
          'userName': applicantName,
        },
      );
    });
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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/branch/preview');
            }
          },
        ),
        title: const Text(
          'Profile & Identity Setup',
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
                'Complete Your Profile',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              const Text(
                'Please provide the identification information requested by this branch to submit your membership application.',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 28),
              const Text(
                'Identification Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _activeBranchName,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                ),
              ),
              const SizedBox(height: 16),

              // Dynamically build the configured form fields
              ..._formFields.map((field) {
                if (field.type == FieldType.photo) {
                  return _buildPhotoUploadField(field);
                } else {
                  return _buildTextField(field);
                }
              }),

              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Submit Application',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoUploadField(IdFormFieldModel field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${field.label}${field.isRequired ? ' *' : ' (Optional)'}',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              _photoAttached = !_photoAttached;
              if (_photoAttached) _photoError = null;
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _photoError != null
                    ? Colors.red
                    : (_photoAttached ? const Color(0xFF10B981) : const Color(0xFFCBD5E1)),
                width: _photoAttached ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _photoAttached ? Icons.check_circle : Icons.add_a_photo_outlined,
                  size: 40,
                  color: _photoAttached ? const Color(0xFF10B981) : const Color(0xFF0D9488),
                ),
                const SizedBox(height: 8),
                Text(
                  _photoAttached ? 'Photo Attached (identity_photo.jpg)' : 'Tap to upload photo (JPEG/PNG)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _photoAttached ? const Color(0xFF059669) : const Color(0xFF0F172A),
                  ),
                ),
                if (!_photoAttached)
                  const Text(
                    'Clear, forward-facing photo required for verification',
                    style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
              ],
            ),
          ),
        ),
        if (_photoError != null) ...[
          const SizedBox(height: 6),
          Text(
            _photoError!,
            style: const TextStyle(fontSize: 12, color: Colors.red),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTextField(IdFormFieldModel field) {
    final ctrl = _controllers[field.id];
    final error = _errors[field.id];

    TextInputType keyboardType;
    switch (field.type) {
      case FieldType.email:
        keyboardType = TextInputType.emailAddress;
        break;
      case FieldType.phone:
        keyboardType = TextInputType.phone;
        break;
      case FieldType.date:
        keyboardType = TextInputType.datetime;
        break;
      case FieldType.longText:
        keyboardType = TextInputType.multiline;
        break;
      default:
        keyboardType = TextInputType.text;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${field.label}${field.isRequired ? ' *' : ' (Optional)'}',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          maxLines: field.type == FieldType.longText ? 3 : 1,
          decoration: InputDecoration(
            hintText: 'Enter ${field.label.toLowerCase()}',
            errorText: error,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2),
            ),
          ),
          onChanged: (_) {
            if (_errors[field.id] != null) {
              setState(() => _errors[field.id] = null);
            }
          },
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}
