import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("HabitHero Home")),
      body: Center(child: Text("Welcome! You're logged in.")),
    );
  }
}
