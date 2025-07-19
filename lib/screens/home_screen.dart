import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_habit_screen.dart';
import 'login_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  String getTodayDate() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _toggleHabitCompletion(
      DocumentReference habitRef, List completedDates) async {
    final today = getTodayDate();

    if (completedDates.contains(today)) {
      // Uncheck today's completion
      completedDates.remove(today);
    } else {
      // Add today's date
      completedDates.add(today);
    }

    await habitRef.update({'completedDates': completedDates});
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text("No user logged in.", style: TextStyle(fontSize: 18)),
        ),
      );
    }

    final habitsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('habits');

    return Scaffold(
      appBar: AppBar(
        title: const Text("HabitHero"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: habitsRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No habits yet! Tap '+' to add one.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, index) {
              final data = docs[index].data() as Map<String, dynamic>?;

              final habitName = data?['name'] ?? 'Unnamed Habit';
              final frequency = data?['frequency'] ?? 'No frequency set';
              final completedDates =
                  List<String>.from(data?['completedDates'] ?? []);
              final today = getTodayDate();
              final isCompletedToday = completedDates.contains(today);

              final habitRef = docs[index].reference;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: IconButton(
                      icon: Icon(
                        isCompletedToday
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isCompletedToday ? Colors.green : Colors.grey,
                      ),
                      onPressed: () {
                        _toggleHabitCompletion(habitRef, completedDates);
                      },
                    ),
                    title: Text(
                      habitName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(frequency),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddHabitScreen()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add New Habit',
      ),
    );
  }
}
