import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  int get _totalCompletions => _completedDays.length;

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

  Future<void> _toggleCompletion(DateTime day) async {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final isCompleted = _completedDays.contains(normalizedDay);
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('habits')
        .doc(widget.habitId);

    setState(() {
      if (isCompleted) {
        _completedDays.remove(normalizedDay);
      } else {
        _completedDays.add(normalizedDay);
      }
    });

    await userDoc.update({
      'completedDates':
          _completedDays.map((d) => Timestamp.fromDate(d)).toList(),
    });
  }

  bool _isCompleted(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _completedDays.contains(normalizedDay);
  }

  void _showDayDialog(DateTime day) {
    final completed = _isCompleted(day);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          completed ? 'Mark as Incomplete?' : 'Mark as Completed?',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          completed
              ? 'Do you want to unmark this day as completed?'
              : 'Do you want to mark this day as completed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _toggleCompletion(day);
            },
            child: Text(completed ? 'Unmark' : 'Mark Completed'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habitName),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                color: Colors.deepPurple.shade50,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.habitName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total completions: $_totalCompletions',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TableCalendar(
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                calendarStyle: CalendarStyle(
                  todayDecoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.green.shade400,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: const TextStyle(color: Colors.redAccent),
                  outsideDaysVisible: false,
                ),
                selectedDayPredicate: _isCompleted,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                  _showDayDialog(selectedDay);
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    if (_isCompleted(day)) {
                      return Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade400,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
