import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import '../services/theme_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLogin = true;
  bool _isLoading = false;

  void _submitAuthForm() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (isLogin) {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
      } else {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentication failed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unexpected error occurred")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.blue[800]!, Colors.blue[600]!, Colors.blue[400]!]
                : [Colors.blue[600]!, Colors.blue[400]!, Colors.blue[200]!],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header Section with Theme Toggle
                Container(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: 40), // Spacer for centering
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.fitness_center,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isDark ? Icons.light_mode : Icons.dark_mode,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              context.read<ThemeService>().toggleTheme();
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Text(
                        "HabitHero",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        isLogin ? "Welcome back!" : "Start your journey",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                // Login Form Card
                Container(
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          isLogin ? "Sign In" : "Create Account",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 32),

                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            prefixIcon: Icon(Icons.email,
                                color: theme.colorScheme.primary),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: Icon(Icons.lock,
                                color: theme.colorScheme.primary),
                            suffixIcon: Icon(Icons.visibility_off,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.5)),
                          ),
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                        ),
                        SizedBox(height: 32),

                        // Submit Button
                        _isLoading
                            ? Container(
                                height: 56,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        theme.colorScheme.primary),
                                  ),
                                ),
                              )
                            : Container(
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: _submitAuthForm,
                                  icon: Icon(
                                    isLogin ? Icons.login : Icons.person_add,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    isLogin ? "Sign In" : "Sign Up",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                        SizedBox(height: 24),

                        // Toggle Button
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isLogin = !isLogin;
                            });
                          },
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color),
                              children: [
                                TextSpan(
                                  text: isLogin
                                      ? "Don't have an account? "
                                      : "Already have an account? ",
                                ),
                                TextSpan(
                                  text: isLogin ? "Sign Up" : "Sign In",
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
