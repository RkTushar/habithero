import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddHabitScreen extends StatefulWidget {
  @override
  _AddHabitScreenState createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _habitController = TextEditingController();
  String _frequency = 'Daily';

  void _saveHabit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final habitName = _habitController.text.trim();
    if (habitName.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('habits')
        .add({
      'name': habitName,
      'frequency': _frequency,
      'createdAt': Timestamp.now(),
    });

    Navigator.pop(context); // Go back to habit list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Habit")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _habitController,
              decoration: InputDecoration(labelText: 'Habit Name'),
            ),
            DropdownButton<String>(
              value: _frequency,
              onChanged: (val) => setState(() => _frequency = val!),
              items: ['Daily', 'Weekly', 'Monthly'].map((f) {
                return DropdownMenuItem(value: f, child: Text(f));
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _saveHabit, child: Text('Save Habit')),
          ],
        ),
      ),
    );
  }
}
