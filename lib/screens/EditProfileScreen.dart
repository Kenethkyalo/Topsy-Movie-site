import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userData['name'] ?? '';
    _emailController.text = widget.userData['email'] ?? '';
  }

  /// **Update Profile Details**
  Future<void> updateProfile() async {
    setState(() => isLoading = true);
    User? user = _auth.currentUser;

    try {
      if (user != null) {
        // Update Firestore Name
        await _firestore.collection('users').doc(user.uid).update({
          'name': _nameController.text,
        });

        // Update Email in FirebaseAuth (if changed)
        if (_emailController.text != widget.userData['email']) {
          await user.updateEmail(_emailController.text);
          await _firestore.collection('users').doc(user.uid).update({
            'email': _emailController.text,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
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
                    builder:
                        (context) => DashboardScreen(user: widget.userData),
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
                  'Edit Profile',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : updateProfile,
              child:
                  isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
