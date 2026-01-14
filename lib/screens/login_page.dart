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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Compact Hero Section
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      height: 140, // Reduced from 220
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            top: -20,
                            child: Icon(Icons.cabin_rounded, size: 120, color: Colors.white.withOpacity(0.1)),
                          ),
                          const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.door_front_door_rounded, size: 48, color: Colors.white),
                                SizedBox(height: 8),
                                Text(
                                  "CabinCheck",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Welcome Text
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        const Text(
                          "Welcome to CabinCheck",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32, 
                            fontWeight: FontWeight.w900, 
                            color: AppColors.textPrimary,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Your campus, simplified. Sign in to continue.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16, 
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Role Switcher & Form
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1200),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 40 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: ModernCard(
                      padding: const EdgeInsets.all(28),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _RoleChip(
                                      label: "Faculty",
                                      selected: role == "Faculty",
                                      onSelected: () => setState(() => role = "Faculty"),
                                    ),
                                  ),
                                  Expanded(
                                    child: _RoleChip(
                                      label: "Student",
                                      selected: role == "Student",
                                      onSelected: () => setState(() => role = "Student"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: "Email Address",
                                prefixIcon: Icon(Icons.email_outlined, size: 22),
                                hintText: "Enter your university email",
                              ),
                              validator: (v) => v != null && v.contains('@') ? null : "Invalid email",
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: "Phone Number",
                                prefixIcon: Icon(Icons.phone_outlined, size: 22),
                                hintText: "Enter your contact number",
                              ),
                              validator: (v) => v != null && v.length >= 10 ? null : "Invalid phone",
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: idController,
                              decoration: InputDecoration(
                                labelText: role == "Faculty" ? "Faculty ID" : "Student ID",
                                prefixIcon: const Icon(Icons.badge_outlined, size: 22),
                                hintText: role == "Faculty" ? "e.g. FAC-123" : "e.g. STU-456",
                              ),
                              validator: (v) => v != null && v.isNotEmpty ? null : "Required",
                            ),
                            const SizedBox(height: 32),
                            GradientButton(
                              label: "Get Started",
                              onPressed: _attemptLogin,
                              icon: Icons.arrow_forward_rounded,
                            ),
                            const SizedBox(height: 20),
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
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                "Fill with demo data",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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
