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
  String facultyPhone = "+91 98765 43210";
  String facultyEmail = "shweta.varma@university.edu";
  String facultyOfficeLink = "https://university.edu/faculty/shweta";
  String? facultyMessage;
  XFile? timetableImage;
  
  String? lastStudentRequestTime;
  List<String> studentQueue = [];
  List<Map<String, dynamic>> studentMessages = [];
  int buzzCount = 0;
  List<String> buzzHistory = [];
  bool isFollowing = false;
  String? notificationMessage;
  
  DateTime? meetingEndTime;
  Timer? _meetingSyncTimer;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  String facultyVibe = "🚀 Ready to help!";
  String statusEmoji = "☕";

  Map<String, String> officeHours = {
    "Morning": "09:30 AM – 10:30 AM",
    "Evening": "03:30 PM – 04:30 PM",
  };
  
  Map<String, List<Map<String, String>>> weeklySchedule = {
    "Monday": [
      {"time": "09:00 – 10:00", "task": "L1 Class", "location": "Gallery 1"},
      {"time": "10:00 – 11:00", "task": "Office Hours", "location": "Cabin"},
      {"time": "14:00 – 15:00", "task": "L2 Class", "location": "Gallery 4"},
    ],
    "Tuesday": [
      {"time": "11:00 – 12:00", "task": "Meeting", "location": "Dept Office"},
      {"time": "14:00 – 15:00", "task": "L3 Class", "location": "Gallery 1"},
    ],
    "Wednesday": [
      {"time": "09:00 – 10:00", "task": "Office Hours", "location": "Cabin"},
      {"time": "10:00 – 12:00", "task": "Lab Session", "location": "Computing Lab 2"},
    ],
    "Thursday": [
      {"time": "14:00 – 15:00", "task": "L1 Class", "location": "Gallery 1"},
      {"time": "15:00 – 16:00", "task": "Office Hours", "location": "Cabin"},
    ],
    "Friday": [
      {"time": "10:00 – 11:00", "task": "Seminars", "location": "Auditorium"},
      {"time": "11:00 – 12:00", "task": "Office Hours", "location": "Cabin"},
    ]
  };

  List<DateTime> statusHistory = [];
  Timer? _autoResetTimer;

  AppState();

  void updateStatus(FacultyAvailability availability, String label, {String? message, String? returnTime}) {
    final wasBusy = _currentStatus.availability != FacultyAvailability.inCabin;
    
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

    // Smart Notification Logic
    if (isFollowing && wasBusy && availability == FacultyAvailability.inCabin) {
      notificationMessage = "Faculty $facultyName is now available in Cabin!";
      // In a real app, this would be a local push notification.
    }
    
    _cancelTimer();
    notifyListeners();
  }

  void toggleFollow() {
    isFollowing = !isFollowing;
    notifyListeners();
  }

  void clearNotification() {
    notificationMessage = null;
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

  void sendStudentMessage(String studentName, String content) {
    studentMessages.insert(0, {
      "sender": studentName,
      "content": content,
      "time": _formatTime(DateTime.now()),
      "reply": null,
      "replyTime": null,
    });
    notifyListeners();
  }

  void replyToStudentMessage(int index, String reply) {
    if (index >= 0 && index < studentMessages.length) {
      studentMessages[index]["reply"] = reply;
      studentMessages[index]["replyTime"] = _formatTime(DateTime.now());
      notifyListeners();
    }
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
    final minutes = diff.inMinutes;
    final seconds = diff.inSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  void updateProfile({String? name, String? dept, String? cabin, String? message, XFile? image, Map<String, String>? hours, String? vibe, String? emoji, String? phone, String? email, String? link}) {
    if (name != null) facultyName = name;
    if (dept != null) department = dept;
    if (cabin != null) cabinInfo = cabin;
    if (message != null) facultyMessage = message;
    if (image != null) timetableImage = image;
    if (hours != null) officeHours = hours;
    if (vibe != null) facultyVibe = vibe;
    if (emoji != null) statusEmoji = emoji;
    if (phone != null) facultyPhone = phone;
    if (email != null) facultyEmail = email;
    if (link != null) facultyOfficeLink = link;
    notifyListeners();
  }

  void updateSchedule(String day, int index, String task, String location) {
    if (weeklySchedule.containsKey(day) && index < weeklySchedule[day]!.length) {
      weeklySchedule[day]![index]["task"] = task;
      weeklySchedule[day]![index]["location"] = location;
      notifyListeners();
    }
  }

  void addScheduleSlot(String day, String time, String task, String location) {
    weeklySchedule[day] ??= [];
    weeklySchedule[day]!.add({"time": time, "task": task, "location": location});
    notifyListeners();
  }

  void removeScheduleSlot(String day, int index) {
    if (weeklySchedule.containsKey(day) && index < weeklySchedule[day]!.length) {
      weeklySchedule[day]!.removeAt(index);
      notifyListeners();
    }
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
    _meetingSyncTimer?.cancel();
    super.dispose();
  }
}
