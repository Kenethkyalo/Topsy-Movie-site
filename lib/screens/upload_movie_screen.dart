import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dashboard_screen.dart';
import 'webview_screen.dart'; // Import the WebView screen

class UploadMovieScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const UploadMovieScreen({Key? key, required this.user}) : super(key: key);

  @override
  _UploadMovieScreenState createState() => _UploadMovieScreenState();
}

class _UploadMovieScreenState extends State<UploadMovieScreen> {
  final TextEditingController _titleController = TextEditingController();
  String? _posterUrl;
  String? _streamUrl;
  String? _downloadUrl;
  String? _description;
  String? _releaseDate;

  String _selectedCategory = "movies"; // Default to movies
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
  final String _apiUrl =
      "https://web-production-97ce2.up.railway.app/search"; // Ensure the API is running

  Future<void> _fetchMovieData() async {
    String title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a movie title.")),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("$_apiUrl?title=${Uri.encodeComponent(title)}"),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data.containsKey("error")) {
          throw data["error"];
        }

        setState(() {
          _posterUrl = data["poster"];
          _description = data["description"];
          _releaseDate = data["release_date"];
          _streamUrl = _downloadUrl = data["streamLink"];
        });
      } else {
        throw "Failed to fetch movie data";
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _uploadMovie() {
    String title = _titleController.text.trim();

    if (title.isNotEmpty && _streamUrl != null) {
      DatabaseReference ref = databaseRef.child(_selectedCategory).push();
      ref
          .set({
            "title": title,
            "description": _description,
            "release_date": _releaseDate,
            "poster": _posterUrl,
            "streamLink": _streamUrl,
            "downloadLink": _downloadUrl,
          })
          .then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("$_selectedCategory uploaded successfully!"),
              ),
            );
            Navigator.pop(context);
          })
          .catchError((error) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Failed to upload: $error")));
          });
    }
  }

  // Function to open links inside the app
  void _openWebView(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WebViewScreen(url: url)),
    );
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
                  'Upload Movie/Series',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items:
                  ["movies", "series"].map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category.toUpperCase()),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              decoration: const InputDecoration(labelText: "Select Category"),
            ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchMovieData,
              child: const Text("Fetch Movie Data"),
            ),
            const SizedBox(height: 20),

            // Movie Details Display
            if (_posterUrl != null ||
                _description != null ||
                _releaseDate != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_posterUrl != null)
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            _posterUrl!,
                            width: 200,
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    if (_titleController.text.isNotEmpty)
                      Center(
                        child: Text(
                          _titleController.text,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 10),

                    if (_description != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Description:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _description!,
                            style: const TextStyle(fontSize: 14),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),

                    if (_releaseDate != null)
                      Text(
                        "Release Date: $_releaseDate",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    const SizedBox(height: 20),

                    if (_streamUrl != null)
                      Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.play_circle_fill),
                          onPressed: () => _openWebView(_streamUrl!),
                          label: const Text("Stream Movie"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),

                    if (_downloadUrl != null)
                      Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.download),
                          onPressed: () => _openWebView(_downloadUrl!),
                          label: const Text("Download Movie"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _uploadMovie,
              child: const Text("Upload"),
            ),
          ],
        ),
      ),
    );
  }
}
