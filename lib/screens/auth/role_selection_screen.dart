import 'package:flutter/material.dart';
import '../../utils/styles.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/primary_button.dart';
import 'student_login_screen.dart';
import 'teacher_login_screen.dart';
import 'admin_login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: Styles.backgroundGradientFromImage),
        child: SafeArea(
          child: Center(
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              borderRadius: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App Logo/Icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: Styles.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App Title
                  const Text(
                    'DigiUni Portal',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Welcome Message
                  const Text(
                    'Welcome to Digital University Portal',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Role Selection Title
                  const Text(
                    'Choose Your Role',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Student Login Button
                  PrimaryButton(
                    label: "Login as Student",
                    width: 240,
                    height: 50,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StudentLoginScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Teacher Login Button
                  PrimaryButton(
                    label: "Login as Teacher",
                    width: 240,
                    height: 50,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TeacherLoginScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Admin Login Button
                  PrimaryButton(
                    label: "Login as Admin",
                    width: 240,
                    height: 50,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminLoginScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Footer Text
                  const Text(
                    '© 2024 DigiUni Portal. All rights reserved.',
                    style: TextStyle(fontSize: 12, color: Colors.white54),
                    textAlign: TextAlign.center,
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
