# AGENTS.md

## Purpose

This document defines the development standards, architecture guidelines, and workflow expectations for all contributors and AI agents working on this Flutter project.

All changes must follow these guidelines unless explicitly instructed otherwise.

---

# Technology Stack

* Flutter (latest stable)
* Dart (latest stable)
* Platform Targets:

  * Android (main Focus)
  * Web (for devlopment)


---

# General Principles

## Code Quality

* Write clean, maintainable, production-ready code.
* Prioritize readability over cleverness.
* Avoid unnecessary abstractions.
* Follow SOLID principles where appropriate.
* Prefer composition over inheritance.
* Keep widgets small and focused.

## Naming

### Classes

Use PascalCase.

Examples:

```dart
UserProfileScreen
SettingsRepository
ThemeController
```

### Variables & Methods

Use camelCase.

Examples:

```dart
loadUserProfile()
isDarkModeEnabled
currentTheme
```

### Constants

Use lowerCamelCase with `const`.

```dart
const defaultAnimationDuration = Duration(milliseconds: 300);
```

Avoid screaming snake case.


---

# State Management

Rules:

* Keep business logic outside widgets.
* Widgets should primarily render UI.
* Use immutable state.
* Avoid global mutable state.

---

# Widget Guidelines

## Widget Size

Target:

* < 200 lines per widget
* Extract reusable widgets early

## Build Methods

Avoid large build methods.

Bad:

```dart
Widget build(BuildContext context) {
  // 500 lines
}
```

Good:

```dart
Widget build(BuildContext context) {
  return Column(
    children: [
      Header(),
      Content(),
      Footer(),
    ],
  );
}
```

---

# Styling

## Colors

Never hardcode colors directly in widgets.

Bad:

```dart
color: Colors.red
```

Good:

```dart
color: context.colorScheme.error
```

Use:

* ColorScheme
* Theme Extensions

---

# Responsiveness

All screens must support:

* Mobile
* Tablet
* Desktop
* Web

Avoid fixed pixel sizes when possible.

Use:

* LayoutBuilder
* MediaQuery
* Adaptive layouts

---

# Performance

Avoid:

* Unnecessary rebuilds
* Nested scroll views
* Expensive calculations in build()

Prefer:

* const constructors
* Memoization where needed
* Lazy loading

Always consider rebuild behavior.

---

# Async Code

Prefer async/await.

Avoid nested Futures.

Good:

```dart
final user = await repository.loadUser();
```

Handle errors explicitly.

```dart
try {
  ...
} catch (e, stackTrace) {
  ...
}
```

Never silently swallow exceptions.

---

# Error Handling

All failures should:

* Be logged
* Show user-friendly messages
* Preserve debugging information

Avoid:

```dart
catch (_) {}
```

---

# Logging

Use a centralized logging solution.

Example:

```dart
SimpleLogging.i(...)
SimpleLogging.w(...)
SimpleLogging.e(...)
```

Do not use `print()` in production code.

---

# Testing

Required for:

* Business logic
* Services
* Repositories

Preferred coverage:

* > 80% for domain logic

---

# Documentation

Public APIs must be documented.

Example:

```dart
/// Loads the currently authenticated user.
Future<User> loadUser();
```

Complex business logic requires comments.

Do not comment obvious code.

---


# Localization

All user-facing text must be localized.

Never hardcode strings directly in widgets.

Bad:

```dart
Text("Save")
```

Good:

```dart
Text(LocaleKeys.commons_save.tr())
```

---

# AI Agent Instructions

When modifying code:

1. Respect existing architecture.
2. Do not introduce new dependencies unless necessary.
3. Update tests when behavior changes.
4. Keep files focused and maintainable.
5. Prefer consistency over personal preference.
6. Never remove existing functionality without explicit instruction.
7. Follow Flutter and Dart best practices.
8. Maintain backward compatibility when possible.

When generating code:

* Produce production-ready implementations.
* Avoid placeholders and TODOs unless requested.
* Include error handling.
* Include null-safety.
* Follow effective Dart guidelines.

---

# Definition of Done

A task is complete when:

* Code compiles successfully.
* Tests pass.
* Static analysis passes.
* Formatting is applied.
* Documentation is updated if needed.
* No unnecessary warnings remain.
* Solution follows this AGENTS.md.

```
```
