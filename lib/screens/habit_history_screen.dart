import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/transition_helper.dart';

class HabitHistoryScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    final habitsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('habits');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Habit History"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: habitsRef.snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final habitDocs = snapshot.data?.docs ?? [];

          if (habitDocs.isEmpty) {
            return const Center(
              child: Text("No habits found."),
            );
          }

          return ListView.builder(
            itemCount: habitDocs.length,
            itemBuilder: (ctx, index) {
              final habit = habitDocs[index];
              final habitId = habit.id;
              final habitName = habit['name'];

              return ListTile(
                title: Text(habitName),
                trailing: const Icon(Icons.history),
                onTap: () {
                  Navigator.push(
                    context,
                    createSlideRoute(
                      HabitDetailScreen(
                        habitId: habitId,
                        habitName: habitName,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class HabitDetailScreen extends StatelessWidget {
  final String habitId;
  final String habitName;
  final User? user = FirebaseAuth.instance.currentUser;

  HabitDetailScreen({required this.habitId, required this.habitName});

  @override
  Widget build(BuildContext context) {
    final completionsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('habit_completions')
        .doc(habitId)
        .collection('dates');

    return Scaffold(
      appBar: AppBar(
        title: Text("History: $habitName"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            completionsRef.orderBy('timestamp', descending: true).snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final completionDocs = snapshot.data?.docs ?? [];

          if (completionDocs.isEmpty) {
            return const Center(
              child: Text("No completion history found."),
            );
          }

          return ListView.builder(
            itemCount: completionDocs.length,
            itemBuilder: (ctx, index) {
              final timestamp = completionDocs[index]['timestamp'] as Timestamp;
              final date = timestamp.toDate();

              return ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(
                  "${date.day}/${date.month}/${date.year}",
                  style: const TextStyle(fontSize: 16),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
