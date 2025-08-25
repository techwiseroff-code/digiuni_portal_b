import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/styles.dart';
import '../../widgets/status_bar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/timetable_model.dart';

class StudentTimetableScreen extends StatefulWidget {
  const StudentTimetableScreen({super.key});

  @override
  State<StudentTimetableScreen> createState() => _StudentTimetableScreenState();
}

class _StudentTimetableScreenState extends State<StudentTimetableScreen> {
  @override
  void initState() {
    super.initState();
    // Load student data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      
      if (authProvider.currentUser != null) {
        // Load student data to get class information
        dataProvider.loadStudentData(authProvider.currentUser!.uid);
        // Listen to class timetable
        final student = dataProvider.currentStudent;
        if (student != null) {
          dataProvider.listenToClassTimetable(student.className);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: Styles.backgroundGradientFromImage),
        child: SafeArea(
          child: Column(
            children: [
              // Clean status bar without fake elements
              const StatusBar(
                title: "Student Portal",
                showNotificationBell: false,
                showBattery: false,
              ),
              const SizedBox(height: 16),

              // Header with back button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Weekly Timetable",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Enhanced timetable with better scrolling
                      Expanded(child: _buildEnhancedTimetable()),
                      const SizedBox(height: 20),

                      // Summary cards
                      Consumer<DataProvider>(
                        builder: (context, dataProvider, child) {
                          final timetables = dataProvider.timetables;
                          final today = DateTime.now().weekday;
                          final todayClasses = timetables.where((t) => 
                            t.dayOfWeek == today
                          ).length;
                          final totalClasses = timetables.length;

                          return Row(
                            children: [
                              _buildSummaryCard(
                                title: "Today's Classes",
                                value: todayClasses.toString(),
                                subtitle: _getDayName(today),
                                icon: Icons.today,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 12),
                              _buildSummaryCard(
                                title: "This Week",
                                value: totalClasses.toString(),
                                subtitle: "Total Classes",
                                icon: Icons.calendar_today,
                                color: Colors.purple,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedTimetable() {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        if (dataProvider.isLoadingTimetable) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        final timetables = dataProvider.timetables;
        if (timetables.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Center(
              child: Text(
                'No timetable data available',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }

        // Extract all slots from all timetables with day information
        final allSlotsWithDay = <MapEntry<String, TimetableSlot>>[];
        for (final timetable in timetables) {
          for (final slot in timetable.slots) {
            allSlotsWithDay.add(MapEntry(timetable.dayOfWeek, slot));
          }
        }

        if (allSlotsWithDay.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Center(
              child: Text(
                'No timetable slots available',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }

        // Group slots by time slots
        final timeSlots = _getTimeSlots(allSlotsWithDay.map((e) => e.value).toList());
        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

        // Color scheme matching the image
        final dayColors = [
          Colors.blue, // Monday
          Colors.purple, // Tuesday
          Colors.pink, // Wednesday
          Colors.green, // Thursday
          Colors.yellow, // Friday
        ];

        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              // Fixed header row
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    // Time column header
                    SizedBox(
                      width: 80,
                      child: Text(
                        'Time',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    // Days headers with horizontal scroll
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: days
                              .map(
                                (day) => Container(
                                  width: 120,
                                  margin: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    day,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Timetable rows
              Expanded(
                child: ListView.builder(
                  itemCount: timeSlots.length,
                  itemBuilder: (context, timeIndex) {
                    final timeSlot = timeSlots[timeIndex];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Time column
                          SizedBox(
                            width: 80,
                            child: Text(
                              '${timeSlot['startTime']}\n${timeSlot['endTime']}',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // Days columns with horizontal scroll
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: days.asMap().entries.map((dayEntry) {
                                  final dayIndex = dayEntry.key;
                                  final day = dayEntry.value;
                                  final dayNumber = dayIndex + 1;
                                  
                                  // Find slot for this day and time
                                  final slotEntry = allSlotsWithDay.firstWhere(
                                    (entry) => _getDayNumber(entry.key) == dayNumber && 
                                               entry.value.startTime == timeSlot['startTime'],
                                    orElse: () => MapEntry('', TimetableSlot(
                                      subject: '',
                                      teacherId: '',
                                      teacherName: '',
                                      startTime: timeSlot['startTime']!,
                                      endTime: timeSlot['endTime']!,
                                      room: '',
                                    )),
                                  );

                                  return Container(
                                    width: 120,
                                    margin: const EdgeInsets.only(right: 8),
                                    child: slotEntry.value.subject.isNotEmpty
                                        ? _buildSubjectCard(slotEntry.value, dayColors[dayIndex])
                                        : Container(
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.05),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, String>> _getTimeSlots(List<TimetableSlot> slots) {
    final timeSlots = <Map<String, String>>[];
    final uniqueTimes = <String>{};
    
    for (final slot in slots) {
      uniqueTimes.add(slot.startTime);
    }
    
    final sortedTimes = uniqueTimes.toList()..sort();
    
    for (final startTime in sortedTimes) {
      // Find corresponding end time
      final slot = slots.firstWhere(
        (s) => s.startTime == startTime,
        orElse: () => TimetableSlot(
          subject: '',
          teacherId: '',
          teacherName: '',
          startTime: startTime,
          endTime: _getEndTime(startTime),
          room: '',
        ),
      );
      
      timeSlots.add({
        'startTime': startTime,
        'endTime': slot.endTime,
      });
    }
    
    return timeSlots;
  }

  int _getDayNumber(String dayName) {
    switch (dayName.toLowerCase()) {
      case 'monday': return 1;
      case 'tuesday': return 2;
      case 'wednesday': return 3;
      case 'thursday': return 4;
      case 'friday': return 5;
      case 'saturday': return 6;
      case 'sunday': return 7;
      default: return 1;
    }
  }

  String _getEndTime(String startTime) {
    // Simple logic to add 1 hour to start time
    final parts = startTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final endHour = hour + 1;
    return '${endHour.toString().padLeft(2, '0')}:$minute';
  }

  String _getDayName(int dayNumber) {
    switch (dayNumber) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Unknown';
    }
  }

  Widget _buildSubjectCard(TimetableSlot slot, Color color) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            slot.subject,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            slot.teacherName,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 8,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            slot.room,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 8,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.3),
              color.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
