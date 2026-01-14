import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.provider.dart';
import '../models/faculty_status.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/room_locator.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    
    // Check for simulated notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.notificationMessage != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("🔔 CabinCheck Notification"),
            content: Text(state.notificationMessage!),
            actions: [
              TextButton(
                onPressed: () {
                  state.clearNotification();
                  Navigator.pop(context);
                },
                child: const Text("Got it!"),
              ),
            ],
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Student Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: const [
          ThemeSelector(),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.currentStatus.availability == FacultyAvailability.emergency) ...[
              const SOSAlert(message: "Faculty is attending an emergency. Communications are suspended."),
              const SizedBox(height: 24),
            ],
            _buildFacultyProfile(state),
            const SizedBox(height: 24),
            _buildLiveLocationCard(state),
            const SizedBox(height: 24),
            _buildQuickContactBar(state),
            const SizedBox(height: 24),
            _buildQueuePosition(state),
            if (state.studentQueue.contains("You")) const SizedBox(height: 24),
            _buildStatusHeader(context, state),
            const SizedBox(height: 24),
            _buildDynamicTimetable(state),
            const SizedBox(height: 24),
            _buildOfficeHoursCard(state),
            const SizedBox(height: 24),
            _buildFacultyFinderSection(),
            const SizedBox(height: 24),
            _buildAvailabilityPrediction(state),
            const SizedBox(height: 24),
            _buildRoomLocatorSection(state),
            const SizedBox(height: 24),
            _buildMessageHistory(state),
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
          if (state.facultyMessage != null && state.facultyMessage!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.push_pin_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.facultyMessage!,
                      style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                  glowColor: state.currentStatus.availability == FacultyAvailability.emergency ? Colors.grey : Colors.amber,
                  icon: Icons.doorbell_outlined,
                  onPressed: state.currentStatus.availability == FacultyAvailability.emergency 
                      ? null 
                      : () => _showMoodBuzzSheet(context, state),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: state.currentStatus.availability == FacultyAvailability.emergency 
                      ? null 
                      : () => _showMessageDialog(context, state),
                  icon: const Icon(Icons.message_outlined),
                  label: const Text("Message"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
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

  Widget _buildLiveLocationCard(AppState state) {
    // Determine current activity based on time
    final now = DateTime.now();
    final days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
    final currentDay = days[now.weekday - 1];
    
    Map<String, String>? currentSlot;
    if (state.weeklySchedule.containsKey(currentDay)) {
      for (var slot in state.weeklySchedule[currentDay]!) {
        final timeParts = slot["time"]!.split("–");
        if (timeParts.length == 2) {
          // Simple time check (ignoring AM/PM for deep logic, just showing the concept)
          // In a real app, we'd parse the time.
          currentSlot = slot; // For demo purposes, we'll just take the first one or show 'Cabin'
        }
      }
    }

    final isAvailable = state.currentStatus.availability == FacultyAvailability.inCabin;
    final statusText = state.currentStatus.label.split(' ').last; // Get "Meeting", "Away", etc.

    return GlassCard(
      color: isAvailable ? AppColors.primary : Colors.orange,
      opacity: 0.1,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isAvailable ? AppColors.primary : Colors.orange).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAvailable ? Icons.my_location : Icons.info_outline_rounded, 
              color: isAvailable ? AppColors.primary : Colors.orange, 
              size: 32
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Faculty Status & Location", style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  !isAvailable 
                    ? "Currently $statusText" 
                    : (currentSlot != null ? "${currentSlot["task"]} @ ${currentSlot["location"]}" : "Currently in ${state.cabinInfo.split('–').last}"),
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: isAvailable ? AppColors.primary : Colors.orange.shade700
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                PulseIndicator(color: Colors.green),
                SizedBox(width: 6),
                Text("LIVE", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickContactBar(AppState state) {
    return Row(
      children: [
        Expanded(
          child: _ContactAction(
            icon: Icons.phone_in_talk_rounded,
            label: "Call",
            color: Colors.blue,
            onPressed: () => _launchURL("tel:${state.facultyPhone}"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ContactAction(
            icon: Icons.alternate_email_rounded,
            label: "Email",
            color: Colors.red,
            onPressed: () => _launchURL("mailto:${state.facultyEmail}"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ContactAction(
            icon: Icons.language_rounded,
            label: "Profile",
            color: Colors.deepPurple,
            onPressed: () => _launchURL(state.facultyOfficeLink),
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicTimetable(AppState state) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 20),
              SizedBox(width: 12),
              Text("Weekly Schedule", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          if (state.timetableImage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(state.timetableImage!.path),
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text("Detailed Schedule", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
          ],
          ...state.weeklySchedule.entries.map((dayEntry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dayEntry.key, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 8),
                  ...dayEntry.value.map((slot) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, left: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(slot["time"]!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                        Expanded(
                          child: Text(slot["task"]!, style: const TextStyle(fontSize: 12)),
                        ),
                        Text(slot["location"]!, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }



  Widget _buildAvailabilityPrediction(AppState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Deep slate for "AI Engine" look
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.teal.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.psychology, color: Colors.tealAccent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text("CABIN-AI PREDICTION", 
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                ],
              ),
              const Icon(Icons.more_vert, color: Colors.white24, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          const Text("Recommended Visit Window", style: TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 4),
          Text(state.predictedTime, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
          const SizedBox(height: 20),
          const ConfidenceMeter(value: 0.94, color: Colors.tealAccent),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Icon(Icons.insights_rounded, color: Colors.tealAccent.withOpacity(0.5), size: 16),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "High probability: Historical data shows faculty usually arrives 10 mins early on Wednesdays.",
                    style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageHistory(AppState state) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Communication History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (state.studentMessages.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text("No messages sent yet", style: TextStyle(color: AppColors.textSecondary))),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.studentMessages.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final msg = state.studentMessages[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("You", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        Text(msg["time"], style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(msg["content"], style: const TextStyle(fontSize: 14)),
                    if (msg["reply"] != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.reply, size: 14, color: Colors.green),
                                const SizedBox(width: 8),
                                Text("Reply from ${state.facultyName}", 
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(msg["reply"], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      const Text("Waiting for reply...", style: TextStyle(fontSize: 12, color: Colors.amber, fontStyle: FontStyle.italic)),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  void _showMessageDialog(BuildContext context, AppState state) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Message Faculty"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "What do you want to convey?",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                state.sendStudentMessage("You", controller.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Message sent! 📩")),
                );
              }
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  Widget _buildFacultyFinderSection() {
    return ModernCard(
      color: Colors.deepPurple.shade50.withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.travel_explore, color: Colors.deepPurple),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Find Your Faculty", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                    Text("View all college faculties and details", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GradientButton(
            label: "Explore VIT Faculties",
            icon: Icons.launch_rounded,
            onPressed: () async {
              final url = Uri.parse('https://vit.ac.in/faculty');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
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

  Widget _buildRoomLocatorSection(AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Cabin Location Map", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: () => state.toggleFollow(),
              icon: Icon(state.isFollowing ? Icons.notifications_off_outlined : Icons.notifications_active_outlined, size: 18),
              label: Text(state.isFollowing ? "Unfollow" : "Notify Me"),
              style: TextButton.styleFrom(
                foregroundColor: state.isFollowing ? Colors.red : AppColors.primary,
                backgroundColor: (state.isFollowing ? Colors.red : AppColors.primary).withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        RoomLocator(roomInfo: state.cabinInfo),
      ],
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

class _ContactAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ContactAction({required this.icon, required this.label, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
