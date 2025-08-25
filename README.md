# DigiUni Portal

A comprehensive Flutter application for digital university management, featuring separate interfaces for students and teachers.

## Features

### 🎓 Student Features
- Dashboard with academic overview
- Profile management
- Notes and study materials
- ID card display
- Attendance tracking
- Timetable management
- Performance analytics
- AI-powered chat assistance

### 🧑‍🏫 Teacher Features
- Dashboard for class management
- Student attendance tracking
- Grade management
- Class scheduling
- Profile management
- ID card display

## Tech Stack

- **Framework**: Flutter 3.8.1+
- **Language**: Dart
- **UI Components**: Material Design with custom theming
- **HTTP Client**: http package for API communication
- **Icons**: Custom icon launcher configuration

## Getting Started

1. Ensure you have Flutter SDK installed (version 3.8.1 or higher)
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the application

## Project Structure

```
lib/
├── main.dart                 # Main application entry point
├── screens/                  # UI screens organized by user role
│   ├── auth/                # Authentication screens
│   ├── student/             # Student-specific screens
│   └── teacher/             # Teacher-specific screens
├── widgets/                  # Reusable UI components
├── theme/                    # App theming and colors
└── utils/                    # Utility functions and constants
```

## Dependencies

- `google_fonts`: Custom typography
- `flutter_svg`: SVG image support
- `http`: API communication
- `mime`: File type handling
- `path`: File path utilities
- `icons_launcher`: Custom app icons

## Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux
