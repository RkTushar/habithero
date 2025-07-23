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
  final Set<DateTime> _completedDays = {};
  int get _totalCompletions => _completedDays.length;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _loadCompletedDates();
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  Future<void> _loadCompletedDates() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('habits')
          .doc(widget.habitId)
          .get();

      final data = snapshot.data();
      if (data == null || data['completedDates'] == null) return;

      final List<dynamic> rawDates = data['completedDates'];

      setState(() {
        _completedDays.addAll(
          rawDates.map((ts) => (ts as Timestamp).toDate()).map(_normalizeDate),
        );
      });
    } catch (e) {
      debugPrint("Error loading completed dates: $e");
    }
  }

  Future<void> _toggleCompletion(DateTime day) async {
    final normalizedDay = _normalizeDate(day);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final habitDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('habits')
        .doc(widget.habitId);

    final isCompleted = _completedDays.contains(normalizedDay);

    setState(() {
      isCompleted
          ? _completedDays.remove(normalizedDay)
          : _completedDays.add(normalizedDay);
    });

    try {
      await habitDoc.update({
        'completedDates': _completedDays.map(Timestamp.fromDate).toList(),
      });
    } catch (e) {
      debugPrint("Error updating completion status: $e");
    }
  }

  bool _isCompleted(DateTime day) =>
      _completedDays.contains(_normalizeDate(day));

  void _showDayDialog(DateTime day) {
    final completed = _isCompleted(day);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _toggleCompletion(day);
            },
            child: Text(completed ? 'Unmark' : 'Mark Completed'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.deepPurple.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2023, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: CalendarFormat.month,
      selectedDayPredicate: _isCompleted,
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
        _showDayDialog(selectedDay);
      },
      calendarStyle: CalendarStyle(
        todayDecoration: const BoxDecoration(
          color: Colors.blueAccent,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.green.shade400,
          shape: BoxShape.circle,
        ),
        weekendTextStyle: const TextStyle(color: Colors.redAccent),
        outsideDaysVisible: false,
      ),
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
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          return null;
        },
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 24),
            _buildCalendar(),
          ],
        ),
      ),
    );
  }
}
