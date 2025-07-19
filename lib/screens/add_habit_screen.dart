import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddHabitScreen extends StatefulWidget {
  @override
  _AddHabitScreenState createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _habitController = TextEditingController();
  String _frequency = 'Daily';
  bool _isLoading = false;

  void _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('habits')
              .add({
            'name': _habitController.text.trim(),
            'frequency': _frequency,
            'createdAt': Timestamp.now(),
            'completedDates': [], // initialize empty
          });

          // Reset loading state before navigation
          setState(() => _isLoading = false);

          // Show success message and navigate back
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Habit added successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate back after successful save
          Navigator.pop(context);
        } else {
          // Show error if user is not logged in
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not logged in')),
          );
        }
      } catch (e) {
        print('Error adding habit: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save habit: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _habitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add New Habit")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _habitController,
                    maxLength: 50,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a habit name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Habit Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _frequency,
                    decoration: InputDecoration(
                      labelText: 'Frequency',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: ['Daily', 'Weekly', 'Monthly'].map((f) {
                      return DropdownMenuItem(
                        value: f,
                        child: Text(f),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _frequency = val;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 30),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton.icon(
                          onPressed: _saveHabit,
                          icon: Icon(Icons.save),
                          label: Text("Save Habit"),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
