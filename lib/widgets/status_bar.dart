import 'package:flutter/material.dart';
import '../utils/styles.dart';

class StatusBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool showNotificationBell;
  final bool showBattery;

  const StatusBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.actions,
    this.showBackButton = false,
    this.showNotificationBell = false,
    this.showBattery = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Title (center)
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Right side actions
          Row(
            children: [
              // Notification bell
              if (showNotificationBell)
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      Icon(
                        Icons.notifications,
                        color: Colors.white.withOpacity(0.8),
                        size: 24,
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "9+",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Battery icon
              if (showBattery)
                Icon(Icons.battery_full, color: Colors.green, size: 24),

              // Custom actions
              if (actions != null) ...actions!,
            ],
          ),
        ],
      ),
    );
  }
}
