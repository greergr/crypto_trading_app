FROM debian:latest AS build

# Install essential packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -ms /bin/bash flutter
USER flutter
WORKDIR /home/flutter

# Download Flutter SDK
RUN git clone https://github.com/flutter/flutter.git -b stable

# Add flutter to path
ENV PATH="/home/flutter/flutter/bin:${PATH}"

# Run flutter doctor
RUN flutter doctor

# Enable web
RUN flutter config --enable-web

# Copy the app files
COPY --chown=flutter:flutter . .

# Get app dependencies
RUN flutter pub get

# Build
RUN flutter build web --release

# Production stage
FROM nginx:alpine
COPY --from=build /home/flutter/build/web /usr/share/nginx/html
