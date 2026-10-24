import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/kivora_service.dart';

class BranchTransferRequestScreen extends StatefulWidget {
  const BranchTransferRequestScreen({super.key});

  @override
  State<BranchTransferRequestScreen> createState() => _BranchTransferRequestScreenState();
}

class _BranchTransferRequestScreenState extends State<BranchTransferRequestScreen> {
  String _targetBranch = 'East Campus';
  final TextEditingController _reasonCtrl = TextEditingController();
  bool _isSubmitting = false;

  void _handleSubmit() {
    setState(() => _isSubmitting = true);
    Future.delayed(const Duration(milliseconds: 700), () {
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
                      'Select your current branch and the\nbranch you want to transfer to.',
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
                    final branchId = KivoraService().currentBranchId;
                    final branch = branchId != null ? KivoraService().getBranchById(branchId) : null;
                    return Text(
                      branch?.name ?? 'Current Branch',
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
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _targetBranch,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'East Campus', child: Text('East Campus (Enugu)')),
                      DropdownMenuItem(value: 'North Campus', child: Text('North Campus (Kano)')),
                      DropdownMenuItem(value: 'South Campus', child: Text('South Campus (Port Harcourt)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _targetBranch = val);
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
                  onPressed: _isSubmitting ? null : _handleSubmit,
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
