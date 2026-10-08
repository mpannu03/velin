# Contributing to Velin

Thank you for your interest in contributing to Velin.

Velin is an open-source PDF application built with Flutter. Contributions are welcome, whether they are bug fixes, new features, improvements to the user experience, documentation, tests, or other improvements.

Before making a significant change, please consider opening an issue first to discuss the idea. This helps keep contributions aligned with the direction of the project.

## Getting Started

### Requirements

You will need:

* Flutter
* Dart
* A supported desktop development environment

Check that Flutter is installed correctly:

```
flutter doctor
```

Clone the repository:

```
git clone https://github.com/mpannu03/velin.git
cd velin
```

Install dependencies:

```
flutter pub get
```

Run the application:

```
flutter run
```

## Development

Before submitting a change, make sure the project builds and the relevant tests pass.

Run static analysis:

```
flutter analyze
```

Run tests:

```
flutter test
```

Format the code:

```
dart format .
```

Please avoid committing generated files or unrelated formatting changes.

## Architecture

Velin follows a feature-oriented architecture with a clear separation between the application UI, core contracts, data access, services, and implementation details.

The main areas of the project are:

```
lib/
├── app/
├── core/
├── data/
├── engine/
├── features/
├── l10n/
├── services/
└── shared/
```

### `app`

Contains application-level concerns such as:

* Application configuration
* Routing
* Theme
* Application effects
* Global application behavior

### `core`

Contains contracts and domain concepts that should not depend on concrete implementations.

Examples include:

* Document engine contracts
* Page selection
* Result handling
* Tasks
* File-related abstractions

Core code should remain independent of UI and concrete implementation details wherever practical.

### `data`

Contains data access and persistence-related functionality.

This includes code responsible for storing, retrieving, and managing application data.

Data-layer implementations should remain separate from feature UI and should expose appropriate abstractions when consumed by other parts of the application.

### `engine`

Contains concrete implementations of document and PDF processing functionality.

This includes integrations with PDF/document processing libraries and implementations of contracts defined in `core`.

PDF processing should remain separated from feature UI code.

### `services`

Contains application services that coordinate reusable application-level behavior which does not belong directly to a feature, data layer, or engine.

Services may coordinate multiple dependencies or provide functionality shared across different features.

Avoid putting feature-specific business logic into `services`.

### `features`

Contains user-facing application features.

Features generally contain their own:

* Page
* BLoC
* View
* ViewModel
* Widgets
* Layouts
* Models

The exact structure may vary depending on the feature, but feature code should remain cohesive and avoid unnecessary dependencies on unrelated features.

Pages generally own the feature-level BLoC, dependency injection, and orchestration required by that page.

Views compose layouts and feature UI, while widgets should remain as dumb and reusable as practical.

### `l10n`

Contains localization resources and generated localization code.

User-facing strings should be defined through the project's ARB localization files rather than hard-coded throughout the UI.

### `shared`

Contains reusable UI components, extensions, and utilities that are appropriate for use across multiple features.

Avoid placing feature-specific code in `shared`.

## State Management

Velin uses BLoC for feature-level state management.

Prefer:

* Explicit events and states
* Sealed classes where appropriate
* Small, focused BLoCs
* Immutable state
* Manual `copyWith` implementations where needed

Avoid introducing another state-management framework unless there is a strong architectural reason and the change has been discussed beforehand.

## Dependency Injection

Velin uses `get_it` for dependency injection.

Dependencies should be registered through the existing application dependency-injection setup rather than instantiated directly throughout the UI.

Pages are responsible for creating the feature-level orchestration needed by that page, while reusable services, data components, and engines should be provided through dependency injection.

## Result Handling

Velin uses the `Result` abstraction for operations that can succeed or fail.

When an operation crosses a layer or represents an expected failure case, prefer returning a `Result` rather than allowing exceptions to propagate through feature boundaries.

Follow the existing `core/result` implementation and conventions when adding new operations.

## PDF and Document Processing

PDF functionality is intentionally separated from the UI.

Features should depend on the appropriate core contract rather than directly coupling application UI to a concrete PDF implementation whenever a contract already exists.

Concrete PDF processing implementations belong under `engine/`.

This separation allows PDF libraries and implementations to evolve without requiring the feature layer to know their internal details.

## UI Guidelines

Velin is designed as a responsive application with desktop and mobile as first-class platforms.

When contributing UI:

* Design for both desktop and mobile experiences.
* Prefer existing Velin widgets and components where available.
* Follow the existing Material 3 design system.
* Keep the interface clean, practical, and consistent across platforms.
* Follow the existing responsive layout patterns.
* Consider platform-appropriate interaction patterns, including mouse, keyboard, touch, and gestures.
* Ensure interactive controls have appropriate tooltips, labels, or accessible alternatives.
* Use appropriate touch targets and spacing on smaller screens.
* Avoid unnecessary visual decoration.
* Avoid introducing platform-specific behavior unless it is necessary for a better platform experience.

When a reusable UI pattern appears more than once, consider whether it belongs in `shared/`.

## Localization

User-facing strings should be localized.

Do not hard-code user-visible application text directly in widgets when the text belongs to the application UI.

Add new strings to the appropriate ARB localization files and use the generated localization classes through the existing localization setup.

## Testing

New functionality should include appropriate tests.

Depending on the change, this may include:

* Unit tests for core logic
* BLoC tests for feature state transitions
* Widget tests for UI behavior
* Regression tests for fixed bugs

Tests should focus on behavior rather than implementation details.

When fixing a bug, a regression test is encouraged whenever practical.

## Code Style

Follow the existing Dart and Flutter conventions used throughout the repository.

In particular:

* Run `dart format .` before committing.
* Keep imports organized and consistent with the existing codebase.
* Prefer small, focused classes and methods.
* Avoid unnecessary abstractions.
* Avoid introducing dependencies without a clear benefit.
* Keep public APIs intentional and minimal.
* Prefer readable code over clever code.

Velin intentionally avoids unnecessary code generation and abstraction layers. New dependencies or architectural patterns should have a clear reason to exist.

## Pull Requests

Before opening a pull request:

1. Make sure your branch is based on the current `main` branch.
2. Run `dart format .`.
3. Run `flutter analyze`.
4. Run `flutter test`.
5. Verify the application manually when the change affects UI or runtime behavior.
6. Keep the pull request focused on one logical change.

A good pull request should explain:

* What changed
* Why the change was needed
* How it was implemented
* How it was tested

For UI changes, screenshots or screen recordings are appreciated.

Please avoid combining unrelated refactoring, formatting changes, or feature work into the same pull request.

## Commit Messages

Keep commit messages concise and descriptive.

For example:

```
Add merge PDF tool
Fix page selection for odd pages
Improve reader tab layout
Add dictionary lookup
```

There is no requirement to follow a particular commit-message framework, but messages should clearly describe the change.

## Reporting Bugs

Use the appropriate GitHub issue template when reporting a bug.

Please include:

* Velin version
* Operating system
* Steps to reproduce
* Expected behavior
* Actual behavior
* Relevant logs or screenshots

The more information provided, the easier it is to reproduce and fix the problem.

## Feature Requests

Feature ideas and improvements are welcome.

Before implementing a significant new feature, open an issue to discuss:

* The problem being solved
* The proposed behavior
* Why the feature would be useful
* Any relevant design or technical considerations

This helps avoid spending time implementing something that may not fit Velin's direction.

## Documentation

Documentation improvements are welcome.

If you find something that is missing, incorrect, or unclear, please open a documentation issue or submit a pull request with the proposed improvement.

## Code of Conduct

By participating in the Velin project, you agree to follow the project's [Code of Conduct](CODE_OF_CONDUCT.md).

## Security

Please do not report security vulnerabilities through public GitHub issues.

See the [Security Policy](SECURITY.md) for information about reporting security vulnerabilities privately.

## License

By contributing to Velin, you agree that your contributions will be licensed under the project's existing license.

See the [LICENSE](LICENSE) file for the complete license terms.

Thank you for contributing to Velin!
