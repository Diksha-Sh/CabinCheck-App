import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.provider.dart';
import '../models/faculty_status.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_widgets.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Student Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFacultyProfile(state),
            const SizedBox(height: 24),
            _buildQueuePosition(state),
            if (state.studentQueue.contains("You")) const SizedBox(height: 24),
            _buildStatusHeader(context, state),
            const SizedBox(height: 24),
            _buildOfficeHoursCard(state),
            const SizedBox(height: 24),
            _buildTimetableSection(state),
            const SizedBox(height: 24),
            _buildMapSection(state),
            const SizedBox(height: 24),
            _buildMiniMap(state),
            const SizedBox(height: 24),
            _buildAvailabilityPrediction(state),
          ],
        ),
      ),
    );
  }

  Widget _buildFacultyProfile(AppState state) {
    return ModernCard(
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white, size: 40),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                  children: [
                    Text(state.facultyName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text(state.statusEmoji, style: const TextStyle(fontSize: 20)),
                  ],
                ),
                Text(state.department, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(state.facultyVibe, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w600, fontSize: 13, fontStyle: FontStyle.italic)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(state.cabinInfo, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          if (state.meetingEndTime != null) ...[
            const Divider(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Colors.red),
                  const SizedBox(width: 12),
                  const Text("Busy for next: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(state.remainingMeetingTime, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context, AppState state) {
    final status = state.currentStatus;
    return GlassCard(
      color: Colors.white,
      opacity: 0.8,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Current Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              StatusBadge(
                label: status.label,
                gradient: _getGradientForStatus(status.availability),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  label: "Join Queue",
                  icon: Icons.notifications_active_outlined,
                  onPressed: () {
                    state.addToQueue("You");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Joined Queue! 👋")),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NeonButton(
                  label: "Buzz",
                  glowColor: Colors.amber,
                  icon: Icons.doorbell_outlined,
                  onPressed: () {
                    _showMoodBuzzSheet(context, state);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQueuePosition(AppState state) {
    if (!state.studentQueue.contains("You")) return const SizedBox.shrink();
    
    final pos = state.studentQueue.indexOf("You") + 1;
    return ModernCard(
      color: Colors.indigo.shade50,
      child: Row(
        children: [
          const Icon(Icons.people_outline, color: Colors.indigo),
          const SizedBox(width: 12),
          Text("You are at position #$pos in the queue", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
        ],
      ),
    );
  }

  Widget _buildOfficeHoursCard(AppState state) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.schedule, color: AppColors.primary),
              SizedBox(width: 12),
              Text("Consultation Hours", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ...state.officeHours.entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(e.value, style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildTimetableSection(AppState state) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Weekly Timetable", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (state.timetableImage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(state.timetableImage!.path),
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: Colors.grey.shade100,
                  child: const Center(child: Text("Click 'Preview' below to view timetable")),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          ...state.timetable.entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(e.value, style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildMiniMap(AppState state) {
    return ModernCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text("Cabin Mini-Map", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              image: const DecorationImage(
                image: NetworkImage("https://images.unsplash.com/photo-1577412647305-991150c7d163?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60"),
                fit: BoxFit.cover,
                opacity: 0.1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary, size: 40),
                      Text(state.cabinInfo.split("–").last.trim(), 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text("Block B Interior", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityPrediction(AppState state) {
    return ModernCard(
      color: Colors.teal.shade50,
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.teal, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("AI Predicted Availability", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(state.predictedTime, style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(AppState state) {
    return ModernCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text("Live Location Map", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
            ),
            child: Image.network(
              "https://maps.googleapis.com/maps/api/staticmap?center=${state.cabinLat},${state.cabinLng}&zoom=16&size=600x300&markers=color:red%7Clabel:C%7C${state.cabinLat},${state.cabinLng}&key=YOUR_API_KEY_HERE",
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_outlined, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text("Interactive Map (Mobile Only)", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Coordinates: ${state.cabinLat.toStringAsFixed(4)}, ${state.cabinLng.toStringAsFixed(4)}",
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {}, 
                  icon: const Icon(Icons.navigation_outlined, size: 18),
                  label: const Text("Nav"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMoodBuzzSheet(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Choose your Buzz Mood", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MoodItem(emoji: "👋", label: "Just checking", onSelect: () => _finishBuzz(context, state, "👋")),
                _MoodItem(emoji: "❓", label: "Question", onSelect: () => _finishBuzz(context, state, "❓")),
                _MoodItem(emoji: "🤝", label: "Meeting", onSelect: () => _finishBuzz(context, state, "🤝")),
                _MoodItem(emoji: "❤️", label: "Thanks!", onSelect: () => _finishBuzz(context, state, "❤️")),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _finishBuzz(BuildContext context, AppState state, String mood) {
    state.sendBuzz("Student", mood: mood);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Buzzed with $mood mood!"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  LinearGradient _getGradientForStatus(FacultyAvailability availability) {
    switch (availability) {
      case FacultyAvailability.inCabin: return AppColors.successGradient;
      case FacultyAvailability.busyMeeting: return AppColors.warningGradient;
      case FacultyAvailability.notAvailable: return AppColors.dangerGradient;
      case FacultyAvailability.emergency: return AppColors.dangerGradient;
      default: return AppColors.primaryGradient;
    }
  }
}

class _MoodItem extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onSelect;

  const _MoodItem({required this.emoji, required this.label, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
