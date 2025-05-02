# Use official Flutter image from Cirrus CI
FROM cirrusci/flutter:3.19.6 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy only pubspec files first (caches dependencies)
COPY pubspec.* ./

# Get dependencies
RUN flutter pub get

# Copy the entire Flutter project
COPY . .

# Build the web app
RUN flutter build web

# Final stage: Use Nginx to serve the built app
FROM nginx:alpine

# Replace default nginx web content with Flutter build output
COPY --from=build /app/build/web /usr/share/nginx/html
