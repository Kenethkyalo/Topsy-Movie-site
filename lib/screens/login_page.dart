import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'lib/auth_service.dart';
import 'forgot_password_page.dart';
import 'dashboard_screen.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;

  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// **Show Dialog (Success)**
  void showSuccessDialog(
    BuildContext context,
    String message,
    VoidCallback onOkPressed,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Success"),
            content: Text(message),
            actions: [
              TextButton(onPressed: onOkPressed, child: const Text("OK")),
            ],
          ),
    );
  }

  /// **Show Snackbar (Error)**
  void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// **Login User**
  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      User? user = await _authService.signInWithEmail(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection("users").doc(user.uid).get();

        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;

          showSuccessDialog(
            context,
            "Login successful. Redirecting to Dashboard...",
            () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardScreen(user: userData),
                ),
              );
            },
          );
        } else {
          showErrorSnackBar(context, "User data not found. Please try again.");
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'invalid-credential':
        case 'user-not-found':
          errorMessage = "Invalid email or password.";
          break;
        case 'wrong-password':
          errorMessage = "Incorrect password.";
          break;
        case 'network-request-failed':
          errorMessage = "No internet connection. Try again.";
          break;
        default:
          errorMessage = "Error: ${e.message}";
      }

      showErrorSnackBar(context, errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 211, 228, 236),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Row(
          children: [
            // ✅ Clickable Logo (Redirects to Dashboard)
            InkWell(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DashboardScreen(user: {}),
                  ),
                );
              },
              child: Image.asset(
                'assets/LOGO.png',
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10), // Space between logo and title
            // ✅ Clickable Title (Refreshes the Page)
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {}); // Refresh the state
                },
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Welcome Back!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              /// **Email Input**
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter a valid email";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

              /// **Password Input**
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return "Enter Password to Continue!";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPasswordPage(user: {}),
                    ),
                  );
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.blue),
                ),
              ),

              /// **Login Button**
              ElevatedButton(onPressed: login, child: const Text("Login")),
            ],
          ),
        ),
      ),
    );
  }
}
