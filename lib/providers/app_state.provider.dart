import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/faculty_status.dart';

class AppState extends ChangeNotifier {
  FacultyStatusDetails _currentStatus = FacultyStatusDetails.defaultStatus();
  FacultyStatusDetails get currentStatus => _currentStatus;

  String facultyName = "Dr. Shweta Varma";
  String department = "Computer Science & Engineering";
  String cabinInfo = "Block B – 2nd Floor – Cabin 214";
  String? facultyMessage;
  XFile? timetableImage;
  
  String? lastStudentRequestTime;
  List<String> studentQueue = [];
  int buzzCount = 0;
  List<String> buzzHistory = [];
  
  DateTime? meetingEndTime;
  Timer? _meetingSyncTimer;

  double cabinLat = 12.9716; // Default Bangalore (example)
  double cabinLng = 77.5946;
  String facultyVibe = "🚀 Ready to help!";
  String statusEmoji = "☕";

  Map<String, String> officeHours = {
    "Morning": "09:30 AM – 10:30 AM",
    "Evening": "03:30 PM – 04:30 PM",
  };
  
  Map<String, String> timetable = {
    "Monday": "10:00 – 11:00",
    "Tuesday": "11:00 – 12:00",
    "Wednesday": "09:00 – 10:00",
    "Thursday": "14:00 – 15:00",
    "Friday": "10:00 – 11:00"
  };

  List<DateTime> statusHistory = [];
  Timer? _autoResetTimer;

  AppState();

  void updateStatus(FacultyAvailability availability, String label, {String? message, String? returnTime}) {
    _currentStatus = FacultyStatusDetails(
      availability: availability,
      label: label,
      message: message,
      returnTime: returnTime,
      lastUpdated: DateTime.now(),
    );
    
    if (availability != FacultyAvailability.emergency) {
      statusHistory.insert(0, DateTime.now());
      _limitHistory();
    }
    
    _cancelTimer();
    notifyListeners();
  }

  void setEmergency() {
    updateStatus(FacultyAvailability.emergency, "🚫 Unavailable (Emergency)");
  }

  void studentRequest() {
    lastStudentRequestTime = _formatTime(DateTime.now());
    notifyListeners();
  }

  void respondToStudent(String time) {
    updateStatus(
      FacultyAvailability.notAvailable, 
      "🔴 Not Available", 
      returnTime: time,
      message: "I'll be back by $time"
    );
  }

  void sendBuzz(String studentName, {String mood = "👋"}) {
    buzzCount++;
    buzzHistory.insert(0, "${_formatTime(DateTime.now())} - $studentName [$mood]");
    if (buzzHistory.length > 5) buzzHistory.removeLast();
    notifyListeners();
  }

  void clearBuzzes() {
    buzzCount = 0;
    notifyListeners();
  }

  void addToQueue(String studentName) {
    if (!studentQueue.contains(studentName)) {
      studentQueue.add(studentName);
      lastStudentRequestTime = _formatTime(DateTime.now());
      notifyListeners();
    }
  }

  void clearQueue() {
    studentQueue.clear();
    notifyListeners();
  }

  void removeFirstFromQueue() {
    if (studentQueue.isNotEmpty) {
      studentQueue.removeAt(0);
      notifyListeners();
    }
  }

  void startMeeting(int minutes) {
    meetingEndTime = DateTime.now().add(Duration(minutes: minutes));
    updateStatus(FacultyAvailability.busyMeeting, "🟡 In a Meeting", returnTime: _formatTime(meetingEndTime!));
    
    _meetingSyncTimer?.cancel();
    _meetingSyncTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (meetingEndTime != null && DateTime.now().isAfter(meetingEndTime!)) {
        endMeeting();
      } else {
        notifyListeners(); // Refresh countdowns
      }
    });
  }

  void endMeeting() {
    meetingEndTime = null;
    _meetingSyncTimer?.cancel();
    updateStatus(FacultyAvailability.inCabin, "🟢 Available");
    notifyListeners();
  }

  String get remainingMeetingTime {
    if (meetingEndTime == null) return "00:00";
    final diff = meetingEndTime!.difference(DateTime.now());
    if (diff.isNegative) return "00:00";
    return "${diff.inMinutes}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  void updateProfile({String? name, String? dept, String? cabin, String? message, XFile? image, Map<String, String>? hours, String? vibe, String? emoji, double? lat, double? lng}) {
    if (name != null) facultyName = name;
    if (dept != null) department = dept;
    if (cabin != null) cabinInfo = cabin;
    if (message != null) facultyMessage = message;
    if (image != null) timetableImage = image;
    if (hours != null) officeHours = hours;
    if (vibe != null) facultyVibe = vibe;
    if (emoji != null) statusEmoji = emoji;
    if (lat != null) cabinLat = lat;
    if (lng != null) cabinLng = lng;
    notifyListeners();
  }

  void _limitHistory() {
    final cutoff = DateTime.now().subtract(const Duration(days: 15));
    statusHistory = statusHistory.where((dt) => dt.isAfter(cutoff)).toList();
    if (statusHistory.length > 50) statusHistory = statusHistory.sublist(0, 50);
  }

  void _cancelTimer() {
    _autoResetTimer?.cancel();
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  String get predictedTime {
    if (statusHistory.isEmpty) return "3:00 – 4:00 PM (Typical)";
    
    Map<int, int> hourCount = {};
    for (var dt in statusHistory) {
      hourCount[dt.hour] = (hourCount[dt.hour] ?? 0) + 1;
    }

    int mostCommonHour = hourCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    return "$mostCommonHour:00 – ${mostCommonHour + 1}:00 (Based on history)";
  }
  
  void saveLoginInfo({required String role, required String email, required String phone, required String id}) {
    debugPrint("Logged in as $role: $email");
  }

  @override
  void dispose() {
    _autoResetTimer?.cancel();
    super.dispose();
  }
}
