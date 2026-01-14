enum FacultyAvailability {
  inCabin,
  busyMeeting,
  notAvailable,
  emergency,
  expectedShortly,
}

class FacultyStatusDetails {
  final FacultyAvailability availability;
  final String label;
  final String? message;
  final String? returnTime;
  final DateTime lastUpdated;

  FacultyStatusDetails({
    required this.availability,
    required this.label,
    this.message,
    this.returnTime,
    required this.lastUpdated,
  });

  factory FacultyStatusDetails.defaultStatus() {
    return FacultyStatusDetails(
      availability: FacultyAvailability.expectedShortly,
      label: "🟡 Expected in Cabin",
      lastUpdated: DateTime.now(),
    );
  }

  FacultyStatusDetails copyWith({
    FacultyAvailability? availability,
    String? label,
    String? message,
    String? returnTime,
    DateTime? lastUpdated,
  }) {
    return FacultyStatusDetails(
      availability: availability ?? this.availability,
      label: label ?? this.label,
      message: message ?? this.message,
      returnTime: returnTime ?? this.returnTime,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
