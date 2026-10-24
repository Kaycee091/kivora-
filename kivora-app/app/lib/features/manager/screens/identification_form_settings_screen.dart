import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/kivora_service.dart';

class IdentificationFormSettingsScreen extends StatefulWidget {
  final String branchId;
  const IdentificationFormSettingsScreen({super.key, this.branchId = 'branch-west'});

  @override
  State<IdentificationFormSettingsScreen> createState() => _IdentificationFormSettingsScreenState();
}

class _IdentificationFormSettingsScreenState extends State<IdentificationFormSettingsScreen> {
  late String _branchId;
  late List<IdFormFieldModel> _fields;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _branchId = widget.branchId;
    _loadFields();
  }

  void _loadFields() {
    _fields = KivoraService().getIdFormConfig(_branchId).map((f) => f.copyWith()).toList();
  }

  void _saveChanges() {
    KivoraService().saveIdFormConfig(_branchId, _fields);
    setState(() => _hasUnsavedChanges = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Identification form settings saved persistently.'),
        backgroundColor: Color(0xFF0D9488),
      ),
    );
  }

  void _openFieldEditor([IdFormFieldModel? field]) {
    final isNew = field == null;
    final labelCtrl = TextEditingController(text: field?.label ?? '');
    FieldType selectedType = field?.type ?? FieldType.text;
    bool isRequired = field?.isRequired ?? true;
    bool isEnabled = field?.isEnabled ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            isNew ? 'Add Custom Identification Field' : 'Edit Identification Field',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Field Label / Display Name *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: labelCtrl,
                      decoration: InputDecoration(
                        hintText: 'e.g. National ID Number, Matriculation No.',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Field Input Type', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<FieldType>(
                          value: selectedType,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: FieldType.text, child: Text('Short Text')),
                            DropdownMenuItem(value: FieldType.longText, child: Text('Longer Text / Paragraph')),
                            DropdownMenuItem(value: FieldType.phone, child: Text('Phone Number')),
                            DropdownMenuItem(value: FieldType.email, child: Text('Email Address')),
                            DropdownMenuItem(value: FieldType.date, child: Text('Date')),
                            DropdownMenuItem(value: FieldType.photo, child: Text('Photo or Image Upload')),
                          ],
                          onChanged: (val) {
                            if (val != null) setModalState(() => selectedType = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Mandatory (Required Field)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Applicant cannot submit without filling this', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      value: isRequired,
                      activeColor: const Color(0xFF0D9488),
                      onChanged: (v) => setModalState(() => isRequired = v),
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Enable on Form', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Show this field on branch joining application', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      value: isEnabled,
                      activeColor: const Color(0xFF0D9488),
                      onChanged: (v) => setModalState(() => isEnabled = v),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          final label = labelCtrl.text.trim();
                          if (label.isEmpty) return;

                          setState(() {
                            _hasUnsavedChanges = true;
                            if (isNew) {
                              _fields.add(
                                IdFormFieldModel(
                                  id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                                  label: label,
                                  type: selectedType,
                                  isRequired: isRequired,
                                  isEnabled: isEnabled,
                                  order: _fields.length,
                                ),
                              );
                            } else {
                              field.label = label;
                              field.type = selectedType;
                              field.isRequired = isRequired;
                              field.isEnabled = isEnabled;
                            }
                          });
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(isNew ? 'Add Field' : 'Save Field', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final branch = KivoraService().getBranchById(_branchId);
    final branchName = branch?.name ?? 'Branch';

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
          'Identification Form Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
        actions: [
          if (_hasUnsavedChanges)
            TextButton(
              onPressed: _saveChanges,
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.tune, color: Color(0xFF0D9488), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Branch: $branchName',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Configure what members must provide when applying to join.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _fields.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    _hasUnsavedChanges = true;
                    if (oldIndex < newIndex) newIndex -= 1;
                    final item = _fields.removeAt(oldIndex);
                    _fields.insert(newIndex, item);
                    for (int i = 0; i < _fields.length; i++) {
                      _fields[i].order = i;
                    }
                  });
                },
                itemBuilder: (context, index) {
                  final field = _fields[index];
                  return Container(
                    key: ValueKey(field.id),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: field.isEnabled ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Drag handle
                        const Icon(Icons.drag_indicator, color: Color(0xFFCBD5E1), size: 20),
                        const SizedBox(width: 10),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      field.label,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: field.isEnabled ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: field.isRequired ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      field.isRequired ? 'Required' : 'Optional',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: field.isRequired ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'Type: ${_getFieldTypeName(field.type)}',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '•  ${field.isEnabled ? "Enabled" : "Disabled"}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: field.isEnabled ? const Color(0xFF059669) : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Actions
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF0D9488)),
                          onPressed: () => _openFieldEditor(field),
                          tooltip: 'Edit Field',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                          onPressed: () {
                            setState(() {
                              _hasUnsavedChanges = true;
                              _fields.removeAt(index);
                            });
                          },
                          tooltip: 'Remove Field',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openFieldEditor(),
                      icon: const Icon(Icons.add, size: 18, color: Color(0xFF0D9488)),
                      label: const Text('Add Custom Field', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0D9488)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveChanges,
                      icon: const Icon(Icons.save, size: 18, color: Colors.white),
                      label: const Text('Save Form', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFieldTypeName(FieldType type) {
    switch (type) {
      case FieldType.text:
        return 'Short Text';
      case FieldType.longText:
        return 'Long Text';
      case FieldType.phone:
        return 'Phone';
      case FieldType.email:
        return 'Email';
      case FieldType.date:
        return 'Date';
      case FieldType.photo:
        return 'Photo Upload';
    }
  }
}
