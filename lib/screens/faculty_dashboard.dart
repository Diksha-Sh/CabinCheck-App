import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/app_state.provider.dart';
import '../models/faculty_status.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_widgets.dart';

class FacultyDashboard extends StatefulWidget {
  const FacultyDashboard({super.key});

  @override
  _FacultyDashboardState createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController deptController = TextEditingController();
  final TextEditingController cabinController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController morningController = TextEditingController();
  final TextEditingController eveningController = TextEditingController();
  final TextEditingController vibeController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController lngController = TextEditingController();
  String selectedEmoji = "☕";

  @override
  void initState() {
    super.initState();
    final state = Provider.of<AppState>(context, listen: false);
    nameController.text = state.facultyName;
    deptController.text = state.department;
    cabinController.text = state.cabinInfo;
    messageController.text = state.facultyMessage ?? "";
    morningController.text = state.officeHours["Morning"] ?? "";
    eveningController.text = state.officeHours["Evening"] ?? "";
    vibeController.text = state.facultyVibe;
    latController.text = state.cabinLat.toString();
    lngController.text = state.cabinLng.toString();
    selectedEmoji = state.statusEmoji;
  }

  Future<void> _pickImage(AppState state) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      state.updateProfile(image: image);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Faculty Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.buzzCount > 0) _buildBuzzAlert(state),
            if (state.buzzCount > 0) const SizedBox(height: 16),
            _buildStatusHeader(state),
            const SizedBox(height: 24),
            _buildMeetingTimerSection(state),
            const SizedBox(height: 24),
            if (state.studentQueue.isNotEmpty) _buildQueueSection(state),
            if (state.studentQueue.isNotEmpty) const SizedBox(height: 24),
            _buildActivitySection(state),
            const SizedBox(height: 24),
            _buildProfileSection(state),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBuzzAlert(AppState state) {
    return NeonButton(
      label: "You have ${state.buzzCount} New Buzzes!",
      glowColor: Colors.amber,
      icon: Icons.notifications_active,
      onPressed: () {
        state.clearBuzzes();
        showModalBottomSheet(
          context: context,
          builder: (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Recent Buzz History", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...state.buzzHistory.map((b) => ListTile(
                  leading: const Icon(Icons.history, color: Colors.amber),
                  title: Text(b),
                )).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMeetingTimerSection(AppState state) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Meeting Management", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (state.meetingEndTime != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    state.remainingMeetingTime,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.meetingEndTime == null)
            Row(
              children: [
                _TimerOption(label: "15m", onSelected: () => state.startMeeting(15)),
                const SizedBox(width: 8),
                _TimerOption(label: "30m", onSelected: () => state.startMeeting(30)),
                const SizedBox(width: 8),
                _TimerOption(label: "60m", onSelected: () => state.startMeeting(60)),
              ],
            )
          else
            GradientButton(
              label: "End Meeting Now",
              onPressed: () => state.endMeeting(),
              icon: Icons.stop_circle_outlined,
            ),
        ],
      ),
    );
  }

  Widget _buildQueueSection(AppState state) {
    return ModernCard(
      color: Colors.indigo.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Student Queue (${state.studentQueue.length})", 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
              TextButton(onPressed: () => state.clearQueue(), child: const Text("Clear All")),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.studentQueue.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(backgroundColor: Colors.indigo, child: Icon(Icons.person, color: Colors.white)),
                title: Text(state.studentQueue[index], style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: IconButton(
                  icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                  onPressed: () => state.removeFirstFromQueue(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(AppState state) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Quick Status Update", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              StatusBadge(
                label: state.currentStatus.label,
                gradient: _getGradientForStatus(state.currentStatus.availability),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatusButton(
                icon: Icons.check_circle_outline,
                label: "In Cabin",
                color: Colors.green,
                onPressed: () => state.updateStatus(FacultyAvailability.inCabin, "🟢 In Cabin"),
              ),
              _StatusButton(
                icon: Icons.groups_outlined,
                label: "Meeting",
                color: Colors.amber,
                onPressed: () => state.updateStatus(FacultyAvailability.busyMeeting, "🟡 Busy/Meeting"),
              ),
              _StatusButton(
                icon: Icons.event_busy_outlined,
                label: "Away",
                color: Colors.red,
                onPressed: () => state.updateStatus(FacultyAvailability.notAvailable, "🔴 Not Available"),
              ),
              _StatusButton(
                icon: Icons.warning_amber_rounded,
                label: "Emergency",
                color: Colors.deepOrange,
                onPressed: () => state.setEmergency(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection(AppState state) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recent Activity (15 Days)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 15,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final date = DateTime.now().subtract(Duration(days: 14 - index));
                final dayStatusCount = state.statusHistory.where((dt) => 
                  dt.day == date.day && dt.month == date.month && dt.year == date.year).length;
                
                return Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1 + (dayStatusCount * 0.2).clamp(0, 0.9)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text("${date.day}", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.auto_graph, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                "Typical Availability: ${state.predictedTime}",
                style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(AppState state) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Faculty Profile & Cabin", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Full Name",
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: deptController,
            decoration: const InputDecoration(
              labelText: "Department",
              prefixIcon: Icon(Icons.business_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: cabinController,
            decoration: const InputDecoration(
              labelText: "Cabin Location",
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: messageController,
            decoration: const InputDecoration(
              labelText: "Announcement Message",
              prefixIcon: Icon(Icons.campaign_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: vibeController,
            decoration: const InputDecoration(
              labelText: "Current Vibe",
              prefixIcon: Icon(Icons.auto_awesome_outlined),
              hintText: "e.g. 🚀 Ready to help!",
            ),
          ),
          const SizedBox(height: 16),
          const Text("Status Emoji", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ["☕", "📖", "💻", "🧘", "🤝"].map((emoji) => InkWell(
              onTap: () => setState(() => selectedEmoji = emoji),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selectedEmoji == emoji ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: selectedEmoji == emoji ? AppColors.primary : Colors.transparent),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: latController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Latitude",
                    prefixIcon: Icon(Icons.map_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: lngController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Longitude",
                    prefixIcon: Icon(Icons.map_outlined),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: morningController,
                  decoration: const InputDecoration(
                    labelText: "Morning Hours",
                    prefixIcon: Icon(Icons.wb_sunny_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: eveningController,
                  decoration: const InputDecoration(
                    labelText: "Evening Hours",
                    prefixIcon: Icon(Icons.nightlight_outlined),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(state),
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Upload Timetable"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GradientButton(
                  label: "Update",
                  onPressed: () {
                    state.updateProfile(
                      name: nameController.text,
                      dept: deptController.text,
                      cabin: cabinController.text,
                      message: messageController.text.isNotEmpty ? messageController.text : null,
                      hours: {
                        "Morning": morningController.text,
                        "Evening": eveningController.text,
                      },
                      vibe: vibeController.text,
                      emoji: selectedEmoji,
                      lat: double.tryParse(latController.text),
                      lng: double.tryParse(lngController.text),
                    );
                    debugPrint("Profile updated successfully");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profile updated successfully")),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentRequestAlert(AppState state) {
    return ModernCard(
      color: Colors.indigo.shade50,
      child: Row(
        children: [
          const Icon(Icons.mail_outline, color: AppColors.primary, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Student Request", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Received at ${state.lastStudentRequestTime}", style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => state.respondToStudent("10 minutes"),
            child: const Text("Respond"),
          ),
        ],
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

class _StatusButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _StatusButton({required this.icon, required this.label, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: (MediaQuery.of(context).size.width - 96) / 2,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _TimerOption extends StatelessWidget {
  final String label;
  final VoidCallback onSelected;

  const _TimerOption({required this.label, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
        ),
      ),
    );
  }
}
