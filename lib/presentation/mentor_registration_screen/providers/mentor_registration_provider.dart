import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:turo/presentation/mentor_registration_screen/mentor_step_4_credentials.dart';
import '../../../services/database_service.dart';

class MentorRegistrationProvider extends ChangeNotifier {
  // Step 1: Personal Info
  String _fullName = '';
  String _bio = '';
  DateTime? _birthdate;

  // Address Data
  String _unit = '';
  String _street = '';
  String _province = '';
  String _city = '';
  String _barangay = '';
  String _zipCode = '';

  // Step 2: Institutional Info
  String _institutionName = '';
  String _institutionEmail = '';
  String _jobTitle = '';

  // Step 3: Files
  XFile? _idFile;
  XFile? _selfieFile;

  // Step 4: Expertise
  double? _hourlyRate;
  List<String> _expertise = [];
  List<Credential> _credentials = [];

  // Navigation Logic
  final PageController pageController = PageController();
  int _currentStep = 0;
  int get currentStep => _currentStep;

  // Updated to support 5 Steps (Indices 0, 1, 2, 3, 4)
  void nextPage() {
    if (_currentStep < 4) {
      _currentStep++;
      pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentStep > 0) {
      _currentStep--;
      pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      notifyListeners();
    }
  }

  // Getters
  String get fullName => _fullName;
  String get bio => _bio;
  DateTime? get birthdate => _birthdate;
  String get unit => _unit;
  String get street => _street;
  String get province => _province;
  String get city => _city;
  String get barangay => _barangay;
  String get zipCode => _zipCode;
  String get institutionName => _institutionName;
  String get institutionEmail => _institutionEmail;
  String get jobTitle => _jobTitle;
  XFile? get idFile => _idFile;
  XFile? get selfieFile => _selfieFile;
  double? get hourlyRate => _hourlyRate;
  List<String> get expertise => _expertise;
  List<Credential> get credentials => _credentials;

  // Setters/Updaters
  void updatePersonalInfo({
    required String fullName,
    required String bio,
    required DateTime birthdate,
    required String unit,
    required String street,
    required String province,
    required String city,
    required String barangay,
    required String zipCode,
  }) {
    _fullName = fullName;
    _bio = bio;
    _birthdate = birthdate;
    _unit = unit;
    _street = street;
    _province = province;
    _city = city;
    _barangay = barangay;
    _zipCode = zipCode;
    notifyListeners();
  }

  void updateInstitutionalInfo({
    required String institutionName,
    required String institutionEmail,
    required String jobTitle,
  }) {
    _institutionName = institutionName;
    _institutionEmail = institutionEmail;
    _jobTitle = jobTitle;
    notifyListeners();
  }

  // --- BUG FIX HERE ---
  void updateFiles({XFile? idFile, XFile? selfieFile}) {
    // Only update if a new file is provided; otherwise keep the old one.
    _idFile = idFile ?? _idFile;
    _selfieFile = selfieFile ?? _selfieFile;
    notifyListeners();
  }

  void updateExpertise({
    required double hourlyRate,
    required List<String> expertise,
  }) {
    _hourlyRate = hourlyRate;
    _expertise = expertise;
    notifyListeners();
  }

  void addCredential(Credential credential) {
    _credentials.add(credential);
    notifyListeners();
  }

  void removeCredential(int index) {
    _credentials.removeAt(index);
    notifyListeners();
  }

  // Validation Getters
  bool get isStep1Valid =>
      _fullName.isNotEmpty &&
      _bio.isNotEmpty &&
      _birthdate != null &&
      _street.isNotEmpty &&
      _province.isNotEmpty &&
      _city.isNotEmpty &&
      _barangay.isNotEmpty;

  bool get isStep2Valid =>
      _institutionName.isNotEmpty &&
      _institutionEmail.isNotEmpty &&
      _jobTitle.isNotEmpty;

  bool get isStep3Valid => _idFile != null && _selfieFile != null;

  bool get isStep4Valid =>
      _hourlyRate != null && _hourlyRate! > 0 && _expertise.isNotEmpty;

  // Submission Logic
  Future<void> submitApplication(String uid, DatabaseService dbService) async {
    // Layer 1 (Public): users/{uid}
    await dbService.updateUserPublic(
      uid: uid,
      bio: _bio,
      isVerified: false,
      roles: ['mentor'],
      mentorProfile: {'rate': _hourlyRate, 'expertise': _expertise},
    );

    // Layer 2 (Private): user_details/{uid}
    await dbService.updateUserDetails(
      uid: uid,
      fullName: _fullName,
      birthdate: _birthdate!,
      address: '$_unit, $_street, $_barangay, $_city, $_province, $_zipCode',
    );

    // Layer 3 (Admin): mentor_verifications/{uid}
    await dbService.createMentorVerification(
      uid: uid,
      institutionName: _institutionName,
      jobTitle: _jobTitle,
      idFile: _idFile,
      selfieFile: _selfieFile,
    );
  }
}
