import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_habit_screen.dart';
import 'login_screen.dart';
import 'habit_detail_screen.dart';
import 'habit_history_screen.dart' hide HabitDetailScreen;
import 'profile_screen.dart';

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

  String _formatTime(int hour, int minute) {
    final time = TimeOfDay(hour: hour, minute: minute);
    final now = DateTime.now();
    final dt = DateTime(
        now.year, now.month, now.day, time.hour, time.minute);
    final formatted = TimeOfDay.fromDateTime(dt).format(
      const TimeOfDayFormat(
        alwaysUse24HourFormat: false,
      ).toMaterialLocalizations(const Locale('en', 'US')),
    );
    return formatted;
  }

  Future<void> _toggleHabitCompletion(
    BuildContext context,
    DocumentReference habitRef,
    List<String> completedDates,
  ) async {
    final today = getTodayDate();
    final updatedSet = Set<String>.from(completedDates);
    final isCompleted = updatedSet.contains(today);

    isCompleted ? updatedSet.remove(today) : updatedSet.add(today);

    try {
      await habitRef.update({'completedDates': updatedSet.toList()});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isCompleted
              ? "Marked as not done for today"
              : "Habit marked as done!"),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update habit.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        body: Center(child: Text("No user logged in.")),
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
            icon: const Icon(Icons.history),
            tooltip: 'Habit History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HabitHistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen()),
              );
            },
          ),
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
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final docId = doc.id;
                final hab
