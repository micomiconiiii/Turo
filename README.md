# turo_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Onboarding architecture and data flow

The mentee onboarding flow is implemented as a multi-step UI with a shared bottom navigation and a single state source of truth using Provider.

- Steps and UI
	- Each step is a stateful widget under `lib/mentee-onboarding/` (e.g., `personal_info_step.dart`, `interests_step.dart`, `goals_step.dart`, `duration_step.dart`, `budget_step.dart`, and `confirmation_step.dart`).
	- The parent page (`lib/features/mentee_onboarding/pages/mentee_onboarding_page.dart`) orchestrates step transitions and reads step values through lightweight getters.
	- Buttons are standardized for consistent sizing and hierarchy: a primary full-width action (Next/Finish) and a secondary Back below it.

- State management
	- `MenteeOnboardingProvider` (`lib/mentee-onboarding/provider_storage/storage.dart`) holds all collected values. Setters immediately `notifyListeners()` so dependent widgets rebuild.
	- Personal information exposes a structured `addressDetails` map (unit/building, street, barangay, city/municipality, province, zip). For convenience, a human-readable one-line `address` is also composed and kept in sync.

- Cascading address selection
	- Province → City/Municipality → Barangay are populated from relational JSON assets under `assets/locations/`:
		- `province.json`: `[ { province_id, province_name } ]`
		- `municipality.json`: `[ { municipality_id, province_id, municipality_name } ]`
		- `barangay.json`: `[ { barangay_id, municipality_id, barangay_name } ]`
	- `personal_info_step.dart` loads these assets and filters lists in-memory by the appropriate foreign keys to drive the cascades.
	- Dropdowns use `initialValue` plus a `ValueKey` to ensure clean resets without deprecated APIs.

This design keeps input validation local to each step, centralizes persistence in the provider, and cleanly separates view, state, and data assets.
