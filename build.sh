#!/bin/bash

# Install Flutter
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:`pwd`/flutter/bin"

# Enable web
flutter config --enable-web

# Get dependencies
flutter pub get

# Build
flutter build web --release
