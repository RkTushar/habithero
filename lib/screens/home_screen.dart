import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_habit_screen.dart';
import 'login_screen.dart';
import 'habit_detail_screen.dart';

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
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  Future<void> _toggleHabitCompletion(
    BuildContext context,
    DocumentReference habitRef,
    List<String> completedDates,
  ) async {
    final today = getTodayDate();
    final updatedSet = Set<String>.from(completedDates);

    final isAlreadyCompleted = updatedSet.contains(today);
    if (isAlreadyCompleted) {
      updatedSet.remove(today);
    } else {
      updatedSet.add(today);
    }

    try {
      await habitRef.update({'completedDates': updatedSet.toList()});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAlreadyCompleted
                ? "Marked as not done for today"
                : "Habit marked as done!",
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update habit."),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFF80DEEA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
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
                final docId = docs[index].id;
                final habitRef = habitsRef.doc(docId);

                final habitName = data?['name'] ?? 'Unnamed Habit';
                final frequency = data?['frequency'] ?? 'No frequency set';
                final completedDates =
                    List<String>.from(data?['completedDates'] ?? []);

                final today = getTodayDate();
                final isCompletedToday = completedDates.contains(today);

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
                        tooltip: isCompletedToday
                            ? 'Mark as not done'
                            : 'Mark as done',
                        onPressed: () {
                          _toggleHabitCompletion(
                              context, habitRef, completedDates);
                        },
                      ),
                      title: Text(
                        habitName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(frequency),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HabitDetailScreen(
                              habitId: docId,
                              habitName: habitName,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
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
