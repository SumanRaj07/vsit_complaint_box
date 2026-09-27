import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';

import '../../models/complaint.dart';
import '../../providers/complaint_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animations.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/section_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _searchCtrl = TextEditingController();
  String _status = 'All';
  String _category = 'All';
  String _priority = 'All';
  bool _overdueOnly = false;

  static const categories = [
    'All',
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
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Dashboard',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            Text(
              'Complaint Management Console',
              style: TextStyle(color: Color(0xFFD8E2F3), fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.logout_outlined,
              color: Colors.white,
              size: 18,
            ),
            label: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<ComplaintProvider>(
        builder: (context, provider, _) {
          if (!provider.loaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final filtered = provider.filtered(
            status: _status,
            category: _category,
            priority: _priority,
            query: _searchCtrl.text,
            overdueOnly: _overdueOnly,
          );

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  width > 900 ? 24 : 14,
                  18,
                  width > 900 ? 24 : 14,
                  0,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _summaryGrid(provider, width),
                        const SizedBox(height: 16),
                        _filters(provider, width),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'Showing ${filtered.length} complaint(s)',
                              style: const TextStyle(
                                color: C.text,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Spacer(),
                            if (_overdueOnly)
                              const StatusPill(
                                text: 'Overdue only',
                                color: C.danger,
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: filtered.isEmpty
                              ? _emptyState()
                              : ListView.separated(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  itemBuilder: (context, index) =>
                                      FadeSlideIn(
                                        delay: Duration(
                                          milliseconds: 40 * (index % 6),
                                        ),
                                        child: _ComplaintTile(
                                          complaint: filtered[index],
                                        ),
                                      ),
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 12),
                                  itemCount: filtered.length,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _summaryGrid(ComplaintProvider provider, double width) {
    final columns = width > 1050
        ? 5
        : width > 720
        ? 3
        : 2;
    final cards = [
      _SummaryData(
        'Total',
        provider.all.length,
        Icons.inbox_outlined,
        C.royal,
      ),
      _SummaryData(
        'Open',
        provider.openCount,
        Icons.pending_actions_outlined,
        C.info,
      ),
      _SummaryData(
        'High Priority',
        provider.countPriority('high'),
        Icons.priority_high_outlined,
        C.danger,
      ),
      _SummaryData(
        'Overdue',
        provider.overdueCount,
        Icons.timer_off_outlined,
        C.warning,
      ),
      _SummaryData(
        'Resolved',
        provider.countStatus(ComplaintStatus.resolved),
        Icons.check_circle_outline,
        C.success,
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: width > 720 ? 2.5 : 2.05,
      children: List.generate(
        cards.length,
        (i) => FadeSlideIn(
          delay: Duration(milliseconds: 50 * i),
          child: _SummaryCard(cards[i]),
        ),
      ),
    );
  }

  Widget _filters(ComplaintProvider provider, double width) {
    final controlWidth = width > 900
        ? 260.0
        : width > 620
        ? 220.0
        : width - 28;
    return SectionCard(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: controlWidth,
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search ID, student, roll, subject',
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          _drop(
            width: controlWidth,
            value: _status,
            values: const ['All', ...ComplaintStatus.all],
            onChanged: (value) => setState(() => _status = value!),
          ),
          _drop(
            width: controlWidth,
            value: _category,
            values: categories,
            onChanged: (value) => setState(() => _category = value!),
          ),
          _drop(
            width: controlWidth,
            value: _priority,
            values: const ['All', 'high', 'medium', 'low'],
            labels: const {
              'high': 'High Priority',
              'medium': 'Medium Priority',
              'low': 'Low Priority',
            },
            onChanged: (value) => setState(() => _priority = value!),
          ),
          FilterChip(
            selected: _overdueOnly,
            onSelected: (value) => setState(() => _overdueOnly = value),
            label: const Text('Overdue only'),
            avatar: const Icon(Icons.timer_off_outlined, size: 18),
            selectedColor: C.danger.withValues(alpha: 0.12),
            checkmarkColor: C.danger,
          ),
          OutlinedButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
            label: const Text('Clear'),
          ),
          ElevatedButton.icon(
            onPressed: () => _export(provider),
            icon: const Icon(Icons.file_download_outlined),
            label: const Text('Copy CSV'),
          ),
          TextButton.icon(
            onPressed: () => _confirmReset(provider),
            icon: const Icon(Icons.restart_alt_outlined),
            label: const Text('Reset demo'),
          ),
        ],
      ),
    );
  }

  Widget _drop({
    required double width,
    required String value,
    required List<String> values,
    required ValueChanged<String?> onChanged,
    Map<String, String> labels = const {},
  }) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        ),
        items: values
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  labels[item] ?? item,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.inbox_outlined, color: C.muted, size: 46),
          SizedBox(height: 10),
          Text(
            'No complaints match the selected filters.',
            style: TextStyle(color: C.muted, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    _searchCtrl.clear();
    setState(() {
      _status = 'All';
      _category = 'All';
      _priority = 'All';
      _overdueOnly = false;
    });
  }

  void _export(ComplaintProvider provider) {
    Clipboard.setData(ClipboardData(text: provider.exportCsv()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CSV report copied to clipboard.')),
    );
  }

  void _confirmReset(ComplaintProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Demo Data'),
        content: const Text(
          'This replaces the local complaint list with sample demo complaints.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.resetDemoData();
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _ComplaintTile extends StatelessWidget {
  final Complaint complaint;

  const _ComplaintTile({required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: complaint.isOverdue
              ? C.danger.withValues(alpha: 0.35)
              : C.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100D1B3E),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _openDetail(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                complaint.id,
                                style: const TextStyle(
                                  color: C.royal,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                complaint.createdAt,
                                style: const TextStyle(
                                  color: C.muted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (complaint.isOverdue)
                                const StatusPill(
                                  text: 'Overdue',
                                  color: C.danger,
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            complaint.subject,
                            style: const TextStyle(
                              color: C.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    StatusBadge(complaint.status),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  complaint.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: C.muted,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _MiniInfo(
                      icon: Icons.person_outline,
                      text: complaint.anonymous ? 'Anonymous' : complaint.name,
                    ),
                    _MiniInfo(
                      icon: Icons.business_outlined,
                      text: complaint.department,
                    ),
                    _MiniInfo(
                      icon: Icons.category_outlined,
                      text: complaint.category,
                    ),
                    _MiniInfo(
                      icon: Icons.account_tree_outlined,
                      text: complaint.assignedTo,
                    ),
                    if (complaint.attachments.isNotEmpty)
                      _MiniInfo(
                        icon: Icons.attach_file,
                        text:
                            '${complaint.attachments.length} attachment${complaint.attachments.length == 1 ? '' : 's'}',
                      ),
                    PriorityBadge(complaint.priority),
                    SlaBadge(complaint),
                  ],
                ),
                const Divider(height: 24, color: C.border),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _openDetail(context),
                      icon: const Icon(Icons.visibility_outlined, size: 17),
                      label: const Text('View'),
                    ),
                    if (complaint.status == ComplaintStatus.received)
                      OutlinedButton.icon(
                        onPressed: () =>
                            context.read<ComplaintProvider>().updateComplaint(
                              complaint.id,
                              status: ComplaintStatus.assigned,
                            ),
                        icon: const Icon(
                          Icons.assignment_ind_outlined,
                          size: 17,
                        ),
                        label: const Text('Assign'),
                      ),
                    if (complaint.status != ComplaintStatus.resolved &&
                        complaint.status != ComplaintStatus.closed)
                      OutlinedButton.icon(
                        onPressed: () =>
                            context.read<ComplaintProvider>().updateComplaint(
                              complaint.id,
                              status: ComplaintStatus.underReview,
                            ),
                        icon: const Icon(Icons.rate_review_outlined, size: 17),
                        label: const Text('Review'),
                      ),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<ComplaintProvider>().updateComplaint(
                            complaint.id,
                            status: ComplaintStatus.resolved,
                          ),
                      icon: const Icon(Icons.check_circle_outline, size: 17),
                      label: const Text('Resolve'),
                    ),
                    TextButton.icon(
                      onPressed: () => _confirmDelete(context),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: C.danger,
                        size: 17,
                      ),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: C.danger),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ComplaintDetailSheet(complaint: complaint),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Complaint'),
        content: Text('Delete ${complaint.id}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ComplaintProvider>().delete(complaint.id);
              Navigator.pop(dialogContext);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: C.danger, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplaintDetailSheet extends StatefulWidget {
  final Complaint complaint;

  const _ComplaintDetailSheet({required this.complaint});

  @override
  State<_ComplaintDetailSheet> createState() => _ComplaintDetailSheetState();
}

class _ComplaintDetailSheetState extends State<_ComplaintDetailSheet> {
  late String _status;
  late String _assignedTo;
  late final TextEditingController _noteCtrl;

  static const officers = [
    'Student Affairs Office',
    'Academic Coordinator',
    'IT Infrastructure Cell',
    'Examination Cell',
    'Library Committee',
    'Canteen Committee',
    'Anti-Ragging Cell',
    'Administrative Office',
  ];

  @override
  void initState() {
    super.initState();
    _status = widget.complaint.status;
    _assignedTo = officers.contains(widget.complaint.assignedTo)
        ? widget.complaint.assignedTo
        : officers.first;
    _noteCtrl = TextEditingController(text: widget.complaint.adminNote);
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.complaint;
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.96,
      minChildSize: 0.52,
      expand: false,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: C.bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: C.border,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.id,
                            style: const TextStyle(
                              color: C.royal,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            c.subject,
                            style: const TextStyle(
                              color: C.text,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
                  children: [
                    SectionCard(
                      title: 'Student and Complaint Information',
                      child: Column(
                        children: [
                          _DetailRow(
                            'Submitted By',
                            c.anonymous ? 'Anonymous' : c.name,
                          ),
                          _DetailRow('Roll Number', c.roll),
                          _DetailRow('Email', c.email),
                          _DetailRow('Phone', c.phone.isEmpty ? '-' : c.phone),
                          _DetailRow('Department', c.department),
                          _DetailRow('Year', c.year),
                          _DetailRow('Category', c.category),
                          _DetailRow('Location', c.location),
                          _DetailRow('Submitted On', c.createdAt),
                          _DetailRow('Last Updated', c.updatedAt),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                PriorityBadge(c.priority),
                                SlaBadge(c),
                              ],
                            ),
                          ),
                          const Divider(height: 26, color: C.border),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              c.description,
                              style: const TextStyle(
                                color: C.text,
                                height: 1.55,
                              ),
                            ),
                          ),
                          if (c.attachments.isNotEmpty) ...[
                            const Divider(height: 26, color: C.border),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: FieldLabel('Attachments'),
                            ),
                            const SizedBox(height: 8),
                            Column(
                              children: c.attachments
                                  .map((path) => _AttachmentTile(path: path))
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      title: 'Admin Action',
                      subtitle:
                          'Update complaint status, assign officer, and add the latest remark.',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FieldLabel('Status'),
                          const SizedBox(height: 7),
                          DropdownButtonFormField<String>(
                            initialValue: _status,
                            isExpanded: true,
                            items: ComplaintStatus.all
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _status = value!),
                          ),
                          const SizedBox(height: 14),
                          const FieldLabel('Assigned To'),
                          const SizedBox(height: 7),
                          DropdownButtonFormField<String>(
                            initialValue: _assignedTo,
                            isExpanded: true,
                            items: officers
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _assignedTo = value!),
                          ),
                          const SizedBox(height: 14),
                          const FieldLabel('Admin Note'),
                          const SizedBox(height: 7),
                          TextField(
                            controller: _noteCtrl,
                            minLines: 4,
                            maxLines: 6,
                            decoration: const InputDecoration(
                              hintText:
                                  'Add action taken, pending requirement, or final resolution note.',
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _save,
                              icon: const Icon(Icons.save_outlined),
                              label: const Text('Save Admin Update'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _save() {
    context.read<ComplaintProvider>().updateComplaint(
      widget.complaint.id,
      status: _status,
      assignedTo: _assignedTo,
      adminNote: _noteCtrl.text.trim(),
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Admin update saved.')));
  }
}

class _SummaryData {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _SummaryData(this.label, this.value, this.icon, this.color);
}

class _SummaryCard extends StatelessWidget {
  final _SummaryData data;

  const _SummaryCard(this.data);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: C.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100D1B3E),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(data.icon, color: data.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CountUpText(
                  data.value,
                  style: TextStyle(
                    color: data.color,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  data.label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: C.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
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

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: C.muted),
        const SizedBox(width: 4),
        Text(
          text.length > 28 ? '${text.substring(0, 28)}...' : text,
          style: const TextStyle(
            color: C.muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  final String path;
  const _AttachmentTile({required this.path});

  String get _name {
    final norm = path.replaceAll('\\', '/');
    return norm.contains('/') ? norm.split('/').last : norm;
  }

  IconData get _icon {
    final ext = _name.contains('.') ? _name.split('.').last.toLowerCase() : '';
    switch (ext) {
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
          final result = await OpenFilex.open(path);
          if (result.type != ResultType.done && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cannot open file: ${result.message}')),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: C.bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: C.border),
          ),
          child: Row(
            children: [
              Icon(_icon, size: 18, color: C.royal),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: C.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.open_in_new, size: 15, color: C.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                color: C.muted,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                color: C.text,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  final String text;
  final Color color;

  const StatusPill({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
