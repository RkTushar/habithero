import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'add_habit_screen.dart';
import 'login_screen.dart';
import 'habit_detail_screen.dart';
import 'habit_history_screen.dart' hide HabitDetailScreen;
import 'profile_screen.dart';
import '../services/theme_service.dart';
import '../utils/transition_helper.dart';

class HomeScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      createFadeRoute(LoginScreen()),
    );
  }

  String getTodayDate() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  String _formatTime(BuildContext context, int hour, int minute) {
    final time = TimeOfDay(hour: hour, minute: minute);
    return time.format(context);
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
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update habit: ${e.toString()}"),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
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

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final habitsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('habits');

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "HabitHero",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? Colors.white : Colors.black87,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () {
              context.read<ThemeService>().toggleTheme();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.history,
              color: isDark ? Colors.white : Colors.black87,
            ),
            tooltip: 'Habit History',
            onPressed: () {
              Navigator.push(
                context,
                createSlideRoute(HabitHistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.person,
              color: isDark ? Colors.white : Colors.black87,
            ),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                createSlideRoute(ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.logout,
              color: isDark ? Colors.white : Colors.black87,
            ),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    Color(0xFF0F0F23),
                    Color(0xFF1A1A2E),
                    Color(0xFF16213E),
                  ]
                : [
                    Color(0xFF667eea),
                    Color(0xFF764ba2),
                    Color(0xFFf093fb),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: habitsRef.snapshots(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: isDark ? Colors.white : Colors.white,
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              // Sort documents manually to handle both Timestamp and String createdAt
              docs.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;

                final aCreatedAt = aData['createdAt'];
                final bCreatedAt = bData['createdAt'];

                // Handle null createdAt (old habits)
                if (aCreatedAt == null && bCreatedAt == null) return 0;
                if (aCreatedAt == null) return 1; // Put nulls at the end
                if (bCreatedAt == null) return -1;

                // Handle Timestamp vs String comparison
                if (aCreatedAt is Timestamp && bCreatedAt is Timestamp) {
                  return bCreatedAt.compareTo(aCreatedAt); // Descending
                } else if (aCreatedAt is String && bCreatedAt is String) {
                  return bCreatedAt.compareTo(aCreatedAt); // Descending
                } else {
                  // Mixed types - convert both to DateTime for comparison
                  DateTime aDate, bDate;

                  if (aCreatedAt is Timestamp) {
                    aDate = aCreatedAt.toDate();
                  } else {
                    aDate = DateTime.parse(aCreatedAt);
                  }

                  if (bCreatedAt is Timestamp) {
                    bDate = bCreatedAt.toDate();
                  } else {
                    bDate = DateTime.parse(bCreatedAt);
                  }

                  return bDate.compareTo(aDate); // Descending
                }
              });

              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_task,
                        size: 80,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      SizedBox(height: 16),
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
                        "Tap the + button to create your first habit",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Text(
                        "Your Habits",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final docId = doc.id;
                          final habitRef = habitsRef.doc(docId);

                          final habitName = data['name'] ?? 'Unnamed Habit';
                          final frequency =
                              data['frequency'] ?? 'Not specified';
                                                     final completedDatesRaw = data['completedDates'];
                           final completedDates = completedDatesRaw != null 
                               ? List<String>.from(completedDatesRaw)
                               : <String>[];
                          final reminderHour = data['reminderHour'] ?? 20;
                          final reminderMinute = data['reminderMinute'] ?? 0;

                          final today = getTodayDate();
                          final isCompletedToday =
                              completedDates.contains(today);
                          final formattedTime = _formatTime(
                              context, reminderHour, reminderMinute);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.white.withOpacity(0.9),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      createSlideRoute(
                                        HabitDetailScreen(
                                          habitId: docId,
                                          habitName: habitName,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isCompletedToday
                                                ? Colors.green.withOpacity(0.2)
                                                : Colors.grey.withOpacity(0.2),
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              isCompletedToday
                                                  ? Icons.check_circle
                                                  : Icons
                                                      .radio_button_unchecked,
                                              color: isCompletedToday
                                                  ? Colors.green
                                                  : Colors.grey,
                                              size: 28,
                                            ),
                                            onPressed: () {
                                              _toggleHabitCompletion(context,
                                                  habitRef, completedDates);
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                habitName,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black87,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                frequency,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: isDark
                                                      ? Colors.white
                                                          .withOpacity(0.7)
                                                      : Colors.black54,
                                                ),
                                              ),
                                              SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time,
                                                    size: 14,
                                                    color: isDark
                                                        ? Colors.white
                                                            .withOpacity(0.6)
                                                        : Colors.black45,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    formattedTime,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: isDark
                                                          ? Colors.white
                                                              .withOpacity(0.6)
                                                          : Colors.black45,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: isDark
                                              ? Colors.white.withOpacity(0.5)
                                              : Colors.black45,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: docs.length,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF667eea).withOpacity(0.4),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          tooltip: 'Add New Habit',
          onPressed: () {
            Navigator.push(
              context,
              createSlideRoute(AddHabitScreen()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          label: Text(
            "Add Habit",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          icon: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: null,
    );
  }
}
