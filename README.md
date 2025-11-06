# Kiwi Spending Tracker

Little tool to help you track your spending.

## Features

- Track daily, monthly, and yearly expenses
- Categorize expenses with customizable categories
- Support for fixed, variable, and subscription expenses
- Visual analytics and insights
- Multiple account management
- Voice input for quick expense entry

## Project Structure

The project architecture:

```
lib/
├── database/       # Database configuration and helpers
├── models/         # Data models
├── repositories/   # Data access layer
├── screens/        # App screens and pages
├── services/       # Business logic services
├── theme/          # App theming
├── utils/          # Utility functions and helpers
├── widgets/        # Reusable UI components
│   ├── common/     # Common UI components
│   ├── expense/    # Expense-related widgets
│   ├── forms/      # Form components
│   ├── charts/     # Data visualization widgets
│   ├── sheets/     # Bottom sheet components
│   ├── dialogs/    # Dialog components
│   └── index.dart  # Main export file
└── main.dart       # App entry point
```

## Widget Organization

Widgets are organized into categories based on their purpose. See the [widgets README](lib/widgets/README.md) for more details.

## Getting Started

1. Clone the repository
2. Install dependencies:
   ```
   flutter pub get
   ```
3. Run the app:
   ```
   flutter run
   ```

## 📦 Building and Distribution

### Quick Commands

```bash
# Debug (run on device/emulator)
flutter run

# Release build for Google Play Console
flutter build appbundle --release    # For Play Store (recommended)
flutter build apk --release          # For direct APK distribution
```

### Documentation

- **[BUILD_README.md](BUILD_README.md)** - Build instructions
