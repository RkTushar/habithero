import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habithero/screens/add_habit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Stream<QuerySnapshot> _habitsStream;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _habitsStream = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _deleteHabit(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Habit deleted'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.red[400],
        ),
      );
    }
  }

  void _goToAddHabitScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddHabitScreen()),
    );
  }

  Widget _buildHabitCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 500),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 20),
              child: child,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: _isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              )
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: ListTile(
            title: Text(
              data['name'] ?? '',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            subtitle: Text(
              data['frequency'] ?? '',
              style: TextStyle(
                color: _isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _deleteHabit(doc.id),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: _isDarkMode ? Colors.black : Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text("HabitHero 🦸‍♂️"),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
              onPressed: _toggleTheme,
            )
          ],
        ),
        floatingActionButton: GestureDetector(
          onTap: _goToAddHabitScreen,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.tealAccent, Colors.blueAccent],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.tealAccent.withOpacity(0.6),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(Icons.add, color: Colors.black, size: 28),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _habitsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  "No habits yet. Tap + to add one!",
                  style: TextStyle(
                    fontSize: 16,
                    color: _isDarkMode ? Colors.white54 : Colors.black54,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.only(top: kToolbarHeight + 24, bottom: 100),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return _buildHabitCard(snapshot.data!.docs[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
