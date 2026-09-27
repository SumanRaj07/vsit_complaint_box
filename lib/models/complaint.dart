class Complaint {
  final String id;
  final String name;
  final String roll;
  final String email;
  final String phone;
  final String department;
  final String year;
  final String category;
  final String location;
  final String subject;
  final String description;
  final String priority;
  final bool anonymous;
  final List<String> attachments; // file paths attached by the student
  String status;
  String assignedTo;
  String adminNote;
  final String createdAt;
  String updatedAt;
  final int timestamp;

  Complaint({
    required this.id,
    required this.name,
    required this.roll,
    required this.email,
    required this.phone,
    required this.department,
    required this.year,
    required this.category,
    required this.location,
    required this.subject,
    required this.description,
    required this.priority,
    required this.anonymous,
    this.attachments = const [],
    this.status = 'Received',
    this.assignedTo = 'Student Affairs Office',
    this.adminNote = '',
    required this.createdAt,
    required this.updatedAt,
    required this.timestamp,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    final oldStatus = json['status'] ?? 'Received';

    return Complaint(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Anonymous',
      roll: json['roll'] ?? '-',
      email: json['email'] ?? '-',
      phone: json['phone'] ?? '',
      department: json['department'] ?? json['dept'] ?? '',
      year: json['year'] ?? '',
      category: json['category'] ?? 'Other',
      location: json['location'] ?? 'Not specified',
      subject: json['subject'] ?? '',
      description: json['description'] ?? json['desc'] ?? '',
      priority: json['priority'] ?? 'medium',
      anonymous: json['anonymous'] ?? false,
      attachments: (json['attachments'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      status: _normalizeStatus(oldStatus),
      assignedTo: json['assignedTo'] ?? 'Student Affairs Office',
      adminNote: json['adminNote'] ?? '',
      createdAt: json['createdAt'] ?? json['date'] ?? '',
      updatedAt: json['updatedAt'] ?? json['date'] ?? '',
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'roll': roll,
    'email': email,
    'phone': phone,
    'department': department,
    'year': year,
    'category': category,
    'location': location,
    'subject': subject,
    'description': description,
    'priority': priority,
    'anonymous': anonymous,
    'attachments': attachments,
    'status': status,
    'assignedTo': assignedTo,
    'adminNote': adminNote,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'timestamp': timestamp,
  };

  int get slaDays {
    switch (priority) {
      case 'high':
        return 2;
      case 'medium':
        return 5;
      default:
        return 7;
    }
  }

  int get ageDays {
    final created = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(created).inDays;
  }

  bool get isClosed =>
      status == 'Resolved' || status == 'Closed' || status == 'Rejected';

  bool get isOverdue => !isClosed && ageDays > slaDays;

  String get displayPriority {
    switch (priority) {
      case 'high':
        return 'High';
      case 'low':
        return 'Low';
      default:
        return 'Medium';
    }
  }

  static String _normalizeStatus(String status) {
    switch (status) {
      case 'Open':
        return 'Received';
      case 'In Review':
        return 'Under Review';
      default:
        return status;
    }
  }
}

class ComplaintStatus {
  static const received = 'Received';
  static const assigned = 'Assigned';
  static const underReview = 'Under Review';
  static const actionTaken = 'Action Taken';
  static const resolved = 'Resolved';
  static const closed = 'Closed';
  static const rejected = 'Rejected';

  static const all = [
    received,
    assigned,
    underReview,
    actionTaken,
    resolved,
    closed,
    rejected,
  ];

  static const trackingSteps = [
    received,
    assigned,
    underReview,
    actionTaken,
    resolved,
  ];
}
