# WellPaw Flutter - AI Agent Instructions

## Project Overview

**WellPaw** is a Flutter mobile application (iOS/Android) with Figma-driven design system integration via Model Context Protocol (MCP). The project is in early development with a starter template structure.

## Architecture & Key Components

### Flutter Application (`lib/`)

- **Entry Point**: [lib/main.dart](lib/main.dart) - Standard Flutter counter demo (starter template)
- **Current State**: Single-file app with no custom architecture yet
- **Expected Pattern**: Will expand into feature-based structure with separate UI, business logic, and data layers

### Figma MCP Server (`mcp/figma-server/`)

- **Purpose**: Connects Claude/AI agents to Figma for design-to-code workflows
- **Implementation**: Node.js MCP server using `@modelcontextprotocol/sdk`
- **Key File**: [mcp/figma-server/server.js](mcp/figma-server/server.js) - Exposes 6 Figma API tools
- **Environment**: Requires `FIGMA_API_KEY` and `FIGMA_FILE_KEY` in `.env` (never commit!)

### Available Figma Tools

1. `get_file_nodes` - Retrieve specific design elements
2. `get_file_components` - Extract all components from design system
3. `get_component_sets` - Get component variants and properties
4. `get_file_styles` - Extract design tokens (colors, typography, effects)
5. `export_component` - Export as SVG/PNG/PDF
6. `get_page_hierarchy` - Navigate page structure

## Critical Workflows

### Running the Flutter App

```bash
flutter run                    # Start on connected device/emulator
flutter run -d chrome          # Run in web browser
flutter run --hot               # Enable hot reload (default)
```

### Figma MCP Server Setup

```bash
cd mcp/figma-server
npm install
# Create .env with FIGMA_API_KEY and FIGMA_FILE_KEY
npm start                       # Runs on stdio for MCP communication
```

**Getting Figma Credentials**:

- Token: https://www.figma.com/settings/account → "Personal access tokens"
- File Key: Extract from Figma URL: `figma.com/file/{FILE_KEY}/...`

### Testing

```bash
flutter test                    # Run all widget tests
flutter test test/widget_test.dart  # Run specific test
```

### Code Quality

```bash
flutter analyze                 # Lint checks via flutter_lints package
dart format lib/               # Format Dart code (DO NOT use manual formatting)
```

## Project-Specific Conventions

### Dart/Flutter Standards

- **SDK Version**: Dart ^3.10.7 (bleeding edge)
- **Linting**: Uses `package:flutter_lints/flutter.yaml` with default rules
- **Formatting**: Always use `dart format` command - never format manually
- **Package Naming**: Snake_case (`well_paw`)
- **Testing**: Widget tests use `WidgetTester` with `pumpWidget()` pattern

### File Organization (Expected Growth)

```
lib/
  main.dart           # App entry point
  /screens            # Page-level widgets (to be added)
  /widgets            # Reusable components (to be added)
  /theme              # Design tokens from Figma (to be added)
  /services           # API clients, business logic (to be added)
```

### Figma Integration Patterns

When implementing designs:

1. Use Figma MCP tools to extract design tokens first
2. Create `lib/theme/` with Material 3 ColorScheme from Figma colors
3. Map Figma components to Flutter widget equivalents
4. Verify implementation matches Figma via `get_page_hierarchy`

**Example Workflow**:

```
Use get_file_styles to extract all color tokens from Figma.
Then create lib/theme/app_colors.dart with Material ColorScheme
mapping Figma color names to Flutter colors.
```

## Integration Points & Dependencies

### Flutter Dependencies ([pubspec.yaml](pubspec.yaml))

- `cupertino_icons: ^1.0.8` - iOS-style icons
- No state management library yet (consider when needed: Provider, Riverpod, Bloc)
- No networking library yet (consider when needed: http, dio)

### MCP Server Dependencies ([mcp/figma-server/package.json](mcp/figma-server/package.json))

- `@modelcontextprotocol/sdk` - MCP protocol implementation
- `axios` - Figma REST API calls
- `dotenv` - Environment variable management

### Cross-Component Communication

- **Figma → Flutter**: MCP tools extract design data, AI generates Flutter code
- **No backend integration yet** - API layer to be defined

## Environment & Configuration

### Required Environment Variables

- **Figma MCP**: `mcp/figma-server/.env` with `FIGMA_API_KEY`, `FIGMA_FILE_KEY`
- **Flutter**: No environment-specific config yet

### Ignored Files (.gitignore)

- `.env` files (Figma secrets)
- Flutter build artifacts (`/build/`, `.dart_tool/`)
- Platform-specific: `/android/app/debug`, `/ios/Flutter/.last_build_id`

## Key Gotchas

### Figma MCP Server

- **Never commit `.env`** - Contains sensitive API keys
- **Rate Limiting**: Figma API allows 120 requests/minute
- **File Key Validation**: Check access permissions if "File not found" errors occur
- **MCP Communication**: Server uses stdio transport, not HTTP

### Flutter Development

- **Hot Reload vs Hot Restart**: Hot reload preserves state; use hot restart for structural changes
- **Material vs Cupertino**: Project uses Material widgets (not iOS-specific Cupertino)
- **Testing**: Widget tests require `await tester.pumpWidget()` before assertions

### Common Commands

```bash
flutter pub get                 # Install dependencies after pubspec.yaml changes
flutter clean                   # Clear build cache if encountering weird errors
flutter doctor                  # Diagnose Flutter installation issues
```

## What This Project Is NOT (Yet)

- No custom state management (still using StatefulWidget)
- No backend API integration
- No navigation/routing beyond single screen
- No internationalization (i18n)
- No authentication/authorization
- No persistent storage (database/cache)

Focus on implementing core features first, then add architectural patterns as complexity grows.
