# WellPaw Flutter Architecture Documentation

## Overview

WellPaw is built using **Clean Architecture** principles with a feature-based folder structure for scalability and maintainability.

## Project Structure

```
lib/
├── main.dart                           # Application entry point
├── core/                               # Shared components across features
│   ├── theme/                          # Design system
│   │   ├── app_colors.dart            # Color palette
│   │   ├── app_text_styles.dart       # Typography
│   │   └── app_theme.dart             # Material theme configuration
│   └── widgets/                        # Reusable UI components
│       ├── custom_button.dart         # Standard & outlined buttons
│       ├── custom_text_field.dart     # Text input with validation
│       └── logo_header.dart           # Branded header component
└── features/                           # Feature modules
    └── auth/                          # Authentication feature
        └── presentation/              # UI layer
            └── pages/
                └── login_page.dart    # Login screen

```

## Architecture Layers

### 1. **Core Layer** (`lib/core/`)

Shared resources accessible to all features.

#### Theme System

- **app_colors.dart**: Brand color palette extracted from Figma designs
- **app_text_styles.dart**: Typography system for consistent text styling
- **app_theme.dart**: Material 3 theme configuration

#### Reusable Widgets

- **CustomButton**: Supports both filled and outlined button variants
- **CustomTextField**: Form input with validation, password toggle, and icons
- **LogoHeader**: Branded header with logo and title text

### 2. **Features Layer** (`lib/features/`)

Each feature is isolated with its own presentation, domain, and data layers (following Clean Architecture).

#### Current Features

**Authentication** (`auth/`)

- **presentation/pages/login_page.dart**
  - Login form with email/password validation
  - Forgot password link
  - Register navigation
  - Demo credentials display
  - Form state management with Flutter Form

## Design Patterns

### State Management

Currently using **StatefulWidget** for local form state. As the app grows, consider:

- **Provider** for simple state sharing
- **Riverpod** for advanced dependency injection
- **Bloc** for complex business logic

### Form Validation

- Uses Flutter's built-in `Form` and `TextFormField`
- Custom validators for email and password fields
- Thai language error messages

### Navigation

- Currently using basic `MaterialApp` routing
- **Future**: Implement `go_router` for declarative routing

## Code Conventions

### Import Organization

Use absolute package imports for clarity:

```dart
import 'package:well_paw/core/theme/app_colors.dart';
```

### File Naming

- Snake_case for file names: `login_page.dart`
- Classes use PascalCase: `LoginPage`

### Widget Structure

- Widgets are organized as: Stateless → Stateful → State classes
- Use `const` constructors wherever possible for performance

## Testing Strategy

### Current Tests

- **widget_test.dart**: Smoke test for login page rendering

### Future Testing

- Unit tests for validators
- Widget tests for each custom component
- Integration tests for auth flow

## Design Integration

### Figma → Flutter Workflow

1. Extract design tokens using Figma MCP server
2. Update color palette in `app_colors.dart`
3. Match typography in `app_text_styles.dart`
4. Implement UI components to match Figma designs

### Current Design Implementation

- ✅ Login page matches Figma design
- ✅ Color scheme from brand guidelines
- ✅ Thai language support
- 🔄 Logo placeholder (using Icons.pets temporarily)

## Next Steps

### Immediate Priorities

1. Implement Register page
2. Add Forgot Password flow
3. Integrate with backend API
4. Add navigation routing

### Future Enhancements

1. Add internationalization (i18n) for multi-language support
2. Implement persistent storage (SharedPreferences/Hive)
3. Add biometric authentication
4. Implement proper error handling with custom exceptions

## File Dependencies

```
main.dart
├── app_theme.dart
│   ├── app_colors.dart
│   └── app_text_styles.dart
└── login_page.dart
    ├── app_colors.dart
    ├── app_text_styles.dart
    ├── logo_header.dart
    ├── custom_text_field.dart
    └── custom_button.dart
```

## Running the Application

### Development

```bash
flutter run                    # Run on connected device
flutter run -d chrome          # Run in web browser
flutter run --hot               # Enable hot reload (default)
```

### Testing

```bash
flutter test                   # Run all tests
dart analyze                   # Check for code issues
dart format lib/               # Format code
```

### Build

```bash
flutter build apk              # Android APK
flutter build ios              # iOS build
flutter build web              # Web build
```

## Performance Considerations

- Use `const` constructors to reduce rebuilds
- Keep widget tree shallow where possible
- Extract complex widgets into separate files
- Use `ListView.builder` for long lists (future feature)

## Accessibility

- All interactive elements have proper tap targets (56px minimum)
- Text fields have descriptive labels
- Buttons have clear action text
- Support for Thai language users

---

**Last Updated**: January 12, 2026  
**Flutter Version**: 3.10.7+  
**Dart Version**: 3.10.7+
