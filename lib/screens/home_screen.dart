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
        backgroundColor: Colors.grey[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                "No user logged in.",
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    final habitsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('habits');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.fitness_center, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "HabitHero",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              tooltip: 'Logout',
              onPressed: () => _logout(context),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[600]!, Colors.blue[400]!, Colors.blue[200]!],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: habitsRef.orderBy('createdAt', descending: true).snapshots(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return Container(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_task,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      "No habits yet!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Tap the + button to add your first habit",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16),
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

                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isCompletedToday
                            ? Colors.green.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          isCompletedToday
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isCompletedToday
                              ? Colors.green
                              : Colors.blue[600],
                          size: 28,
                        ),
                        onPressed: () {
                          _toggleHabitCompletion(habitRef, completedDates);
                        },
                      ),
                    ),
                    title: Text(
                      habitName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                    subtitle: Container(
                      margin: EdgeInsets.only(top: 4),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        frequency,
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 16),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddHabitScreen()),
            );
          },
          icon: Icon(Icons.add, color: Colors.white),
          label: Text(
            "Add Habit",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.blue[600],
          elevation: 8,
          tooltip: 'Add New Habit',
        ),
      ),
    );
  }
}
