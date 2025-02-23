#!/bin/bash
set -e  # Exit on error

echo "🚀 Starting build process..."

# Install Flutter
echo "📦 Installing Flutter..."
git clone https://github.com/flutter/flutter.git --depth 1 -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
echo "✅ Verifying Flutter installation..."
flutter doctor

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
