#!/bin/bash
set -e

echo "🚀 Starting build process..."

# Install Flutter
echo "📦 Installing Flutter..."
git clone https://github.com/flutter/flutter.git --depth 1 -b stable _flutter
export PATH="$PATH:$(pwd)/_flutter/bin"

# Verify installation
echo "✅ Verifying Flutter installation..."
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
