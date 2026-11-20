import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/kivora_service.dart';

class BranchTransferRequestScreen extends StatefulWidget {
  const BranchTransferRequestScreen({super.key});

  @override
  State<BranchTransferRequestScreen> createState() => _BranchTransferRequestScreenState();
}

class _BranchTransferRequestScreenState extends State<BranchTransferRequestScreen> {
  String? _targetBranchId;
  final TextEditingController _reasonCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final otherBranches = _otherBranches;
    if (otherBranches.isNotEmpty) {
      _targetBranchId = otherBranches.first.id;
    }
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  List<BranchModel> get _otherBranches {
    final curId = KivoraService().currentBranchId;
    return KivoraService().branches.where((b) => b.id != curId).toList();
  }

  Future<void> _handleSubmit() async {
    final reason = _reasonCtrl.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please state the reason for the transfer request.')),
      );
      return;
    }

    if (_targetBranchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a target branch for transfer.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (AuthService().isLiveMode) {
        final currentBranchId = KivoraService().currentBranchId;
        final currentUserId = AuthService().currentUserId;

        if (currentBranchId == null || currentUserId == null) {
          throw Exception('Missing active branch or user session.');
        }

        await Supabase.instance.client.from('transfer_requests').insert({
          'user_id': currentUserId,
          'source_branch_id': currentBranchId,
          'target_branch_id': _targetBranchId,
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
            content: Text('Branch transfer petition submitted to branch administrator.'),
            backgroundColor: Color(0xFF0D9488),
          ),
        );
        context.push('/member/transfer/history');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transfer petition error: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final otherBranches = _otherBranches;

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
          'Branch Transfer',
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
                      child: const Icon(Icons.swap_horiz, size: 48, color: Color(0xFF0D9488)),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Request Branch Transfer',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Select your target branch and explain\nthe reason for your transfer.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.3),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Current Branch
              const Text('Current Branch', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Builder(
                  builder: (context) {
                    final branch = KivoraService().currentBranch;
                    return Text(
                      branch?.name ?? 'Techverve',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              // Target Branch Dropdown
              const Text('Target Branch', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: otherBranches.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'No other branches currently registered for transfer.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        ),
                      )
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _targetBranchId,
                          isExpanded: true,
                          items: otherBranches.map((b) {
                            return DropdownMenuItem<String>(
                              value: b.id,
                              child: Text(b.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _targetBranchId = val);
                          },
                        ),
                      ),
              ),

              const SizedBox(height: 18),

              // Reason Text Area
              const Text('Reason for Transfer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 6),
              TextField(
                controller: _reasonCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter reason for transfer...',
                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2)),
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_isSubmitting || (otherBranches.isEmpty && AuthService().isLiveMode)) ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Submit Request', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
