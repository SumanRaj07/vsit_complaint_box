import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/complaint.dart';
import '../providers/complaint_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/section_card.dart';

class SubmitScreen extends StatefulWidget {
  const SubmitScreen({super.key});

  @override
  State<SubmitScreen> createState() => _SubmitScreenState();
}

class _SubmitScreenState extends State<SubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _rollCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  final List<PlatformFile> _attachedFiles = [];

  String? _department;
  String? _year;
  String? _category;
  String _priority = 'medium';
  bool _anonymous = false;
  bool _consent = false;
  String? _submittedId;

  static const departments = [
    'B.Sc Information Technology',
    'B.Sc Computer Science',
    'B.C.A',
    'M.Sc IT',
    'M.Sc CS',
    'MCA',
  ];

  static const years = [
    'First Year',
    'Second Year',
    'Third Year',
    'Post Graduate',
  ];

  static const categories = [
    'Academic',
    'Faculty',
    'Infrastructure',
    'Labs and IT',
    'Library',
    'Canteen',
    'Examination',
    'Ragging or Safety',
    'Other',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rollCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _subjectCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 930;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(wide ? 28 : 16, 22, wide ? 28 : 16, 36),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: _submittedId == null ? _buildForm(wide) : _successView(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm(bool wide) {
    final form = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageTitle(),
          const SizedBox(height: 18),
          SectionCard(
            entranceDelay: const Duration(milliseconds: 60),
            icon: Icons.person_outline,
            title: 'Student Details',
            subtitle:
                'These details help the committee verify and contact you if required.',
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  value: _anonymous,
                  onChanged: (value) => setState(() => _anonymous = value),
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Submit as anonymous complaint',
                    style: TextStyle(
                      color: C.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: const Text(
                    'Admin will see the issue details, but your name, roll number, and email will be hidden.',
                    style: TextStyle(color: C.muted),
                  ),
                  activeThumbColor: C.royal,
                ),
                const Divider(height: 26, color: C.border),
                _ResponsivePair(
                  wide: wide,
                  left: _textField(
                    'Student Name',
                    _nameCtrl,
                    required: !_anonymous,
                    enabled: !_anonymous,
                    hint: 'Enter full name',
                  ),
                  right: _textField(
                    'Roll Number',
                    _rollCtrl,
                    required: !_anonymous,
                    enabled: !_anonymous,
                    hint: 'Example: 2024IT042',
                  ),
                ),
                const SizedBox(height: 14),
                _ResponsivePair(
                  wide: wide,
                  left: _textField(
                    'Email ID',
                    _emailCtrl,
                    required: !_anonymous,
                    enabled: !_anonymous,
                    hint: 'student@vsit.edu.in',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  right: _textField(
                    'Phone Number',
                    _phoneCtrl,
                    hint: 'Optional contact number',
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(height: 14),
                _ResponsivePair(
                  wide: wide,
                  left: _dropdown(
                    'Department',
                    departments,
                    _department,
                    (value) => setState(() => _department = value),
                    required: true,
                  ),
                  right: _dropdown(
                    'Year',
                    years,
                    _year,
                    (value) => setState(() => _year = value),
                    required: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SectionCard(
            entranceDelay: const Duration(milliseconds: 140),
            icon: Icons.report_problem_outlined,
            title: 'Complaint Details',
            subtitle:
                'Give clear information so the concerned cell can take faster action.',
            child: Column(
              children: [
                _ResponsivePair(
                  wide: wide,
                  left: _dropdown(
                    'Complaint Category',
                    categories,
                    _category,
                    (value) => setState(() => _category = value),
                    required: true,
                  ),
                  right: _textField(
                    'Location',
                    _locationCtrl,
                    required: true,
                    hint: 'Example: Lab 3, Library, Canteen',
                  ),
                ),
                const SizedBox(height: 14),
                _textField(
                  'Subject',
                  _subjectCtrl,
                  required: true,
                  hint: 'Write a short subject',
                ),
                const SizedBox(height: 14),
                _textField(
                  'Detailed Description',
                  _descriptionCtrl,
                  required: true,
                  hint:
                      'Mention date, time, location, people involved, and the impact of the issue.',
                  minLines: 5,
                  maxLines: 8,
                ),
                const SizedBox(height: 14),
                _attachmentField(),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FieldLabel('Priority'),
                ),
                const SizedBox(height: 8),
                _prioritySelector(wide),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SectionCard(
            entranceDelay: const Duration(milliseconds: 220),
            icon: Icons.fact_check_outlined,
            title: 'Review and Declaration',
            subtitle:
                'False or misleading complaints may be reviewed under college policy.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  value: _consent,
                  onChanged: (value) =>
                      setState(() => _consent = value ?? false),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: C.royal,
                  title: const Text(
                    'I confirm that the information provided is correct to the best of my knowledge.',
                    style: TextStyle(
                      color: C.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('Submit Complaint'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!wide) return form;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: form),
        const SizedBox(width: 22),
        Expanded(flex: 3, child: _sidePanel()),
      ],
    );
  }

  Widget _pageTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Submit New Complaint',
          style: TextStyle(
            color: C.text,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Use this official form to raise academic, infrastructure, safety, or service-related concerns.',
          style: TextStyle(color: C.muted, fontSize: 14),
        ),
      ],
    );
  }

  Widget _sidePanel() {
    return Column(
      children: [
        SectionCard(
          entranceDelay: const Duration(milliseconds: 120),
          icon: Icons.timeline_outlined,
          title: 'Process Flow',
          subtitle:
              'Every complaint is tracked through a clear resolution cycle.',
          child: Column(
            children: const [
              _InfoStep(
                number: '1',
                title: 'Received',
                text: 'Complaint ID is generated instantly.',
              ),
              _InfoStep(
                number: '2',
                title: 'Assigned',
                text: 'Concerned cell receives the complaint.',
              ),
              _InfoStep(
                number: '3',
                title: 'Action Taken',
                text: 'Admin updates progress and remarks.',
              ),
              _InfoStep(
                number: '4',
                title: 'Resolved',
                text: 'Student can track the final status.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          entranceDelay: const Duration(milliseconds: 200),
          icon: Icons.schedule_outlined,
          title: 'SLA Guidelines',
          subtitle: 'Expected response time by priority.',
          child: Column(
            children: const [
              _SlaRow(
                label: 'High Priority',
                value: '2 working days',
                color: C.danger,
              ),
              _SlaRow(
                label: 'Medium Priority',
                value: '5 working days',
                color: C.warning,
              ),
              _SlaRow(
                label: 'Low Priority',
                value: '7 working days',
                color: C.success,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _successView() {
    return SectionCard(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 650),
            curve: Curves.elasticOut,
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, v, child) =>
                Transform.scale(scale: v, child: child),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: C.success.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: C.success,
                size: 42,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Complaint Submitted Successfully',
            style: TextStyle(
              color: C.text,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Your complaint has been registered in the VSIT grievance system.',
            style: TextStyle(color: C.muted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: C.royal.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: C.royal.withValues(alpha: 0.20)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _submittedId!,
                  style: const TextStyle(
                    color: C.royal,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _submittedId!));
                    _snack('Complaint ID copied.');
                  },
                  child: const Icon(
                    Icons.copy_outlined,
                    color: C.royal,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.add),
                label: const Text('Submit Another'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _submittedId!));
                  _snack('Use Track Status tab to check progress.');
                },
                icon: const Icon(Icons.manage_search_outlined),
                label: const Text('Keep This ID'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _textField(
    String label,
    TextEditingController controller, {
    bool required = false,
    bool enabled = true,
    String? hint,
    TextInputType? keyboardType,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label, required: required),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: maxLines,
          style: const TextStyle(color: C.text, fontSize: 14),
          decoration: InputDecoration(
            hintText: enabled ? hint : 'Hidden for anonymous complaint',
          ),
          validator: required
              ? (value) {
                  if (value == null || value.trim().isEmpty) return 'Required';
                  if (label == 'Email ID' && !value.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _dropdown(
    String label,
    List<String> items,
    String? value,
    ValueChanged<String?> onChanged, {
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label, required: required),
        const SizedBox(height: 7),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(hintText: 'Select $label'),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
          validator: required
              ? (value) => value == null || value.isEmpty ? 'Required' : null
              : null,
        ),
      ],
    );
  }

  Widget _prioritySelector(bool wide) {
    final items = [
      ('low', 'Low', 'General issue', '7 days', C.success),
      ('medium', 'Medium', 'Needs attention', '5 days', C.warning),
      ('high', 'High', 'Urgent impact', '2 days', C.danger),
    ];

    Widget tile((String, String, String, String, Color) item) {
      final selected = _priority == item.$1;
      return InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => _priority = item.$1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: selected ? item.$5.withValues(alpha: 0.10) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? item.$5 : C.border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: item.$5,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    item.$2,
                    style: TextStyle(
                      color: item.$5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                item.$3,
                style: const TextStyle(
                  color: C.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'SLA: ${item.$4}',
                style: const TextStyle(color: C.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    if (wide) {
      return Row(
        children: [
          Expanded(child: tile(items[0])),
          const SizedBox(width: 10),
          Expanded(child: tile(items[1])),
          const SizedBox(width: 10),
          Expanded(child: tile(items[2])),
        ],
      );
    }

    return Column(
      children: [
        tile(items[0]),
        const SizedBox(height: 10),
        tile(items[1]),
        const SizedBox(height: 10),
        tile(items[2]),
      ],
    );
  }

  Widget _attachmentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel('Attachments'),
        const SizedBox(height: 7),
        DottedAttachBox(onTap: _pickFiles, hasFiles: _attachedFiles.isNotEmpty),
        if (_attachedFiles.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_attachedFiles.length, (i) {
              final f = _attachedFiles[i];
              return Container(
                padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
                decoration: BoxDecoration(
                  color: C.royal.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: C.royal.withValues(alpha: 0.22)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_iconForFile(f.extension), size: 16, color: C.royal),
                    const SizedBox(width: 7),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 180),
                      child: Text(
                        f.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: C.text,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatSize(f.size),
                      style: const TextStyle(color: C.muted, fontSize: 11),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => setState(() => _attachedFiles.removeAt(i)),
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(Icons.close, size: 15, color: C.muted),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.pickFiles(
        allowMultiple: true,
        withData: false,
        type: FileType.custom,
        allowedExtensions: const [
          'jpg',
          'jpeg',
          'png',
          'gif',
          'webp',
          'pdf',
          'doc',
          'docx',
          'txt',
          'mp4',
          'mov',
        ],
      );
      if (result == null) return;
      setState(() {
        for (final f in result.files) {
          final already = _attachedFiles.any(
            (e) => e.name == f.name && e.size == f.size,
          );
          if (!already) _attachedFiles.add(f);
        }
      });
    } catch (e) {
      _snack('Could not open file picker: $e');
    }
  }

  IconData _iconForFile(String? ext) {
    switch ((ext ?? '').toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image_outlined;
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'doc':
      case 'docx':
      case 'txt':
        return Icons.description_outlined;
      case 'mp4':
      case 'mov':
        return Icons.videocam_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_consent) {
      _snack('Please accept the declaration before submitting.');
      return;
    }

    final provider = context.read<ComplaintProvider>();
    final now = DateTime.now();
    final id = provider.generateId();

    provider.add(
      Complaint(
        id: id,
        name: _anonymous ? 'Anonymous' : _nameCtrl.text.trim(),
        roll: _anonymous ? '-' : _rollCtrl.text.trim(),
        email: _anonymous ? '-' : _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        department: _department!,
        year: _year!,
        category: _category!,
        location: _locationCtrl.text.trim(),
        subject: _subjectCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        priority: _priority,
        anonymous: _anonymous,
        attachments: _attachedFiles
            .map((f) => f.path ?? f.name)
            .toList(growable: false),
        status: ComplaintStatus.received,
        assignedTo: 'Student Affairs Office',
        adminNote: 'Complaint received. Awaiting review by grievance cell.',
        createdAt: ComplaintProvider.formatDate(now),
        updatedAt: ComplaintProvider.formatDate(now),
        timestamp: now.millisecondsSinceEpoch,
      ),
    );

    setState(() => _submittedId = id);
  }

  void _reset() {
    _formKey.currentState?.reset();
    _nameCtrl.clear();
    _rollCtrl.clear();
    _emailCtrl.clear();
    _phoneCtrl.clear();
    _locationCtrl.clear();
    _subjectCtrl.clear();
    _descriptionCtrl.clear();
    _attachedFiles.clear();
    setState(() {
      _department = null;
      _year = null;
      _category = null;
      _priority = 'medium';
      _anonymous = false;
      _consent = false;
      _submittedId = null;
    });
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class DottedAttachBox extends StatelessWidget {
  final VoidCallback onTap;
  final bool hasFiles;

  const DottedAttachBox({
    super.key,
    required this.onTap,
    required this.hasFiles,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: C.royal.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: C.royal.withValues(alpha: 0.30),
            width: 1.4,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              color: C.royal.withValues(alpha: 0.85),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              hasFiles ? 'Add more files' : 'Attach files or photos',
              style: const TextStyle(
                color: C.royal,
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              'Images, PDF, DOC, TXT, or video as proof (optional)',
              textAlign: TextAlign.center,
              style: TextStyle(color: C.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResponsivePair extends StatelessWidget {
  final bool wide;
  final Widget left;
  final Widget right;

  const _ResponsivePair({
    required this.wide,
    required this.left,
    required this.right,
  });

  @override
  Widget build(BuildContext context) {
    if (!wide) {
      return Column(children: [left, const SizedBox(height: 14), right]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 14),
        Expanded(child: right),
      ],
    );
  }
}

class _InfoStep extends StatelessWidget {
  final String number;
  final String title;
  final String text;

  const _InfoStep({
    required this.number,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: C.royal,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: C.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: const TextStyle(
                    color: C.muted,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlaRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SlaRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: C.text,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: C.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
