# Use stable nginx version
FROM nginx:1.25.3-alpine

# Remove default nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy the Flutter web build files
COPY build/web /usr/share/nginx/html

# Use custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

