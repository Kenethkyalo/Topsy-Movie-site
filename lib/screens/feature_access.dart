import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';

class FeatureAccess extends StatefulWidget {
  final String? role;
  const FeatureAccess({Key? key, this.role}) : super(key: key);

  @override
  _FeatureAccessState createState() => _FeatureAccessState();
}

class _FeatureAccessState extends State<FeatureAccess> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, String>> movies = [];
  String selectedCategory = 'movies';

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  void _fetchMovies() {
    _database.child(selectedCategory).onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          movies =
              data.entries.map((entry) {
                final movie = Map<String, dynamic>.from(entry.value);
                return {
                  "title": movie["title"]?.toString() ?? "Unknown Title",
                  "poster": movie["poster"]?.toString() ?? "",
                  "description":
                      movie["description"]?.toString() ??
                      "No description available",
                  "streamLink": movie["streamLink"]?.toString() ?? "",
                  "downloadLink": movie["downloadLink"]?.toString() ?? "",
                };
              }).toList();
        });
      } else {
        setState(() {
          movies = [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    selectedCategory = 'movies';
                    _fetchMovies();
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor:
                      selectedCategory == 'movies'
                          ? Colors.blueGrey
                          : Colors.transparent,
                ),
                child: Text("Movies", style: TextStyle(color: Colors.black)),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    selectedCategory = 'series';
                    _fetchMovies();
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor:
                      selectedCategory == 'series'
                          ? Colors.blueGrey
                          : Colors.transparent,
                ),
                child: Text("Series", style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child:
            movies.isEmpty
                ? Center(
                  child: Text(
                    "No ${selectedCategory == 'movies' ? 'Movies' : 'Series'} available",
                  ),
                )
                : LayoutBuilder(
                  builder: (context, constraints) {
                    double screenWidth = constraints.maxWidth;
                    int crossAxisCount = screenWidth > 600 ? 3 : 2;
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        var movie = movies[index];
                        return GestureDetector(
                          onTap: () => _showMovieDetails(movie),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(10),
                                    ),
                                    child: Image.network(
                                      movie['poster']!,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie['title']!,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        movie['description']!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
      ),
    );
  }

  void _showMovieDetails(Map<String, String> movie) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(movie['title']!),
          content: SingleChildScrollView(
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(movie['poster']!, fit: BoxFit.contain),
                ),
                SizedBox(height: 10),
                Text(movie['description']!),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _openLink(movie['streamLink']!),
                      child: Text("Stream"),
                    ),
                    ElevatedButton(
                      onPressed: () => _openLink(movie['downloadLink']!),
                      child: Text("Download"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _openLink(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print("Could not open URL: $url");
    }
  }
}
