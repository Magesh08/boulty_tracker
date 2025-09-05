#!/bin/bash

echo "🚀 Building and running Daily Tracker Flutter app..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Analyze code
echo "🔍 Analyzing code..."
flutter analyze

# Run the app (will open in available platform)
echo "🎯 Running the app..."
flutter run

echo "✅ Done!"

