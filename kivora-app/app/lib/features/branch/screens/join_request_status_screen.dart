import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/kivora_service.dart';

class JoinRequestStatusScreen extends StatefulWidget {
  final String? branchId;
  final String? branchName;
  final String? userName;

  const JoinRequestStatusScreen({
    super.key,
    this.branchId,
    this.branchName,
    this.userName,
  });

  @override
  State<JoinRequestStatusScreen> createState() => _JoinRequestStatusScreenState();
}

class _JoinRequestStatusScreenState extends State<JoinRequestStatusScreen> {
  bool _isChecking = false;
  late String _branchName;
  String _status = 'pending';
  MembershipApplicationModel? _app;

  @override
  void initState() {
    super.initState();
    _branchName = widget.branchName ??
        (KivoraService().currentBranchId != null
            ? KivoraService().getBranchById(KivoraService().currentBranchId!)?.name
            : null) ??
        'Branch';
    _refreshStatus();
  }

  void _refreshStatus() {
    final service = KivoraService();
    // Look up application for the current user or branch
    final app = service.currentApplication ??
        (service.applications.isNotEmpty ? service.applications.last : null);

    if (app != null) {
      _app = app;
      _branchName = app.branchName;
      _status = app.status;
    }
  }

  void _checkStatus() {
    setState(() => _isChecking = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _isChecking = false;
        _refreshStatus();
      });

      if (_status == 'approved') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Congratulations! Your application has been approved by the Branch Manager.'),
            backgroundColor: Color(0xFF0D9488),
          ),
        );
      } else if (_status == 'rejected') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your application was not approved. Please contact your administrator.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your application is still under review by the Branch Manager.'),
            backgroundColor: Color(0xFF0F766E),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isApproved = _status == 'approved';
    final isRejected = _status == 'rejected';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => context.canPop() ? context.pop() : context.go('/branch/gateway'),
        ),
        title: const Text(
          'Application Status',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Status Icon Graphic
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: isApproved
                      ? const Color(0xFFECFDF5)
                      : (isRejected ? const Color(0xFFFEF2F2) : const Color(0xFFE0F2F1)),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isApproved
                        ? Icons.check_circle_outline
                        : (isRejected ? Icons.cancel_outlined : Icons.access_time_filled),
                    size: 60,
                    color: isApproved
                        ? const Color(0xFF059669)
                        : (isRejected ? const Color(0xFFDC2626) : const Color(0xFF0F766E)),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Text(
                isApproved
                    ? 'Application Approved!'
                    : (isRejected ? 'Application Not Approved' : 'Your account is\nawaiting approval'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  height: 1.25,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 14),

              // Branch & Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.apartment, size: 16, color: Color(0xFF0D9488)),
                    const SizedBox(width: 6),
                    Text(
                      _branchName,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF94A3B8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isApproved ? 'Approved' : (isRejected ? 'Rejected' : 'Pending Review'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isApproved
                            ? const Color(0xFF059669)
                            : (isRejected ? const Color(0xFFDC2626) : const Color(0xFFD97706)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Text(
                isApproved
                    ? 'Your membership has been officially approved. You now have full access to your member dashboard.'
                    : (isRejected
                        ? 'Your registration was reviewed and not accepted. Please verify your invitation details or re-apply.'
                        : 'Your registration has been submitted. A branch administrator must review and approve your account before membership becomes active.'),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 36),

              if (isApproved) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => context.go('/member/home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Proceed to Member Home',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ] else if (isRejected) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => context.go('/branch/discover'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0D9488)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Try Another Invitation Code',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isChecking ? null : _checkStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isChecking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Check Status',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.refresh, size: 18, color: Colors.white),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                // Demo helper button allowing testing approval lifecycle directly
                TextButton.icon(
                  onPressed: () {
                    if (_app != null) {
                      KivoraService().approveApplication(_app!.id);
                    } else if (KivoraService().applications.isNotEmpty) {
                      KivoraService().approveApplication(KivoraService().applications.first.id);
                    }
                    setState(() => _refreshStatus());
                  },
                  icon: const Icon(Icons.verified, size: 16, color: Color(0xFF0D9488)),
                  label: const Text(
                    'Simulate Branch Manager Approval (Demo)',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF0D9488), fontWeight: FontWeight.w600),
                  ),
                ),
              ],

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
