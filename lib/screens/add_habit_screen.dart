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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Add New Habit",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[600]!, Colors.blue[400]!, Colors.blue[200]!],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header Section
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.add_task,
                        size: 60,
                        color: Colors.white,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Create Your New Habit",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Build better habits, one step at a time",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Form Card
                Container(
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Habit Name Field
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
                              hintText: 'e.g., Exercise, Read, Meditate',
                              prefixIcon:
                                  Icon(Icons.edit, color: Colors.blue[600]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                    color: Colors.blue[600]!, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                            ),
                          ),

                          SizedBox(height: 24),

                          // Frequency Dropdown
                          DropdownButtonFormField<String>(
                            value: _frequency,
                            decoration: InputDecoration(
                              labelText: 'Frequency',
                              prefixIcon: Icon(Icons.calendar_today,
                                  color: Colors.blue[600]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                    color: Colors.blue[600]!, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'Daily',
                                child: Row(
                                  children: [
                                    Icon(Icons.today, color: Colors.blue[600]),
                                    SizedBox(width: 12),
                                    Text('Daily'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Weekly',
                                child: Row(
                                  children: [
                                    Icon(Icons.view_week,
                                        color: Colors.blue[600]),
                                    SizedBox(width: 12),
                                    Text('Weekly'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Monthly',
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_month,
                                        color: Colors.blue[600]),
                                    SizedBox(width: 12),
                                    Text('Monthly'),
                                  ],
                                ),
                              ),
                            ].toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _frequency = val;
                                });
                              }
                            },
                          ),

                          SizedBox(height: 32),

                          // Save Button
                          _isLoading
                              ? Container(
                                  height: 56,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.blue[600]!),
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 56,
                                  child: ElevatedButton.icon(
                                    onPressed: _saveHabit,
                                    icon: Icon(Icons.save, color: Colors.white),
                                    label: Text(
                                      "Save Habit",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[600],
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      elevation: 8,
                                      shadowColor: Colors.blue.withOpacity(0.3),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
