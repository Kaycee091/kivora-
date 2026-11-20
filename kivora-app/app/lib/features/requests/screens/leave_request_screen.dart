import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/kivora_service.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  String _leaveType = 'Annual Leave';
  late final TextEditingController _startDateCtrl;
  late final TextEditingController _endDateCtrl;
  final TextEditingController _reasonCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final end = now.add(const Duration(days: 3));
    _startDateCtrl = TextEditingController(text: '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}');
    _endDateCtrl = TextEditingController(text: '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}');
  }

  @override
  void dispose() {
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final reason = _reasonCtrl.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reason for the leave request.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (AuthService().isLiveMode) {
        final branchId = KivoraService().currentBranchId;
        final userId = AuthService().currentUserId;

        if (branchId == null || userId == null) {
          throw Exception('No active branch or user session found.');
        }

        String typeCode = 'annual';
        if (_leaveType.contains('Sick')) {
          typeCode = 'sick';
        } else if (_leaveType.contains('Casual')) {
          typeCode = 'casual';
        } else if (_leaveType.contains('Early')) {
          typeCode = 'early_departure';
        } else if (_leaveType.contains('Other')) {
          typeCode = 'other';
        }

        final now = DateTime.now();
        await Supabase.instance.client.from('leave_requests').insert({
          'branch_id': branchId,
          'user_id': userId,
          'leave_type': typeCode,
          'start_date': now.toUtc().toIso8601String(),
          'end_date': now.add(const Duration(days: 3)).toUtc().toIso8601String(),
          'reason': reason,
          'status': 'pending',
        });
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leave request submitted successfully for approval.'),
            backgroundColor: Color(0xFF0D9488),
          ),
        );
        context.push('/member/requests');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission error: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
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
          'Leave Request',
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
              // Illustration header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDFA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.calendar_month, size: 44, color: Color(0xFF0D9488)),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Request a leave',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Fill in the details below to submit\nyour leave request.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.3),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Leave Type Dropdown
              const Text('Leave Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
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
                    value: _leaveType,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'Annual Leave', child: Text('Annual Leave')),
                      DropdownMenuItem(value: 'Sick Leave', child: Text('Sick Leave')),
                      DropdownMenuItem(value: 'Casual Leave', child: Text('Casual Leave')),
                      DropdownMenuItem(value: 'Early Departure', child: Text('Early Departure')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _leaveType = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Date pickers row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Start Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _startDateCtrl,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.calendar_today, size: 16, color: Color(0xFF0D9488)),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('End Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _endDateCtrl,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.calendar_today, size: 16, color: Color(0xFF0D9488)),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Reason Text Area
              const Text('Reason', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 6),
              TextField(
                controller: _reasonCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter reason for leave...',
                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 32),

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
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Submit Request',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
