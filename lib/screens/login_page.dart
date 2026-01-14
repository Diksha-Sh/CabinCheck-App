import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.provider.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_widgets.dart';
import 'faculty_dashboard.dart';
import 'student_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String role = "Faculty";
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController idController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    idController.dispose();
    super.dispose();
  }

  void _attemptLogin() {
    if (!_formKey.currentState!.validate()) return;
    
    final state = Provider.of<AppState>(context, listen: false);
    state.saveLoginInfo(
      role: role,
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      id: idController.text.trim()
    );

    if (role == "Faculty") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const FacultyDashboard()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentDashboard()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary.withOpacity(0.05), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome Back",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Please sign in to your account",
                      style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    ModernCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _RoleChip(
                                    label: "Faculty",
                                    selected: role == "Faculty",
                                    onSelected: () => setState(() => role = "Faculty"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _RoleChip(
                                    label: "Student",
                                    selected: role == "Student",
                                    onSelected: () => setState(() => role = "Student"),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: "Email Address",
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (v) => v != null && v.contains('@') ? null : "Invalid email",
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: "Phone Number",
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                              validator: (v) => v != null && v.length >= 10 ? null : "Invalid phone",
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: idController,
                              decoration: InputDecoration(
                                labelText: role == "Faculty" ? "Faculty ID" : "Student ID",
                                prefixIcon: const Icon(Icons.badge_outlined),
                              ),
                              validator: (v) => v != null && v.isNotEmpty ? null : "Required",
                            ),
                            const SizedBox(height: 32),
                            GradientButton(
                              label: "Continue",
                              onPressed: _attemptLogin,
                              icon: Icons.arrow_forward_rounded,
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  if (role == "Faculty") {
                                    emailController.text = "prof@university.edu";
                                    phoneController.text = "9876543210";
                                    idController.text = "FAC-2241";
                                  } else {
                                    emailController.text = "student@university.edu";
                                    phoneController.text = "8877665544";
                                    idController.text = "STU-8890";
                                  }
                                });
                              },
                              child: const Text("Fill with demo data"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _RoleChip({required this.label, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : Colors.grey.shade200),
          boxShadow: selected ? [
            BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))
          ] : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
