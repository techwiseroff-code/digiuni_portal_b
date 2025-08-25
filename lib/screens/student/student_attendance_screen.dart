import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/styles.dart';
import '../../widgets/status_bar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/attendance_model.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    // Load attendance data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dataProvider = Provider.of<DataProvider>(context, listen: false);

      if (authProvider.currentUser != null) {
        dataProvider.listenToStudentAttendance(authProvider.currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: Styles.backgroundGradientFromImage),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                StatusBar(
                  title: "Attendance Details",
                  showBackButton: true,
                  onBackPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Consumer<DataProvider>(
                    builder: (context, dataProvider, child) {
                      if (dataProvider.isLoadingAttendance) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      final attendance = dataProvider.studentAttendance;
                      if (attendance.isEmpty) {
                        return const Center(
                          child: Text(
                            'No attendance records found',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      final overallStats = _calculateOverallStats(attendance);
                      final subjectStats = _calculateSubjectStats(attendance);

                      return Column(
                        children: [
                          Row(
                            children: [
                              _buildStatCard(
                                "Overall Attendance",
                                "${overallStats['percentage'].toStringAsFixed(0)}%",
                                "${overallStats['present']}/${overallStats['total']} Classes",
                                Colors.green,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                "Best Subject",
                                "${overallStats['bestSubjectPercentage'].toStringAsFixed(0)}%",
                                overallStats['bestSubject'] ?? "N/A",
                                Colors.blue,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildDonutChart(overallStats['percentage'] / 100),
                          const SizedBox(height: 24),
                          _buildSubjectAttendance(subjectStats),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateOverallStats(
    List<AttendanceModel> attendance,
  ) {
    if (attendance.isEmpty) {
      return {
        'percentage': 0.0,
        'present': 0,
        'total': 0,
        'bestSubject': null,
        'bestSubjectPercentage': 0.0,
      };
    }

    final total = attendance.length;
    final present = attendance.where((a) => a.status == 'present').length;
    final percentage = total > 0 ? (present / total) * 100 : 0.0;

    // Group by subject and find best
    final subjectGroups = <String, List<AttendanceModel>>{};
    for (final record in attendance) {
      subjectGroups.putIfAbsent(record.subject, () => []).add(record);
    }

    String? bestSubject;
    double bestPercentage = 0.0;
    for (final entry in subjectGroups.entries) {
      final subjectAttendance = entry.value;
      final subjectPresent = subjectAttendance
          .where((a) => a.status == 'present')
          .length;
      final subjectPercentage = subjectAttendance.isNotEmpty
          ? (subjectPresent / subjectAttendance.length) * 100
          : 0.0;

      if (subjectPercentage > bestPercentage) {
        bestPercentage = subjectPercentage;
        bestSubject = entry.key;
      }
    }

    return {
      'percentage': percentage,
      'present': present,
      'total': total,
      'bestSubject': bestSubject,
      'bestSubjectPercentage': bestPercentage,
    };
  }

  List<Map<String, dynamic>> _calculateSubjectStats(
    List<AttendanceModel> attendance,
  ) {
    if (attendance.isEmpty) return [];

    final subjectGroups = <String, List<AttendanceModel>>{};
    for (final record in attendance) {
      subjectGroups.putIfAbsent(record.subject, () => []).add(record);
    }

    final subjectStats = <Map<String, dynamic>>[];
    for (final entry in subjectGroups.entries) {
      final subjectAttendance = entry.value;
      final total = subjectAttendance.length;
      final present = subjectAttendance
          .where((a) => a.status == 'present')
          .length;
      final percentage = total > 0 ? present / total : 0.0;

      String tag;
      if (percentage >= 0.9)
        tag = "Excellent";
      else if (percentage >= 0.8)
        tag = "Good";
      else if (percentage >= 0.7)
        tag = "Average";
      else
        tag = "Needs Improvement";

      subjectStats.add({
        'name': entry.key,
        'percent': percentage,
        'count': "$present/$total",
        'tag': tag,
      });
    }

    // Sort by percentage descending
    subjectStats.sort(
      (a, b) => (b['percent'] as double).compareTo(a['percent'] as double),
    );
    return subjectStats;
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonutChart(double percentage) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.2),
            Colors.blue.withOpacity(0.2),
          ],
        ),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: CircularProgressIndicator(
                value: percentage,
                strokeWidth: 18,
                backgroundColor: Colors.red.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Attendance",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  "${(percentage * 100).toInt()}%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectAttendance(List<Map<String, dynamic>> subjects) {
    if (subjects.isEmpty) {
      return const Center(
        child: Text(
          'No subject attendance data available',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Subject-wise Attendance",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        ...subjects.map((s) => _buildSubjectRow(s)).toList(),
      ],
    );
  }

  Widget _buildSubjectRow(Map<String, dynamic> s) {
    final percent = s["percent"] as double;
    final tag = s["tag"] as String;
    Color tagColor = Colors.blue;
    if (tag == "Good") tagColor = Colors.green;
    if (tag == "Average") tagColor = Colors.orange;
    if (tag == "Excellent") tagColor = Colors.purple;
    if (tag == "Needs Improvement") tagColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s["name"],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "${(percent * 100).toInt()}%",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Container(
                height: 8,
                width: 220 * percent,
                decoration: BoxDecoration(
                  color: tagColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s["count"],
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: tagColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
