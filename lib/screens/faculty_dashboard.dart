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
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  String selectedEmoji = "☕";
  
  @override
  void dispose() {
    nameController.dispose();
    deptController.dispose();
    cabinController.dispose();
    messageController.dispose();
    morningController.dispose();
    eveningController.dispose();
    vibeController.dispose();
    phoneController.dispose();
    emailController.dispose();
    linkController.dispose();
    super.dispose();
  }

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
    phoneController.text = state.facultyPhone;
    emailController.text = state.facultyEmail;
    linkController.text = state.facultyOfficeLink;
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
              const SOSAlert(message: "EMERGENCY PROTOCOL ACTIVE. Student communication restricted."),
              const SizedBox(height: 24),
            ],
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
            _buildPeakInsights(state),
            const SizedBox(height: 24),
            _buildMessagesSection(state),
            const SizedBox(height: 24),
            _buildDynamicScheduleEditor(state),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Presence Analytics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user_rounded, color: Colors.blue, size: 12),
                    SizedBox(width: 4),
                    Text("Reliability: 98%", style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text("LAST 24 HOURS STATUS CHANGES", 
            style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          const SizedBox(height: 20),
          TimelineItem(
            time: "10:30 AM",
            status: "Entered Cabin",
            color: Colors.green,
          ),
          TimelineItem(
            time: "12:45 PM",
            status: "Meeting with Dean",
            color: Colors.amber,
          ),
          TimelineItem(
            time: "02:15 PM",
            status: "Back in Cabin",
            color: Colors.green,
          ),
          TimelineItem(
            time: "04:00 PM",
            status: "Left for Lab",
            color: Colors.red,
            isLast: true,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_graph_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Availability Insight", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text("You are most active between 09:00 AM - 12:00 PM.", 
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeakInsights(AppState state) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Peak Activity Detection", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text("STUDENT BUZZ HEATMAP", 
            style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(8, (index) {
              const hours = ["09", "10", "11", "12", "01", "02", "03", "04"];
              const intensity = [0.2, 0.4, 0.9, 0.6, 0.1, 0.3, 0.7, 0.5];
              return Column(
                children: [
                  Container(
                    width: 30,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(intensity[index]),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: intensity[index] > 0.8 
                        ? const Center(child: Icon(Icons.flash_on, color: Colors.white, size: 12)) 
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(hours[index], style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ],
              );
            }),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withOpacity(0.1)),
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: Colors.amber, size: 18),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Insight: You get 40% more buzzes between 11:00 AM - 12:00 PM. Consider keeping office hours then.",
                    style: TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
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
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email ID",
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: linkController,
            decoration: const InputDecoration(
              labelText: "Office/Profile Link",
              prefixIcon: Icon(Icons.link_outlined),
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
                      phone: phoneController.text,
                      email: emailController.text,
                      link: linkController.text,
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

  Widget _buildDynamicScheduleEditor(AppState state) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Weekly Schedule & Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                onPressed: () => _showAddSlotDialog(state),
                icon: const Icon(Icons.add_circle, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DefaultTabController(
            length: 5,
            child: Column(
              children: [
                const TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: "Mon"),
                    Tab(text: "Tue"),
                    Tab(text: "Wed"),
                    Tab(text: "Thu"),
                    Tab(text: "Fri"),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: TabBarView(
                    children: [
                      _buildDayList(state, "Monday"),
                      _buildDayList(state, "Tuesday"),
                      _buildDayList(state, "Wednesday"),
                      _buildDayList(state, "Thursday"),
                      _buildDayList(state, "Friday"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayList(AppState state, String day) {
    final slots = state.weeklySchedule[day] ?? [];
    if (slots.isEmpty) {
      return const Center(child: Text("No slots added for this day", style: TextStyle(color: AppColors.textSecondary)));
    }
    return ListView.separated(
      itemCount: slots.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final slot = slots[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(slot["time"]!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(slot["task"]!, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(slot["location"]!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
                onPressed: () => _showEditSlotDialog(state, day, index, slot),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                onPressed: () => state.removeScheduleSlot(day, index),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddSlotDialog(AppState state) {
    final timeC = TextEditingController();
    final taskC = TextEditingController();
    final locC = TextEditingController();
    String selectedDay = "Monday";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Add Schedule Slot"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: selectedDay,
                  isExpanded: true,
                  items: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedDay = v!),
                ),
                TextField(controller: timeC, decoration: const InputDecoration(labelText: "Time (e.g. 09:00 - 10:00)")),
                TextField(controller: taskC, decoration: const InputDecoration(labelText: "Task (e.g. Class L1)")),
                TextField(controller: locC, decoration: const InputDecoration(labelText: "Location (e.g. Gallery 1)")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                state.addScheduleSlot(selectedDay, timeC.text, taskC.text, locC.text);
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSlotDialog(AppState state, String day, int index, Map<String, String> slot) {
    final taskC = TextEditingController(text: slot["task"]);
    final locC = TextEditingController(text: slot["location"]);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Slot"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Day: $day | Time: ${slot["time"]}", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: taskC, decoration: const InputDecoration(labelText: "Task")),
            TextField(controller: locC, decoration: const InputDecoration(labelText: "Location")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              state.updateSchedule(day, index, taskC.text, locC.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }



  Widget _buildMessagesSection(AppState state) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Student Messages", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (state.studentMessages.any((m) => m["reply"] == null))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                  child: const Text("New", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.studentMessages.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text("No messages yet", style: TextStyle(color: AppColors.textSecondary))),
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
                        Text(msg["sender"], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        Text(msg["time"], style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(msg["content"], style: const TextStyle(fontSize: 14)),
                    if (msg["reply"] != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Your Reply", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                            const SizedBox(height: 4),
                            Text(msg["reply"], style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.reply, size: 18),
                        label: const Text("Reply"),
                        onPressed: () => _showReplyDialog(context, state, index),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  void _showReplyDialog(BuildContext context, AppState state, int index) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reply to Student"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Type your reply...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                state.replyToStudentMessage(index, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Send Reply"),
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
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.03),
          border: Border.all(color: color.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color.withOpacity(0.8))),
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
