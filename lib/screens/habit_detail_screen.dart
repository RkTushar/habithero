import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class HabitDetailScreen extends StatefulWidget {
  final String habitId;
  final String habitName;

  const HabitDetailScreen({
    Key? key,
    required this.habitId,
    required this.habitName,
  }) : super(key: key);

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late DateTime _focusedDay;
  Set<DateTime> _completedDays = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _loadCompletedDates();
  }

  Future<void> _loadCompletedDates() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('habits')
        .doc(widget.habitId)
        .get();

    final data = snapshot.data();
    if (data == null) return;

    List<dynamic> rawDates = data['completedDates'] ?? [];

    setState(() {
      _completedDays = rawDates
          .map((ts) => (ts as Timestamp).toDate())
          .map((date) => DateTime(date.year, date.month, date.day))
          .toSet();
    });
  }

  bool _isCompleted(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _completedDays.contains(normalizedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habitName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TableCalendar(
          firstDay: DateTime.utc(2023, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: CalendarFormat.month,
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
            ),
          ),
          selectedDayPredicate: _isCompleted,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
        ),
      ),
    );
  }
}
