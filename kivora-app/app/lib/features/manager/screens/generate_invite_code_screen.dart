import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/services/kivora_service.dart';

class GenerateInviteCodeScreen extends StatefulWidget {
  final String? branchId;
  const GenerateInviteCodeScreen({super.key, this.branchId});

  @override
  State<GenerateInviteCodeScreen> createState() => _GenerateInviteCodeScreenState();
}

class _GenerateInviteCodeScreenState extends State<GenerateInviteCodeScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  List<BranchInviteCodeModel> _codes = [];
  BranchInviteCodeModel? _activeCode;

  // New code form controllers
  final TextEditingController _customCodeController = TextEditingController();
  final TextEditingController _maxUsesController = TextEditingController(text: '50');
  bool _unlimitedUses = false;
  bool _noExpiry = false;
  DateTime? _selectedExpiryDate = DateTime.now().add(const Duration(days: 30));
  bool _showCreateForm = false;

  @override
  void initState() {
    super.initState();
    _loadInviteCodes();
  }

  @override
  void dispose() {
    _customCodeController.dispose();
    _maxUsesController.dispose();
    super.dispose();
  }

  String get _effectiveBranchId =>
      widget.branchId ?? KivoraService().currentBranchId ?? '';

  Future<void> _loadInviteCodes() async {
    setState(() => _isLoading = true);
    final branchId = _effectiveBranchId;
    if (branchId.isNotEmpty) {
      try {
        final codes = await KivoraService().fetchInviteCodesForBranch(branchId);
        if (mounted) {
          setState(() {
            _codes = codes;
            _activeCode = codes.cast<BranchInviteCodeModel?>().firstWhere(
                  (c) => c != null && c.isActive,
                  orElse: () => codes.isNotEmpty ? codes.first : null,
                );
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load invite codes: $e'),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _generateRandom() {
    final branch = KivoraService().getBranchById(_effectiveBranchId);
    final prefix = (branch != null && branch.name.isNotEmpty)
        ? (branch.name.length >= 3 ? branch.name.substring(0, 3).toUpperCase() : 'KIV')
        : 'KIV';
    final randomCode = KivoraService.generateSecureRandomCode(prefix: prefix);
    setState(() {
      _customCodeController.text = randomCode;
    });
  }

  Future<void> _copyToClipboard(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text('Invite code "$code" copied')),
            ],
          ),
          backgroundColor: const Color(0xFF0D9488),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? now.add(const Duration(days: 30)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D9488),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedExpiryDate = picked;
        _noExpiry = false;
      });
    }
  }

  Future<void> _handleCreateOrReplaceCode() async {
    final code = _customCodeController.text.trim().toUpperCase();
    if (code.isEmpty || code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter or generate a code with at least 4 characters.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final int? maxUses = _unlimitedUses
        ? null
        : int.tryParse(_maxUsesController.text.trim());
    final DateTime? expiry = _noExpiry ? null : _selectedExpiryDate;

    // Show confirmation dialog before replacing active code
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm New Invite Code'),
        content: Text(
          _activeCode != null && _activeCode!.isActive
              ? 'Activating "$code" will supersede your current active code "${_activeCode!.code}". Prospective members must use the new code. Continue?'
              : 'Create and activate new invitation code "$code"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
            ),
            child: const Text('Confirm & Activate', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);
    try {
      final created = await KivoraService().createInviteCode(
        branchId: _effectiveBranchId,
        code: code,
        maxUses: maxUses,
        expiresAt: expiry,
        allowedRoles: const ['member'],
        revokeExisting: true,
      );

      if (mounted) {
        setState(() {
          _isSaving = false;
          _showCreateForm = false;
          _customCodeController.clear();
        });
        await _loadInviteCodes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invite code "${created.code}" is now live and active!'),
              backgroundColor: const Color(0xFF0D9488),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save invite code: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _handleRevokeCode(BranchInviteCodeModel code) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revoke Invite Code'),
        content: Text(
          'Are you sure you want to revoke code "${code.code}"? Prospective members will no longer be able to use this code to join.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Revoke Code', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);
    try {
      await KivoraService().revokeInviteCode(
        inviteCodeId: code.id,
        branchId: _effectiveBranchId,
      );
      await _loadInviteCodes();
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Code "${code.code}" has been revoked.'),
            backgroundColor: const Color(0xFF0F172A),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to revoke code: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _handleReactivateCode(BranchInviteCodeModel code) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reactivate Invite Code'),
        content: Text('Reactivate code "${code.code}" so prospective members can use it again?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
            ),
            child: const Text('Reactivate', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);
    try {
      await KivoraService().reactivateInviteCode(
        inviteCodeId: code.id,
        branchId: _effectiveBranchId,
      );
      await _loadInviteCodes();
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Code "${code.code}" has been reactivated.'),
            backgroundColor: const Color(0xFF0D9488),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reactivate code: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final branch = KivoraService().getBranchById(_effectiveBranchId);
    final branchName = branch?.name ?? 'Techverve Branch';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Branch Invite Codes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF64748B)),
            tooltip: 'Refresh codes',
            onPressed: _loadInviteCodes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Branch Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDFA),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.domain, color: Color(0xFF0D9488), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              branchName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            const Text(
                              'Manage member onboarding invitation codes',
                              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 1. Current Active Invite Code Card
                  if (_activeCode != null) ...[
                    _buildActiveCodeCard(_activeCode!),
                  ] else ...[
                    _buildNoActiveCodeCard(),
                  ],

                  const SizedBox(height: 24),

                  // 2. Create or Replace Code Section
                  _buildCreateOrReplaceSection(),

                  const SizedBox(height: 28),

                  // 3. History of Past Invite Codes
                  Text(
                    'All Invite Codes (${_codes.length})',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 12),

                  if (_codes.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Center(
                        child: Text(
                          'No invite codes created yet for this branch.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                      ),
                    )
                  else
                    ..._codes.map((code) => _buildHistoryCodeTile(code)),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildActiveCodeCard(BranchInviteCodeModel code) {
    final statusColor = _getStatusColor(code);
    final statusBg = _getStatusBg(code);
    final expiryText = code.expiresAt != null
        ? 'Expires ${DateFormat('MMM d, yyyy').format(code.expiresAt!)}'
        : 'Never expires';
    final usesText = code.maxUses != null
        ? '${code.usedCount} of ${code.maxUses} uses'
        : '${code.usedCount} uses (Unlimited)';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CURRENT INVITE CODE',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1.2),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  code.statusDisplay.toUpperCase(),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor, letterSpacing: 0.5),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Big Code Display
          SelectableText(
            code.code,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0D9488),
              letterSpacing: 3,
              fontFamily: 'monospace',
            ),
          ),

          const SizedBox(height: 12),

          // Metadata row (Uses & Expiry)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people_alt_outlined, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(usesText, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                  ],
                ),
                Container(width: 1, height: 16, color: const Color(0xFFE2E8F0)),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(expiryText, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () => _copyToClipboard(code.code),
                    icon: const Icon(Icons.copy, size: 16, color: Colors.white),
                    label: const Text('Copy Code', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (!code.isRevoked)
                SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: _isSaving ? null : () => _handleRevokeCode(code),
                    icon: const Icon(Icons.block, size: 16, color: Color(0xFFEF4444)),
                    label: const Text('Revoke', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: _isSaving ? null : () => _handleReactivateCode(code),
                    icon: const Icon(Icons.check, size: 16, color: Color(0xFF0D9488)),
                    label: const Text('Reactivate', style: TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0D9488)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoActiveCodeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 36),
          const SizedBox(height: 10),
          const Text(
            'No Active Invite Code',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Prospective members cannot join your branch until an active invitation code is created.',
            style: TextStyle(fontSize: 12.5, color: Color(0xFFB45309)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () => setState(() => _showCreateForm = true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              elevation: 0,
            ),
            child: const Text('Create Invite Code Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateOrReplaceSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.add_circle_outline, color: Color(0xFF0D9488), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _activeCode != null ? 'Create or Replace Code' : 'Create New Invite Code',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => setState(() => _showCreateForm = !_showCreateForm),
                child: Text(_showCreateForm ? 'Hide' : 'Customize', style: const TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold)),
              ),
            ],
          ),

          if (_showCreateForm) ...[
            const Divider(height: 24, color: Color(0xFFF1F5F9)),

            // Code input row
            const Text(
              'Invite Code *',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customCodeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'e.g. TECHVERVE-2026',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _generateRandom,
                  icon: const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF0D9488)),
                  label: const Text('Generate', style: TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0D9488)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ],
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _customCodeController,
              builder: (context, value, _) {
                final generatedText = value.text.trim();
                if (generatedText.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Preview: $generatedText (Save & Activate to apply)',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please tap "Save & Activate Code" first to save before copying.'),
                              backgroundColor: Color(0xFFF59E0B),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 14, color: Color(0xFF94A3B8)),
                        label: const Text('Copy', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Maximum uses setting
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Maximum Uses',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                ),
                Row(
                  children: [
                    const Text('Unlimited', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    Switch.adaptive(
                      value: _unlimitedUses,
                      activeColor: const Color(0xFF0D9488),
                      onChanged: (val) => setState(() => _unlimitedUses = val),
                    ),
                  ],
                ),
              ],
            ),
            if (!_unlimitedUses) ...[
              TextField(
                controller: _maxUsesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '50',
                  suffixText: 'uses',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Expiry date setting
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Expiration Date',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                ),
                Row(
                  children: [
                    const Text('No Expiry', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    Switch.adaptive(
                      value: _noExpiry,
                      activeColor: const Color(0xFF0D9488),
                      onChanged: (val) => setState(() => _noExpiry = val),
                    ),
                  ],
                ),
              ],
            ),
            if (!_noExpiry) ...[
              InkWell(
                onTap: _pickExpiryDate,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedExpiryDate != null
                            ? DateFormat('EEEE, MMMM d, yyyy').format(_selectedExpiryDate!)
                            : 'Select Expiry Date',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                      ),
                      const Icon(Icons.calendar_today, size: 16, color: Color(0xFF0D9488)),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleCreateOrReplaceCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Save & Activate Code',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryCodeTile(BranchInviteCodeModel code) {
    final statusColor = _getStatusColor(code);
    final statusBg = _getStatusBg(code);
    final dateStr = code.createdAt != null
        ? DateFormat('MMM d, yyyy').format(code.createdAt!)
        : 'Unknown date';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      code.code,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        code.statusDisplay,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Created $dateStr • ${code.usedCount} ${code.maxUses != null ? '/ ${code.maxUses}' : ''} uses',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18, color: Color(0xFF64748B)),
            tooltip: 'Copy code',
            onPressed: () => _copyToClipboard(code.code),
          ),
          if (!code.isRevoked)
            IconButton(
              icon: const Icon(Icons.block, size: 18, color: Color(0xFFEF4444)),
              tooltip: 'Revoke',
              onPressed: () => _handleRevokeCode(code),
            )
          else
            IconButton(
              icon: const Icon(Icons.check, size: 18, color: Color(0xFF0D9488)),
              tooltip: 'Reactivate',
              onPressed: () => _handleReactivateCode(code),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(BranchInviteCodeModel code) {
    if (code.isRevoked) return const Color(0xFFEF4444);
    if (code.isExpired) return const Color(0xFFF59E0B);
    if (code.isExhausted) return const Color(0xFF8B5CF6);
    return const Color(0xFF059669);
  }

  Color _getStatusBg(BranchInviteCodeModel code) {
    if (code.isRevoked) return const Color(0xFFFEF2F2);
    if (code.isExpired) return const Color(0xFFFFFBEB);
    if (code.isExhausted) return const Color(0xFFF5F3FF);
    return const Color(0xFFECFDF5);
  }
}
