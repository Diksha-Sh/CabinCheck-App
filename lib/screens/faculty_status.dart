import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/faculty_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';

class FacultyStatus extends StatefulWidget {
  const FacultyStatus({super.key});

  @override
  State<FacultyStatus> createState() => _FacultyStatusState();
}

class _FacultyStatusState extends State<FacultyStatus> {
  late TextEditingController _noteController;
  late String _selectedStatus;
  DateTime? _selectedReturnTime;

  @override
  void initState() {
    super.initState();
    final faculty = Provider.of<FacultyProvider>(context, listen: false).faculty;
    _noteController = TextEditingController(text: faculty.note);
    _selectedStatus = faculty.status;
    _selectedReturnTime = faculty.estimatedReturn;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedReturnTime ?? DateTime.now()),
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      setState(() {
        _selectedReturnTime = DateTime(
          now.year,
          now.month,
          now.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  void _saveStatus() {
    Provider.of<FacultyProvider>(context, listen: false).updateFacultyDetails(
      status: _selectedStatus,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      estimatedReturn: _selectedReturnTime,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Status updated successfully!"),
        backgroundColor: AppColors.statusAvailable,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.facultyView)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Update Your Status",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Share your availability with students in real-time.",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            const Text(
              "Availability",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _StatusChip(
                  label: AppStrings.statusAvailable,
                  color: AppColors.statusAvailable,
                  isSelected: _selectedStatus == AppStrings.statusAvailable,
                  onSelected: (val) => setState(() => _selectedStatus = AppStrings.statusAvailable),
                ),
                _StatusChip(
                  label: AppStrings.statusBusy,
                  color: AppColors.statusBusy,
                  isSelected: _selectedStatus == AppStrings.statusBusy,
                  onSelected: (val) => setState(() => _selectedStatus = AppStrings.statusBusy),
                ),
                _StatusChip(
                  label: AppStrings.statusUnavailable,
                  color: AppColors.statusUnavailable,
                  isSelected: _selectedStatus == AppStrings.statusUnavailable,
                  onSelected: (val) => setState(() => _selectedStatus = AppStrings.statusUnavailable),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              "Short Note (Optional)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: "e.g., In a lab session, Back in 10 mins",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 32),
            const Text(
              "Estimated Return (Optional)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      _selectedReturnTime == null
                          ? "Not Set"
                          : DateFormat('hh:mm a').format(_selectedReturnTime!),
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedReturnTime == null ? Colors.grey : Colors.black,
                      ),
                    ),
                    const Spacer(),
                    if (_selectedReturnTime != null)
                      IconButton(
                        onPressed: () => setState(() => _selectedReturnTime = null),
                        icon: const Icon(Icons.close, size: 20),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Text(
                  AppStrings.saveStatus,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final Function(bool) onSelected;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? color : Colors.grey.shade300),
      ),
    );
  }
}
