// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'feature_access.dart';
import 'upload_movie_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> user; // User details passed from login/register

  const DashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    String role =
        widget.user.containsKey('role') ? widget.user['role'] : 'User';
    String name =
        widget.user.containsKey('name') ? widget.user['name'] : 'Guest';
    String? profilePic = widget.user['profilePic']; // Get profile picture URL

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
                    builder: (context) => DashboardScreen(user: widget.user),
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
                  setState(() {}); // Just refresh the state
                },
                child: const Text(
                  'Dashboard',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadMovieScreen(user: widget.user),
                ),
              );
            },
          ),
          IconButton(
            icon:
                widget.user['profilePic'] != null
                    ? CircleAvatar(
                      backgroundImage: NetworkImage(widget.user['profilePic']),
                      radius: 15,
                    )
                    : const Icon(Icons.account_circle, size: 30),
            onPressed: () async {
              final updatedUser = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(user: widget.user),
                ),
              );

              if (updatedUser != null) {
                setState(() {
                  widget.user.addAll(updatedUser);
                });
              }
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $name!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(child: FeatureAccess(role: "admin")),
          ],
        ),
      ),
    );
  }
}
