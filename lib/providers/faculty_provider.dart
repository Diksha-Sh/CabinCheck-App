import 'package:flutter/material.dart';
import '../models/faculty.dart';
import '../data/faculty_data.dart';

class FacultyProvider with ChangeNotifier {
  final Faculty _faculty = demoFaculty;

  Faculty get faculty => _faculty;

  void updateStatus(String newStatus) {
    _faculty.status = newStatus;
    _faculty.lastUpdated = DateTime.now();
    notifyListeners();
  }

  void updateFacultyDetails({
    required String status,
    String? note,
    DateTime? estimatedReturn,
  }) {
    _faculty.status = status;
    _faculty.note = note;
    _faculty.estimatedReturn = estimatedReturn;
    _faculty.lastUpdated = DateTime.now();
    notifyListeners();
  }
}
