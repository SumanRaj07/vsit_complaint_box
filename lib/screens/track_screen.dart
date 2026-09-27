import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/complaint.dart';
import '../providers/complaint_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/priority_badge.dart';
import '../widgets/section_card.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  final _ctrl = TextEditingController();
  String? _searchedId;
  int _rating = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ComplaintProvider>(
      builder: (context, provider, _) {
        final complaint = _searchedId == null
            ? null
            : provider.findById(_searchedId!);

        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 880;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                wide ? 28 : 16,
                22,
                wide ? 28 : 16,
                36,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Track Complaint Status',
                        style: TextStyle(
                          color: C.text,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Enter your complaint ID to view status, assigned office, timeline, and latest admin note.',
                        style: TextStyle(color: C.muted, fontSize: 14),
                      ),
                      const SizedBox(height: 18),
                      _searchCard(),
                      const SizedBox(height: 18),
                      if (_searchedId != null && complaint == null) _notFound(),
                      if (complaint != null) _resultLayout(complaint, wide),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _searchCard() {
    return SectionCard(
      entranceDelay: const Duration(milliseconds: 60),
      icon: Icons.manage_search_outlined,
      title: 'Complaint Lookup',
      subtitle: 'Complaint IDs follow this format: VSIT-2026-1001',
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                color: C.text,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.7,
              ),
              decoration: const InputDecoration(hintText: 'Enter Complaint ID'),
              onSubmitted: (_) => _search(),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: _search,
            icon: const Icon(Icons.search_outlined),
            label: const Text('Track'),
          ),
        ],
      ),
    );
  }

  Widget _notFound() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.danger.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: C.danger.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: C.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'No complaint found for ${_searchedId ?? ''}. Please check the ID and try again.',
              style: const TextStyle(
                color: C.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultLayout(Complaint complaint, bool wide) {
    final left = Column(
      children: [
        _summaryCard(complaint),
        const SizedBox(height: 18),
        _timelineCard(complaint),
      ],
    );

    final right = Column(
      children: [
        _detailsCard(complaint),
        const SizedBox(height: 18),
        _helpCard(),
        if (complaint.status == ComplaintStatus.resolved ||
            complaint.status == ComplaintStatus.closed) ...[
          const SizedBox(height: 18),
          _feedbackCard(),
        ],
      ],
    );

    if (!wide) {
      return Column(children: [left, const SizedBox(height: 18), right]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 6, child: left),
        const SizedBox(width: 18),
        Expanded(flex: 4, child: right),
      ],
    );
  }

  Widget _summaryCard(Complaint c) {
    return SectionCard(
      entranceDelay: const Duration(milliseconds: 60),
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
                    Row(
                      children: [
                        Text(
                          c.id,
                          style: const TextStyle(
                            color: C.royal,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: c.id));
                            _snack('Complaint ID copied.');
                          },
                          child: const Icon(
                            Icons.copy_outlined,
                            color: C.muted,
                            size: 17,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c.subject,
                      style: const TextStyle(
                        color: C.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              StatusBadge(c.status),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [PriorityBadge(c.priority), SlaBadge(c)],
          ),
          const Divider(height: 28, color: C.border),
          _DetailLine(
            label: 'Assigned Office',
            value: c.assignedTo,
            icon: Icons.account_tree_outlined,
          ),
          const SizedBox(height: 10),
          _DetailLine(
            label: 'Latest Admin Note',
            value: c.adminNote.isEmpty ? 'No remark added yet.' : c.adminNote,
            icon: Icons.notes_outlined,
          ),
        ],
      ),
    );
  }

  Widget _timelineCard(Complaint c) {
    final activeIndex = _activeIndex(c.status);
    return SectionCard(
      entranceDelay: const Duration(milliseconds: 160),
      icon: Icons.timeline_outlined,
      title: 'Resolution Timeline',
      subtitle:
          'The progress below updates whenever the admin changes complaint status.',
      child: Column(
        children: List.generate(ComplaintStatus.trackingSteps.length, (index) {
          final step = ComplaintStatus.trackingSteps[index];
          final done = index <= activeIndex;
          final color = done ? C.royal : C.border;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: done ? C.royal : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 2),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: done
                            ? const Icon(
                                key: ValueKey('done'),
                                Icons.check,
                                color: Colors.white,
                                size: 17,
                              )
                            : Center(
                                key: const ValueKey('pending'),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: C.muted,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    if (index != ComplaintStatus.trackingSteps.length - 1)
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 2,
                          color: done
                              ? C.royal.withValues(alpha: 0.35)
                              : C.border,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step,
                          style: TextStyle(
                            color: done ? C.text : C.muted,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _stepText(step),
                          style: const TextStyle(
                            color: C.muted,
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _detailsCard(Complaint c) {
    return SectionCard(
      entranceDelay: const Duration(milliseconds: 100),
      icon: Icons.description_outlined,
      title: 'Complaint Details',
      subtitle: 'Information submitted with the complaint.',
      child: Column(
        children: [
          _DetailLine(
            label: 'Student',
            value: c.name,
            icon: Icons.person_outline,
          ),
          _DetailLine(
            label: 'Roll Number',
            value: c.roll,
            icon: Icons.badge_outlined,
          ),
          _DetailLine(
            label: 'Department',
            value: c.department,
            icon: Icons.business_outlined,
          ),
          _DetailLine(
            label: 'Category',
            value: c.category,
            icon: Icons.category_outlined,
          ),
          _DetailLine(
            label: 'Location',
            value: c.location,
            icon: Icons.place_outlined,
          ),
          _DetailLine(
            label: 'Submitted On',
            value: c.createdAt,
            icon: Icons.calendar_today_outlined,
          ),
          const Divider(height: 26, color: C.border),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              c.description,
              style: const TextStyle(
                color: C.text,
                fontSize: 13.5,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _helpCard() {
    return const SectionCard(
      entranceDelay: Duration(milliseconds: 180),
      icon: Icons.support_agent_outlined,
      title: 'Need Assistance?',
      subtitle:
          'For urgent issues, contact the Student Affairs Office directly.',
      child: Column(
        children: [
          _DetailLine(
            label: 'Email',
            value: 'grievance@vsit.edu.in',
            icon: Icons.email_outlined,
          ),
          _DetailLine(
            label: 'Phone',
            value: '+91 22 2788 1234',
            icon: Icons.phone_outlined,
          ),
          _DetailLine(
            label: 'Office',
            value: 'Ground Floor, VSIT Campus',
            icon: Icons.location_city_outlined,
          ),
        ],
      ),
    );
  }

  Widget _feedbackCard() {
    return SectionCard(
      entranceDelay: const Duration(milliseconds: 240),
      icon: Icons.rate_review_outlined,
      title: 'Resolution Feedback',
      subtitle: 'Optional local feedback for the resolved complaint.',
      child: Row(
        children: List.generate(5, (index) {
          final selected = index < _rating;
          return IconButton(
            onPressed: () => setState(() => _rating = index + 1),
            icon: Icon(
              selected ? Icons.star : Icons.star_border,
              color: C.gold,
            ),
          );
        }),
      ),
    );
  }

  int _activeIndex(String status) {
    if (status == ComplaintStatus.closed) {
      return ComplaintStatus.trackingSteps.length - 1;
    }
    if (status == ComplaintStatus.rejected) return 1;
    final index = ComplaintStatus.trackingSteps.indexOf(status);
    return index < 0 ? 0 : index;
  }

  String _stepText(String step) {
    switch (step) {
      case ComplaintStatus.received:
        return 'Complaint has been registered in the system.';
      case ComplaintStatus.assigned:
        return 'Complaint has been assigned to a responsible officer or committee.';
      case ComplaintStatus.underReview:
        return 'Concerned authority is reviewing the complaint and gathering details.';
      case ComplaintStatus.actionTaken:
        return 'Corrective action has been initiated or completed.';
      default:
        return 'Complaint is marked as resolved by the admin team.';
    }
  }

  void _search() {
    FocusScope.of(context).unfocus();
    setState(() {
      _searchedId = _ctrl.text.trim().toUpperCase();
      _rating = 0;
    });
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailLine({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: C.muted, size: 18),
          const SizedBox(width: 9),
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(
                color: C.muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
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
