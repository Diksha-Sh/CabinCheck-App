class Faculty {
  final String id;
  final String name;
  final String department;
  final String cabin;
  String status;
  DateTime lastUpdated;
  String? note;
  DateTime? estimatedReturn;

  Faculty({
    required this.id,
    required this.name,
    required this.department,
    required this.cabin,
    required this.status,
    required this.lastUpdated,
    this.note,
    this.estimatedReturn,
  });
}
