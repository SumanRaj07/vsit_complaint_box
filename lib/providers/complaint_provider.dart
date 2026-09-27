import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/complaint.dart';

class ComplaintProvider extends ChangeNotifier {
  static const _storageKey = 'vsit_complaints';

  final List<Complaint> _list = [];
  bool _loaded = false;

  List<Complaint> get all => List.unmodifiable(_list);
  bool get loaded => _loaded;

  ComplaintProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];

    _list
      ..clear()
      ..addAll(
        raw.isEmpty
            ? _demoComplaints()
            : raw.map((item) => Complaint.fromJson(jsonDecode(item))),
      );

    _list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      _list.map((complaint) => jsonEncode(complaint.toJson())).toList(),
    );
  }

  Complaint? findById(String id) {
    final query = id.trim().toUpperCase();
    for (final complaint in _list) {
      if (complaint.id.toUpperCase() == query) return complaint;
    }
    return null;
  }

  List<Complaint> filtered({
    String status = 'All',
    String category = 'All',
    String priority = 'All',
    String query = '',
    bool overdueOnly = false,
  }) {
    final q = query.trim().toLowerCase();
    return _list.where((complaint) {
      final matchesStatus = status == 'All' || complaint.status == status;
      final matchesCategory =
          category == 'All' || complaint.category == category;
      final matchesPriority =
          priority == 'All' || complaint.priority == priority;
      final matchesOverdue = !overdueOnly || complaint.isOverdue;
      final matchesQuery =
          q.isEmpty ||
          complaint.id.toLowerCase().contains(q) ||
          complaint.subject.toLowerCase().contains(q) ||
          complaint.name.toLowerCase().contains(q) ||
          complaint.roll.toLowerCase().contains(q);

      return matchesStatus &&
          matchesCategory &&
          matchesPriority &&
          matchesOverdue &&
          matchesQuery;
    }).toList();
  }

  int countStatus(String status) =>
      _list.where((c) => c.status == status).length;

  int countPriority(String priority) =>
      _list.where((c) => c.priority == priority).length;

  int get overdueCount => _list.where((c) => c.isOverdue).length;

  int get openCount => _list.where((c) => !c.isClosed).length;

  void add(Complaint complaint) {
    _list.insert(0, complaint);
    _save();
    notifyListeners();
  }

  void updateComplaint(
    String id, {
    String? status,
    String? assignedTo,
    String? adminNote,
  }) {
    final index = _list.indexWhere((complaint) => complaint.id == id);
    if (index == -1) return;

    final complaint = _list[index];
    if (status != null) complaint.status = status;
    if (assignedTo != null) complaint.assignedTo = assignedTo;
    if (adminNote != null) complaint.adminNote = adminNote;
    complaint.updatedAt = _formatDate(DateTime.now());

    _save();
    notifyListeners();
  }

  void updateStatus(String id, String status) {
    updateComplaint(id, status: status);
  }

  void delete(String id) {
    _list.removeWhere((complaint) => complaint.id == id);
    _save();
    notifyListeners();
  }

  void resetDemoData() {
    _list
      ..clear()
      ..addAll(_demoComplaints());
    _save();
    notifyListeners();
  }

  String exportCsv() {
    final rows = [
      [
        'ID',
        'Date',
        'Student',
        'Roll',
        'Department',
        'Category',
        'Priority',
        'Status',
        'Assigned To',
        'Subject',
      ],
      ..._list.map(
        (c) => [
          c.id,
          c.createdAt,
          c.name,
          c.roll,
          c.department,
          c.category,
          c.displayPriority,
          c.status,
          c.assignedTo,
          c.subject,
        ],
      ),
    ];

    return rows.map((row) => row.map(_csvCell).join(',')).join('\n');
  }

  String generateId() {
    final now = DateTime.now();
    final year = now.year;
    final tail = now.millisecondsSinceEpoch.toString().substring(7);
    return 'VSIT-$year-$tail';
  }

  static String _csvCell(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  static String formatDate(DateTime date) => _formatDate(date);

  static String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final day = date.day.toString().padLeft(2, '0');
    return '$day ${months[date.month - 1]} ${date.year}';
  }

  List<Complaint> _demoComplaints() {
    final now = DateTime.now();
    return [
      Complaint(
        id: 'VSIT-2026-1001',
        name: 'Rahul Sharma',
        roll: '2024IT042',
        email: 'rahul.sharma@vsit.edu.in',
        phone: '9876543210',
        department: 'B.Sc Information Technology',
        year: 'Second Year',
        category: 'Labs and IT',
        location: 'Computer Lab 3',
        subject: 'Projector not working during practical sessions',
        description:
            'The projector in Computer Lab 3 has not been working properly for two weeks. Faculty members are unable to explain practical steps clearly during lab hours.',
        priority: 'high',
        anonymous: false,
        status: ComplaintStatus.underReview,
        assignedTo: 'IT Infrastructure Cell',
        adminNote: 'Technician visit scheduled. Replacement cable requested.',
        createdAt: _formatDate(now.subtract(const Duration(days: 3))),
        updatedAt: _formatDate(now.subtract(const Duration(days: 1))),
        timestamp: now.subtract(const Duration(days: 3)).millisecondsSinceEpoch,
      ),
      Complaint(
        id: 'VSIT-2026-1002',
        name: 'Anonymous',
        roll: '-',
        email: '-',
        phone: '',
        department: 'B.Sc Computer Science',
        year: 'Third Year',
        category: 'Academic',
        location: 'TY CS Classroom',
        subject: 'Timetable clash for elective lecture',
        description:
            'The elective lecture timing is clashing with a practical batch. Students are missing either the elective or practical attendance.',
        priority: 'medium',
        anonymous: true,
        status: ComplaintStatus.assigned,
        assignedTo: 'Academic Coordinator',
        adminNote: 'Forwarded to timetable committee.',
        createdAt: _formatDate(now.subtract(const Duration(days: 2))),
        updatedAt: _formatDate(now.subtract(const Duration(days: 1))),
        timestamp: now.subtract(const Duration(days: 2)).millisecondsSinceEpoch,
      ),
      Complaint(
        id: 'VSIT-2026-1003',
        name: 'Priya Nair',
        roll: '2023IT018',
        email: 'priya.nair@vsit.edu.in',
        phone: '9123456789',
        department: 'M.Sc IT',
        year: 'Post Graduate',
        category: 'Canteen',
        location: 'College Canteen',
        subject: 'Food quality concern in lunch counter',
        description:
            'Food quality has dropped in the last month. Several students have raised concerns about stale items being served during lunch.',
        priority: 'low',
        anonymous: false,
        status: ComplaintStatus.resolved,
        assignedTo: 'Canteen Committee',
        adminNote: 'Vendor has been warned and daily quality checks started.',
        createdAt: _formatDate(now.subtract(const Duration(days: 8))),
        updatedAt: _formatDate(now.subtract(const Duration(days: 4))),
        timestamp: now.subtract(const Duration(days: 8)).millisecondsSinceEpoch,
      ),
    ];
  }
}
