import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'lib/services/cloudinary_service.dart'; // Import Cloudinary Service
import 'dashboard_screen.dart';
import 'landing_page.dart';
import 'ChangePasswodScreen.dart';
import 'EditProfileScreen.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user; // Receive user data from DashboardScreen

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinaryService =
      CloudinaryService(); // Cloudinary instance
  // ignore: unused_field
  File? _image;

  @override
  void initState() {
    super.initState();
    userData = widget.user;
  }

  /// **Logout User**
  void logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => LandingPage(),
      ), // Go to login page
      (route) => true, // Remove all previous screens
    );
  }

  /// **Pick and Upload Profile Picture (Cloudinary)**
  Future<void> uploadProfilePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return; // User didn't pick an image

    // ignore: unused_local_variable
    File imageFile = File(pickedFile.path); // Convert XFile to File

    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // ✅ Upload Image to Cloudinary
        String? imageUrl = await _cloudinaryService.uploadImage(
          context,
          pickedFile,
        );

        if (imageUrl != null) {
          // ✅ Update Firestore with New Profile Picture URL
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'profilePic': imageUrl});

          // ✅ Update Local User Data
          setState(() {
            userData?['profilePic'] = imageUrl;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile picture updated!")),
          );

          // ✅ Return Updated User Data to Dashboard
          Navigator.pop(context, userData);
        } else {
          throw "Failed to upload image";
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error uploading image: $e")));
      }
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
                  setState(() {}); // Refresh the state
                },
                child: const Text(
                  'Profile',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout, // Logout function
          ),
        ],
      ),
      body:
          userData == null
              ? const Center(child: CircularProgressIndicator())
              : Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            userData?['profilePic'] != null
                                ? NetworkImage(userData!['profilePic'])
                                : null,
                        child:
                            userData?['profilePic'] == null
                                ? const Icon(Icons.person, size: 50)
                                : null,
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: uploadProfilePicture,
                        child: const Text("Change Profile Picture"),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Name: ${userData?['name'] ?? "Not available"}',
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Email: ${userData?['email'] ?? "Not available"}',
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Role: ${userData?['role'] ?? "Not available"}',
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      EditProfileScreen(userData: userData!),
                            ),
                          ).then((_) {
                            setState(() {}); // Refresh profile after returning
                          });
                        },
                        child: const Text("Edit Profile"),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      ChangePasswordScreen(user: widget.user),
                            ),
                          );
                        },
                        child: const Text("Change Password"),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: logout,
                        child: const Text("Logout"),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
