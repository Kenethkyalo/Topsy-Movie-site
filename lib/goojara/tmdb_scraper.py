from flask import Flask, request, jsonify
from flask_cors import CORS  # Enable CORS for Flutter Web
import requests

app = Flask(__name__)
CORS(app)  # Allow all origins

TMDB_API_KEY = "1d34ec442cd9da72dc8bd82cddeaf282"  # Replace with your TMDb API Key

def get_movie_details(movie_title):
    # Search for the movie on TMDb
    url = f"https://api.themoviedb.org/3/search/movie?api_key={TMDB_API_KEY}&query={movie_title}"
    response = requests.get(url)
    data = response.json()
    
    if "results" in data and len(data["results"]) > 0:
        movie = data["results"][0]
        movie_id = movie["id"]

        # Fetch YouTube Trailer
        trailer_url = f"https://api.themoviedb.org/3/movie/{movie_id}/videos?api_key={TMDB_API_KEY}"
        trailer_response = requests.get(trailer_url).json()
        youtube_link = None

        for video in trailer_response.get("results", []):
            if video["site"] == "YouTube" and video["type"].lower() in ["trailer", "teaser", "clip"]:
                youtube_link = f"https://www.youtube.com/watch?v={video['key']}"
                break

        # If no YouTube link found, use a placeholder
        if not youtube_link:
            youtube_link = "https://www.youtube.com"  # Generic YouTube page

        return {
            "title": movie["title"],
            "poster": f"https://image.tmdb.org/t/p/w500{movie['poster_path']}" if movie["poster_path"] else None,
            "description": movie["overview"],
            "release_date": movie["release_date"],
            "streamLink": youtube_link,  # Now correctly fetching YouTube trailer
            "downloadLink": youtube_link  # Using the same link for now
        }
    else:
        return {"error": "Movie not found"}


@app.route('/search', methods=['GET'])
def search():
    movie_title = request.args.get('title')
    if not movie_title:
        return jsonify({"error": "No title provided"}), 400

    data = get_movie_details(movie_title)
    return jsonify(data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)  # Change port if needed
