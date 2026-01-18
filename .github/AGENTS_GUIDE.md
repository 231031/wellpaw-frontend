---
title: WellPaw Flutter Agent Selection Guide
description: Quick reference for selecting the right AI agent based on your task and development needs
---

# WellPaw Flutter Agents Guide

This guide helps you select the right AI agent for your Flutter Android/iOS development tasks. Each agent specializes in different aspects of the development lifecycle.

## Agent Overview

| Agent                  | Specialty                            | Best For                                                  |
| ---------------------- | ------------------------------------ | --------------------------------------------------------- |
| **frontend-developer** | UI implementation & component design | Building screens, widgets, and UI features                |
| **flutter-expert**     | Architecture & optimization          | App structure, performance, and cross-platform excellence |
| **architect-reviewer** | Design validation & scalability      | Reviewing architecture and making strategic decisions     |
| **code-reviewer**      | Code quality & security              | Peer code review and quality assurance                    |
| **qa-test-automator**  | Testing & quality metrics            | Test strategy, automation, and defect management          |

---

## Decision Matrix: Which Agent to Use?

### 🎨 UI/UX Development

**Primary: frontend-developer** | Secondary: flutter-expert

✅ **Use frontend-developer when:**

- Building new screens or pages
- Creating reusable widgets/components
- Implementing layouts (responsive, adaptive, Material 3/Cupertino)
- Adding animations and interactions
- Handling state integration for UI features
- Working with Material Design or iOS HIG

**Example prompts:**

- "Create a login screen with email/password fields, validation, and error messages"
- "Build a reusable card widget that adapts to different screen sizes"
- "Implement a bottom sheet with animations and drag-to-dismiss"

---

### 🏗️ Architecture & App Structure

**Primary: flutter-expert** | Secondary: architect-reviewer

✅ **Use flutter-expert when:**

- Setting up the app from scratch or restructuring
- Choosing/implementing state management (Riverpod/Bloc/Provider)
- Designing navigation flow (go_router, Navigator 2.0)
- Planning feature modularization and layer separation
- Implementing Clean Architecture
- Optimizing performance across the app

✅ **Use architect-reviewer when:**

- Reviewing major architectural decisions
- Validating feature boundaries and dependencies
- Assessing scalability and technical debt
- Planning migrations (e.g., switching state managers)
- Evaluating third-party plugins/packages

**Example prompts:**

- "Set up the app with Clean Architecture, Riverpod, and go_router"
- "How should I structure offline sync with Isar database?"
- "Review our proposed feature modularization for scalability"

---

### 🔍 Code Quality & Security Review

**Primary: code-reviewer** | Secondary: architect-reviewer

✅ **Use code-reviewer when:**

- Need code review (PR feedback, design patterns, best practices)
- Checking for security vulnerabilities (storage, permissions, API)
- Optimizing performance (widget rebuilds, memory, frames)
- Enforcing Effective Dart and Flutter style guidelines
- Identifying technical debt and refactoring opportunities
- Validating test coverage and quality

**Example prompts:**

- "Review this code for security issues and best practices"
- "Check this widget for performance problems (frame budget)"
- "What are the code smells in this repository pattern?"

---

### 🧪 Testing & Quality Assurance

**Primary: qa-test-automator** | Secondary: flutter-expert

✅ **Use qa-test-automator when:**

- Creating a test strategy or test plan
- Writing widget/unit/integration tests
- Setting up test automation and CI/CD integration
- Implementing test factories and mock data
- Tracking quality metrics and defects
- Preparing for device testing or UAT
- Configuring Patrol/Maestro for E2E testing

**Example prompts:**

- "Create a comprehensive test strategy for our app"
- "Help me write widget tests for this screen"
- "Set up automated integration tests with Patrol"
- "Configure CI/CD pipeline for automated testing (Codemagic)"

---

### 🚀 Performance & Optimization

**Primary: flutter-expert** | Secondary: code-reviewer

✅ **Use flutter-expert when:**

- App startup is slow (cold/warm start)
- Need to reduce jank or frame drops
- Optimizing bundle size
- Improving memory usage
- Scaling lists efficiently
- Implementing image caching
- Battery drain analysis

**Example prompts:**

- "Help me optimize startup time from 2.5s to <1.5s"
- "How do I implement efficient lazy loading for long lists?"
- "Analyze why this screen is dropping frames"

---

### 📱 Platform Integration (Android/iOS)

**Primary: flutter-expert** | Secondary: frontend-developer

✅ **Use flutter-expert when:**

- Using platform channels (Method/Event channels, Pigeon)
- Integrating native modules (camera, location, biometrics)
- Handling Android/iOS specific configurations
- Managing push notifications (FCM/APNs)
- Implementing deep linking
- Platform-specific UI/UX patterns (Material vs Cupertino)

**Example prompts:**

- "Set up biometric authentication with platform channels"
- "How do I implement deep linking for Android and iOS?"
- "Configure push notifications with FCM and APNs"

---

### 🔐 Security & Privacy

**Primary: code-reviewer** | Secondary: architect-reviewer

✅ **Use code-reviewer when:**

- Reviewing security in code (input validation, storage, encryption)
- Checking for vulnerabilities in dependencies
- Verifying permission handling

✅ **Use architect-reviewer when:**

- Designing security architecture
- Planning authentication/authorization flows
- Evaluating secure storage strategies

**Example prompts:**

- "Review this code for security vulnerabilities"
- "How should we securely store API tokens?"
- "What are the privacy concerns with location tracking?"

---

### 📊 Project Setup & Configuration

**Primary: flutter-expert** | Secondary: architect-reviewer

✅ **Use flutter-expert when:**

- Creating flavors/build variants (dev, staging, prod)
- Setting up environment variables (.env)
- Configuring build signing (iOS certificates, Android keystores)
- Managing dependencies and pubspec.yaml
- Setting up linting and code analysis

**Example prompts:**

- "Set up build flavors for dev, staging, and production"
- "Configure code signing for iOS and Android releases"
- "Help me optimize pubspec.yaml and lock file"

---

## Quick Task Reference

| Task                    | Agent              | Context                                            |
| ----------------------- | ------------------ | -------------------------------------------------- |
| Build a new screen      | frontend-developer | "Create a user profile screen with edit mode"      |
| Set up app architecture | flutter-expert     | "Set up Clean Architecture with Riverpod"          |
| Review my app structure | architect-reviewer | "Review our feature-based modularization"          |
| Review code quality     | code-reviewer      | "Review this code for issues and best practices"   |
| Write tests             | qa-test-automator  | "Write widget tests for the login screen"          |
| Optimize performance    | flutter-expert     | "App startup is slow, help optimize"               |
| Integrate native camera | flutter-expert     | "Set up camera integration with platform channels" |
| Check security          | code-reviewer      | "Review for security vulnerabilities"              |

---

## How to Invoke Agents

### Standard Format

```
@agent-name
Your task or question here, with as much detail as helpful.
```

### Examples

**Frontend Development:**

```
@frontend-developer
Build a settings screen with theme toggle, language selection,
and logout button. Should be responsive and follow Material 3 design.
Include error handling for logout.
```

**Architecture:**

```
@flutter-expert
Set up the app with Clean Architecture, Riverpod for state management,
and go_router for navigation. Create the folder structure and show
example feature implementation.
```

**Code Review:**

```
@code-reviewer
Review this repository pattern implementation for correctness,
security, and performance. Check for any code smells.
```

**Testing:**

```
@qa-test-automator
Create a comprehensive test strategy for our authentication flow.
Include unit tests, widget tests, and integration tests.
```

**Architecture Review:**

```
@architect-reviewer
Review our proposed modularization strategy. We want to split
the app into features. Is this scalable for 20+ screens?
```

---

## Agent Context Requests

Each agent can initialize with a context request to your context-manager. This helps the agent understand your project better.

### frontend-developer

```json
{
  "requesting_agent": "frontend-developer",
  "request_type": "get_project_context",
  "payload": {
    "query": "Flutter mobile context needed: current widget architecture, state management, theming/design system, navigation patterns, platform configurations (Android/iOS), testing setup, and build/deployment pipeline."
  }
}
```

### flutter-expert

```json
{
  "requesting_agent": "flutter-expert",
  "request_type": "get_flutter_context",
  "payload": {
    "query": "Flutter context needed: target platforms, app type, state management preference, native features required, and deployment strategy."
  }
}
```

### architect-reviewer

```json
{
  "requesting_agent": "architect-reviewer",
  "request_type": "get_architecture_context",
  "payload": {
    "query": "Flutter architecture context needed: app purpose, scale requirements, constraints, team structure, technology preferences, state management, navigation, and evolution plans."
  }
}
```

### code-reviewer

```json
{
  "requesting_agent": "code-reviewer",
  "request_type": "get_review_context",
  "payload": {
    "query": "Flutter code review context: coding standards, security requirements, performance criteria, team conventions, review scope, and target platforms."
  }
}
```

### qa-test-automator

```json
{
  "requesting_agent": "qa-test-automator",
  "request_type": "get_qa_context",
  "payload": {
    "query": "Flutter QA context needed: app type, quality requirements, current coverage, defect history, device matrix, CI/CD setup, and release timeline."
  }
}
```

---

## Best Practices

✅ **Do:**

- Be specific about what you're trying to achieve
- Include relevant context (code snippets, error messages, current behavior)
- Ask follow-up questions if you need clarification
- Let agents leverage their specialties without overlap
- Start with architecture questions before diving into code

❌ **Don't:**

- Ask multiple agents the same question (pick the best fit)
- Skip providing context (agents work better with details)
- Mix concerns (choose the agent that best matches your primary need)

---

## When Agents Collaborate

Some tasks benefit from multiple agents working together:

- **UI + Architecture**: frontend-developer for screens, flutter-expert for state integration
- **Code + Architecture**: code-reviewer for quality, architect-reviewer for design validation
- **Testing + QA**: qa-test-automator for execution, code-reviewer for test quality
- **Security**: code-reviewer for implementation, architect-reviewer for design

---

## Getting Started

1. **First time?** Start with `flutter-expert` to set up your app structure
2. **Building features?** Use `frontend-developer` for UI and `qa-test-automator` for tests
3. **Need review?** Use `code-reviewer` for code and `architect-reviewer` for design
4. **Stuck?** Ask the most relevant agent and they'll guide you

---

## Tips & Tricks

- Save time by asking one agent to "set up the foundation" (architecture, core patterns)
- Use agents for code review PRs to catch issues early
- Combine agents: build with `frontend-developer`, test with `qa-test-automator`, review with `code-reviewer`
- Reference agent output in future prompts: "Using the structure from flutter-expert, implement..."

---

## Questions?

Each agent's specification file in `.claude/agents/` contains detailed information about capabilities and workflows.
