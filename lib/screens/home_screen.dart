import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_habit_screen.dart';

class HomeScreen extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final habitsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('habits');

    return Scaffold(
      appBar: AppBar(title: Text("Your Habits")),
      body: StreamBuilder(
        stream: habitsRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) return Center(child: Text("No habits yet!"));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['name']),
                subtitle: Text(data['frequency']),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddHabitScreen()),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_habit_screen.dart';

class HomeScreen extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final habitsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('habits');

    return Scaffold(
      appBar: AppBar(title: Text("Your Habits")),
      body: StreamBuilder(
        stream: habitsRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) return Center(child: Text("No habits yet!"));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['name']),
                subtitle: Text(data['frequency']),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddHabitScreen()),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}
