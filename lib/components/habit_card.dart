import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HabitCard extends StatefulWidget {
  final DocumentSnapshot habit;
  final VoidCallback onUpdate;

  const HabitCard({required this.habit, required this.onUpdate, super.key});

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  late List completedDates;

  @override
  void initState() {
    super.initState();
    completedDates = widget.habit['completedDates'] ?? [];
  }

  bool isCompletedToday() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return completedDates.contains(today);
  }

  void toggleCompletion() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (!completedDates.contains(today)) {
      completedDates.add(today);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('habits')
          .doc(widget.habit.id)
          .update({'completedDates': completedDates});
    }

    widget.onUpdate(); // refresh UI from Home
  }

  @override
  Widget build(BuildContext context) {
    final habitName = widget.habit['name'] ?? '';

    return Card(
      child: ListTile(
        title: Text(habitName),
        trailing: IconButton(
          icon: Icon(
            isCompletedToday()
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: isCompletedToday() ? Colors.green : Colors.grey,
          ),
          onPressed: isCompletedToday() ? null : toggleCompletion,
        ),
      ),
    );
  }
}
