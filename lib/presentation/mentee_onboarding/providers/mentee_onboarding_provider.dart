import 'dart:io';
import 'package:flutter/foundation.dart';

/// Provides read/write access to the data captured throughout the mentee
/// onboarding flow.
class MenteeOnboardingProvider extends ChangeNotifier {
  // Personal info
  String? _fullName;
  String? _birthMonth;
  String? _birthDay;
  String? _birthYear;
  String? _bio;
  String? _address; // Backward-compatible one-line address for simple UIs
  Map<String, String?> _addressDetails = const {};
  // Profile media - temp storage for selected image (before upload)
  File? _profilePictureFile; // Mobile/desktop
  Uint8List? _profilePictureBytes; // Web
  String? _profilePictureUrl; // Remote download URL for uploaded profile image

  // Selection-based steps
  final Set<String> _selectedInterests = {};
  final Set<String> _selectedGoals = {};

  // Duration and budget
  String? _selectedDuration;
  String? _minBudget;
  String? _maxBudget;

  // Getters expose immutable views or copies where appropriate
  String? get fullName => _fullName;
  String? get birthMonth => _birthMonth;
  String? get birthDay => _birthDay;
  String? get birthYear => _birthYear;
  String? get bio => _bio;
  String? get address => _address;
  Map<String, String?> get addressDetails => Map.unmodifiable(_addressDetails);
  File? get profilePictureFile => _profilePictureFile;
  Uint8List? get profilePictureBytes => _profilePictureBytes;
  String? get profilePictureUrl => _profilePictureUrl;

  Set<String> get selectedInterests => Set.unmodifiable(_selectedInterests);
  Set<String> get selectedGoals => Set.unmodifiable(_selectedGoals);

  String? get selectedDuration => _selectedDuration;
  String? get minBudget => _minBudget;
  String? get maxBudget => _maxBudget;

  /// Setters update local state and notify listeners to rebuild dependents.
  void setFullName(String value) {
    _fullName = value;
    notifyListeners();
  }

  void setBirthMonth(String? value) {
    _birthMonth = value;
    notifyListeners();
  }

  void setBirthDay(String? value) {
    _birthDay = value;
    notifyListeners();
  }

  void setBirthYear(String? value) {
    _birthYear = value;
    notifyListeners();
  }

  void setBio(String? value) {
    _bio = value;
    notifyListeners();
  }

  void setAddress(String? value) {
    _address = value;
    notifyListeners();
  }

  /// Set or replace the profile picture download URL (nullable allowed externally
  /// by passing an empty string if you want to clear it; here we store empty as null).
  void setProfilePictureUrl(String url) {
    final trimmed = url.trim();
    _profilePictureUrl = trimmed.isEmpty ? null : trimmed;
    notifyListeners();
  }

  /// Set structured address details and also compose a single-line address
  /// string for backward compatibility with existing UI that displays `address`.
  void setAddressDetails(Map<String, String?> values) {
    _addressDetails = Map<String, String?>.from(values);

    // Build a friendly one-liner address from the non-empty parts
    final parts = <String>[];
    void add(String? v) {
      final s = (v ?? '').trim();
      if (s.isNotEmpty) parts.add(s);
    }

    add(values['unitBldg']);
    add(values['street']);
    add(values['barangay']);
    add(values['cityMunicipality']);
    add(values['province']);
    add(values['zip']);
    _address = parts.join(', ');

    notifyListeners();
  }

  /// Replace the current interest selections.
  void setSelectedInterests(Set<String> values) {
    _selectedInterests
      ..clear()
      ..addAll(values);
    notifyListeners();
  }

  /// Replace the current goal selections.
  void setSelectedGoals(Set<String> values) {
    _selectedGoals
      ..clear()
      ..addAll(values);
    notifyListeners();
  }

  /// Set the selected duration label (nullable).
  void setSelectedDuration(String? value) {
    _selectedDuration = value;
    notifyListeners();
  }

  /// Set the minimum budget string (nullable).
  void setMinBudget(String? value) {
    _minBudget = value;
    notifyListeners();
  }

  /// Set the maximum budget string (nullable).
  void setMaxBudget(String? value) {
    _maxBudget = value;
    notifyListeners();
  }

  /// Store the selected profile picture (before upload).
  /// For mobile/desktop, pass the File. For web, pass null for file and the bytes.
  void setProfilePictureData({File? file, Uint8List? bytes}) {
    _profilePictureFile = file;
    _profilePictureBytes = bytes;
    notifyListeners();
  }

  /// Clear the temporary profile picture data (useful for "Remove" button).
  void clearProfilePictureData() {
    _profilePictureFile = null;
    _profilePictureBytes = null;
    notifyListeners();
  }
}
