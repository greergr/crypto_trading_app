#!/bin/bash
set -e

echo "🚀 Starting build process..."

# Download Flutter SDK
echo "📦 Downloading Flutter..."
git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter-sdk
export PATH="$PATH:$(pwd)/flutter-sdk/bin"

# Run basic Flutter commands
echo "✅ Setting up Flutter..."
flutter precache
flutter doctor -v

# Enable web
echo "🌐 Enabling web support..."
flutter config --enable-web

# Get dependencies
echo "📚 Getting dependencies..."
flutter pub get

# Build for web
echo "🏗️ Building web application..."
flutter build web --release

echo "✨ Build completed successfully!"
