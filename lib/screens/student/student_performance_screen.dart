import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/styles.dart';
import '../../widgets/status_bar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/performance_model.dart';

class StudentPerformanceScreen extends StatefulWidget {
  const StudentPerformanceScreen({super.key});

  @override
  State<StudentPerformanceScreen> createState() =>
      _StudentPerformanceScreenState();
}

class _StudentPerformanceScreenState extends State<StudentPerformanceScreen> {
  @override
  void initState() {
    super.initState();
    // Load performance data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dataProvider = Provider.of<DataProvider>(context, listen: false);

      if (authProvider.currentUser != null) {
        dataProvider.listenToStudentPerformance(authProvider.currentUser!.uid);
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
                  title: "Performance Details",
                  showBackButton: true,
                  onBackPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Consumer<DataProvider>(
                    builder: (context, dataProvider, child) {
                      if (dataProvider.isLoadingPerformance) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      final performance = dataProvider.studentPerformance;
                      if (performance.isEmpty) {
                        return const Center(
                          child: Text(
                            'No performance records found',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      final overallStats = _calculateOverallStats(performance);
                      final subjectStats = _calculateSubjectStats(performance);
                      final gradeDistribution = _calculateGradeDistribution(
                        performance,
                      );

                      return Column(
                        children: [
                          Row(
                            children: [
                              _buildStatCard(
                                "Current GPA",
                                overallStats['gpa'].toStringAsFixed(1),
                                "Out of 4.0",
                                Colors.green,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                "Average Score",
                                "${overallStats['averageScore'].toStringAsFixed(0)}%",
                                "Overall Performance",
                                Colors.blue,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildGradeDistribution(
                            overallStats['gpa'] / 4.0,
                            gradeDistribution,
                          ),
                          const SizedBox(height: 24),
                          _buildSubjectPerformance(subjectStats),
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
    List<PerformanceModel> performance,
  ) {
    if (performance.isEmpty) {
      return {'gpa': 0.0, 'averageScore': 0.0, 'totalSubjects': 0};
    }

    double totalScore = 0;
    int totalSubjects = performance.length;

    for (final record in performance) {
      final percentage = (record.marks / record.totalMarks) * 100;
      totalScore += percentage;
    }

    final averageScore = totalScore / totalSubjects;

    // Convert percentage to GPA (simplified conversion)
    double gpa;
    if (averageScore >= 93)
      gpa = 4.0;
    else if (averageScore >= 90)
      gpa = 3.7;
    else if (averageScore >= 87)
      gpa = 3.3;
    else if (averageScore >= 83)
      gpa = 3.0;
    else if (averageScore >= 80)
      gpa = 2.7;
    else if (averageScore >= 77)
      gpa = 2.3;
    else if (averageScore >= 73)
      gpa = 2.0;
    else if (averageScore >= 70)
      gpa = 1.7;
    else if (averageScore >= 67)
      gpa = 1.3;
    else if (averageScore >= 63)
      gpa = 1.0;
    else if (averageScore >= 60)
      gpa = 0.7;
    else
      gpa = 0.0;

    return {
      'gpa': gpa,
      'averageScore': averageScore,
      'totalSubjects': totalSubjects,
    };
  }

  List<Map<String, dynamic>> _calculateSubjectStats(
    List<PerformanceModel> performance,
  ) {
    if (performance.isEmpty) return [];

    final subjectStats = <Map<String, dynamic>>[];
    for (final record in performance) {
      final percentage = (record.marks / record.totalMarks) * 100;
      subjectStats.add({
        'subject': record.subject,
        'score': percentage,
        'marks': record.marks,
        'totalMarks': record.totalMarks,
        'examType': record.examType,
        'date': record.examDate,
      });
    }

    // Sort by score descending
    subjectStats.sort(
      (a, b) => (b['score'] as double).compareTo(a['score'] as double),
    );
    return subjectStats;
  }

  Map<String, int> _calculateGradeDistribution(
    List<PerformanceModel> performance,
  ) {
    if (performance.isEmpty) return {};

    final gradeCounts = <String, int>{};
    for (final record in performance) {
      final percentage = (record.marks / record.totalMarks) * 100;
      String grade;

      if (percentage >= 93)
        grade = "A";
      else if (percentage >= 90)
        grade = "A-";
      else if (percentage >= 87)
        grade = "B+";
      else if (percentage >= 83)
        grade = "B";
      else if (percentage >= 80)
        grade = "B-";
      else if (percentage >= 77)
        grade = "C+";
      else if (percentage >= 73)
        grade = "C";
      else if (percentage >= 70)
        grade = "C-";
      else if (percentage >= 67)
        grade = "D+";
      else if (percentage >= 63)
        grade = "D";
      else if (percentage >= 60)
        grade = "D-";
      else
        grade = "F";

      gradeCounts[grade] = (gradeCounts[grade] ?? 0) + 1;
    }

    return gradeCounts;
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

  Widget _buildGradeDistribution(
    double gpaPercentage,
    Map<String, int> gradeDistribution,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Grade Distribution",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Donut chart
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.withOpacity(0.2),
                      Colors.blue.withOpacity(0.2),
                    ],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: gpaPercentage,
                        strokeWidth: 12,
                        backgroundColor: Colors.red.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.greenAccent,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "GPA",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          (gpaPercentage * 4.0).toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Grade legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (gradeDistribution.isNotEmpty) ...[
                      ...gradeDistribution.entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildGradeLegend(
                            entry.key,
                            entry.value,
                            _getGradeColor(entry.key),
                          ),
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'No grades available',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
      case 'A-':
        return Colors.green;
      case 'B+':
      case 'B':
      case 'B-':
        return Colors.blue;
      case 'C+':
      case 'C':
      case 'C-':
        return Colors.orange;
      case 'D+':
      case 'D':
      case 'D-':
        return Colors.red;
      case 'F':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildGradeLegend(String grade, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "$grade: $count",
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSubjectPerformance(List<Map<String, dynamic>> subjects) {
    if (subjects.isEmpty) {
      return const Center(
        child: Text(
          'No subject performance data available',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Subject Performance",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ...subjects
              .map(
                (subject) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildSubjectBar(
                    subject['subject'],
                    subject['score'],
                    _getSubjectColor(subject['subject']),
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.pink,
      Colors.indigo,
      Colors.teal,
      Colors.orange,
      Colors.deepPurple,
      Colors.cyan,
    ];

    final index = subject.hashCode % colors.length;
    return colors[index];
  }

  Widget _buildSubjectBar(String subject, double score, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              subject,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            Text(
              "${score.toStringAsFixed(0)}%",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
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
              width: 220 * (score / 100),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
