import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/kivora_service.dart';

class BranchInfoScreen extends StatefulWidget {
  final String? branchId;

  const BranchInfoScreen({super.key, this.branchId});

  @override
  State<BranchInfoScreen> createState() => _BranchInfoScreenState();
}

class _BranchInfoScreenState extends State<BranchInfoScreen> {
  BranchModel? _branch;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBranchDetails();
  }

  @override
  void didUpdateWidget(covariant BranchInfoScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.branchId != widget.branchId) {
      _loadBranchDetails();
    }
  }

  Future<void> _loadBranchDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final targetBranchId = widget.branchId ?? KivoraService().currentBranchId;
      BranchModel? branch;

      if (targetBranchId != null && targetBranchId.isNotEmpty) {
        branch = await KivoraService().fetchBranch(targetBranchId);
      } else {
        branch = await KivoraService().fetchCurrentBranch();
      }

      if (!mounted) return;
      setState(() {
        _branch = branch;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/branch/gateway');
            }
          },
        ),
        title: const Text(
          'Branch Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0D9488)),
      );
    }

    if (_branch == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.domain_disabled_outlined, size: 40, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 20),
              const Text(
                'No Branch Information Found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'No branch details are currently associated with this account or workspace.',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                textAlign: TextAlign.center,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444)),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go('/branch/gateway'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                icon: const Icon(Icons.arrow_back, size: 18, color: Colors.white),
                label: const Text('Go to Branch Gateway', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final branch = _branch!;
    final addressText = branch.address.isNotEmpty ? branch.address : 'No address provided';
    final phoneText = branch.contactPhone.isNotEmpty ? branch.contactPhone : 'Not provided';
    final emailText = branch.contactEmail.isNotEmpty ? branch.contactEmail : 'Not provided';
    final orgTypeText = branch.organizationType.isNotEmpty ? branch.organizationType : 'Workspace';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Top Hero Illustration Card
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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDFA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.apartment, size: 48, color: Color(0xFF0D9488)),
                ),
                const SizedBox(height: 16),
                Text(
                  branch.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Color(0xFF0D9488)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        addressText,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    orgTypeText,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Branch Details Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Branch Details',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 16),
                _buildItem(Icons.business_outlined, 'Branch Name', branch.name),
                const Divider(height: 24, color: Color(0xFFF1F5F9)),
                _buildItem(Icons.category_outlined, 'Organization Type', orgTypeText),
                const Divider(height: 24, color: Color(0xFFF1F5F9)),
                _buildItem(Icons.place_outlined, 'Location / Address', addressText),
                const Divider(height: 24, color: Color(0xFFF1F5F9)),
                _buildItem(Icons.phone_outlined, 'Contact Phone', phoneText),
                const Divider(height: 24, color: Color(0xFFF1F5F9)),
                _buildItem(Icons.email_outlined, 'Contact Email', emailText),
                if (branch.inviteCode.isNotEmpty) ...[
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  _buildItem(Icons.qr_code, 'Invite Code', branch.inviteCode),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0D9488)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
