# Stage 1: Build Flutter web app
FROM ghcr.io/cirruslabs/flutter:stable AS build-env

# Set working directory
WORKDIR /app

# Copy pubspec files
COPY pubspec.* ./

# Get dependencies
RUN flutter pub get

# Copy the rest of the application
COPY . .

# Build for web
RUN flutter build web --release --web-renderer html

# Stage 2: Create the run-time image
FROM nginx:alpine

# Copy the built web app
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
