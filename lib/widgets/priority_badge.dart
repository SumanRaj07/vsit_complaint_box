import 'package:flutter/material.dart';

import '../models/complaint.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class PriorityBadge extends StatelessWidget {
  final String priority;
  const PriorityBadge(this.priority, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = priorityColor(priority);
    final text = priority == 'high'
        ? 'High Priority'
        : priority == 'low'
        ? 'Low Priority'
        : 'Medium Priority';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class SlaBadge extends StatelessWidget {
  final Complaint complaint;
  const SlaBadge(this.complaint, {super.key});

  @override
  Widget build(BuildContext context) {
    final overdue = complaint.isOverdue;
    final color = overdue ? C.danger : C.success;
    final label = overdue ? 'SLA overdue' : 'SLA ${complaint.slaDays} days';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

Color priorityColor(String priority) {
  switch (priority) {
    case 'high':
      return C.danger;
    case 'low':
      return C.success;
    default:
      return C.warning;
  }
}

Color statusColor(String status) {
  switch (status) {
    case ComplaintStatus.received:
      return C.info;
    case ComplaintStatus.assigned:
      return C.royal;
    case ComplaintStatus.underReview:
      return C.warning;
    case ComplaintStatus.actionTaken:
      return C.blue;
    case ComplaintStatus.resolved:
    case ComplaintStatus.closed:
      return C.success;
    case ComplaintStatus.rejected:
      return C.danger;
    default:
      return C.muted;
  }
}
