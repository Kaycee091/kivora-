import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/kivora_service.dart';

class BranchPreviewScreen extends StatefulWidget {
  final String? branchId;
  final String? inviteCode;
  final String? inviteCodeId;

  const BranchPreviewScreen({
    super.key,
    this.branchId,
    this.inviteCode,
    this.inviteCodeId,
  });

  @override
  State<BranchPreviewScreen> createState() => _BranchPreviewScreenState();
}

class _BranchPreviewScreenState extends State<BranchPreviewScreen> {
  late final TextEditingController _codeController;
  BranchModel? _matchedBranch;
  String? _inviteCodeId;
  String? _errorMessage;
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.inviteCode ?? '');
    _inviteCodeId = widget.inviteCodeId;

    if (widget.branchId != null) {
      _matchedBranch = KivoraService().getBranchById(widget.branchId!);
    } else if (widget.inviteCode != null && widget.inviteCode!.isNotEmpty) {
      _matchedBranch = KivoraService().validateInviteCodeSync(widget.inviteCode!);
    } else {
      _matchedBranch = null;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _validateCode() {
    final code = _codeController.text.trim();
    setState(() {
      _errorMessage = null;
    });

    if (code.isEmpty) {
      setState(() => _errorMessage = 'Please enter an invitation code.');
      return;
    }

    setState(() => _isValidating = true);

    Future.delayed(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      final result = await KivoraService().validateInviteCodeDetailed(code);
      if (!mounted) return;

      if (!result.isValid || result.branch == null) {
        setState(() {
          _isValidating = false;
          _errorMessage = result.errorMessage ?? 'Invalid, inactive, or expired invitation code. Please check with your branch manager.';
          _matchedBranch = null;
          _inviteCodeId = null;
        });
      } else {
        setState(() {
          _isValidating = false;
          _matchedBranch = result.branch;
          _inviteCodeId = result.inviteCodeId;
        });
      }
    });
  }

  void _proceedToIdentification() {
    if (_matchedBranch == null) return;
    context.push(
      '/profile/setup',
      extra: {
        'branchId': _matchedBranch!.id,
        'branchName': _matchedBranch!.name,
        'inviteCode': _codeController.text.isNotEmpty ? _codeController.text : _matchedBranch!.inviteCode,
        'inviteCodeId': _inviteCodeId ?? widget.inviteCodeId,
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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/branch/discover');
            }
          },
        ),
        title: const Text(
          'Confirm Branch',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_matchedBranch == null) ...[
                const Text(
                  'Enter Invitation Code',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your invitation code to display and confirm your branch.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'Invitation Code *',
                    errorText: _errorMessage,
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isValidating ? null : _validateCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isValidating
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Confirm Code', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ] else ...[
                const Text(
                  'Matching Branch Details',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Please confirm that this is the branch you intend to join before completing your identification details.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                ),
                const SizedBox(height: 24),

                // Matching Branch Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDFA),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.apartment, size: 36, color: Color(0xFF0D9488)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _matchedBranch!.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      const SizedBox(height: 16),
                      _buildRow('Organization Type', _matchedBranch!.organizationType),
                      const SizedBox(height: 12),
                      _buildRow('Address', _matchedBranch!.address),
                      const SizedBox(height: 12),
                      _buildRow('Contact Phone', _matchedBranch!.contactPhone),
                      const SizedBox(height: 12),
                      _buildRow('Invitation Code', _codeController.text.isNotEmpty ? _codeController.text : _matchedBranch!.inviteCode),
                    ],
                  ),
                ),

                const Spacer(),

                // Continue / Next Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _proceedToIdentification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Join This Branch',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/branch/discover'),
                    child: const Text(
                      'Enter a different invitation code',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }
}
