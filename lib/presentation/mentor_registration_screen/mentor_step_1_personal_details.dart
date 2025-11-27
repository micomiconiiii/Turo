import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'providers/mentor_registration_provider.dart';

class MentorStep1PersonalDetails extends StatefulWidget {
  const MentorStep1PersonalDetails({super.key});

  @override
  State<MentorStep1PersonalDetails> createState() =>
      _MentorStep1PersonalDetailsState();
}

class _MentorStep1PersonalDetailsState
    extends State<MentorStep1PersonalDetails> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _unitBldgController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  DateTime? _selectedBirthDate;

  // Cascading dropdown state
  String? _selectedProvince;
  int? _selectedProvinceId;
  String? _selectedCityMunicipality;
  int? _selectedMunicipalityId;
  String? _selectedBarangay;

  // Location data lists
  List<Map<String, dynamic>> _provincesData = [];
  List<Map<String, dynamic>> _municipalitiesData = [];
  List<Map<String, dynamic>> _barangaysData = [];
  List<String> _provinces = [];
  List<String> _citiesMunicipalities = [];
  List<String> _barangays = [];

  @override
  void initState() {
    super.initState();
    // 1. Load data from Provider
    final provider = context.read<MentorRegistrationProvider>();
    _fullNameController.text = provider.fullName;
    _bioController.text = provider.bio;
    _selectedBirthDate = provider.birthdate;
    _unitBldgController.text = provider.unit;
    _streetController.text = provider.street;
    _zipCodeController.text = provider.zipCode;

    // Load saved dropdown values (if any)
    if (provider.province.isNotEmpty) _selectedProvince = provider.province;
    if (provider.city.isNotEmpty) _selectedCityMunicipality = provider.city;
    if (provider.barangay.isNotEmpty) _selectedBarangay = provider.barangay;

    // 2. Load JSONs and restore lists
    _loadLocationData();
  }

  Future<void> _loadLocationData() async {
    try {
      final String provincesJson = await rootBundle.loadString(
        'assets/locations/province.json',
      );
      final String municipalitiesJson = await rootBundle.loadString(
        'assets/locations/municipality.json',
      );
      final String barangaysJson = await rootBundle.loadString(
        'assets/locations/barangay.json',
      );

      final List<dynamic> provincesData = json.decode(provincesJson);
      final List<dynamic> municipalitiesData = json.decode(municipalitiesJson);
      final List<dynamic> barangaysData = json.decode(barangaysJson);

      _provincesData = List<Map<String, dynamic>>.from(provincesData);
      _municipalitiesData = List<Map<String, dynamic>>.from(municipalitiesData);
      _barangaysData = List<Map<String, dynamic>>.from(barangaysData);

      final List<String> provinceNames = _provincesData
          .map((province) => province['province_name'] as String)
          .toList();

      if (mounted) {
        setState(() {
          _provinces = provinceNames;

          // --- CRITICAL FIX: Restore Dependent Dropdowns ---
          // 1. If we have a selected province, manually trigger the logic to load cities
          if (_selectedProvince != null) {
            _restoreCitiesForProvince(_selectedProvince!);
          }

          // 2. If we have a selected city, manually trigger the logic to load barangays
          if (_selectedCityMunicipality != null) {
            _restoreBarangaysForCity(_selectedCityMunicipality!);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _provinces = ['Metro Manila', 'Cebu', 'Davao del Sur'];
        });
      }
    }
  }

  // Logic to load cities (Used by both Dropdown onChange and Init)
  void _restoreCitiesForProvince(String provinceName) {
    final selectedProvinceData = _provincesData.firstWhere(
      (province) => province['province_name'] == provinceName,
      orElse: () => <String, dynamic>{},
    );

    if (selectedProvinceData.isNotEmpty) {
      _selectedProvinceId = selectedProvinceData['province_id'] as int;
      final municipalitiesForProvince = _municipalitiesData
          .where(
            (municipality) =>
                municipality['province_id'] == _selectedProvinceId,
          )
          .toList();

      _citiesMunicipalities = municipalitiesForProvince
          .map((municipality) => municipality['municipality_name'] as String)
          .toList();
    }
  }

  // Logic to load barangays (Used by both Dropdown onChange and Init)
  void _restoreBarangaysForCity(String cityName) {
    final selectedMunicipalityData = _municipalitiesData.firstWhere(
      (municipality) =>
          municipality['municipality_name'] == cityName &&
          municipality['province_id'] == _selectedProvinceId,
      orElse: () => <String, dynamic>{},
    );

    if (selectedMunicipalityData.isNotEmpty) {
      _selectedMunicipalityId =
          selectedMunicipalityData['municipality_id'] as int;
      final barangaysForMunicipality = _barangaysData
          .where(
            (barangay) =>
                barangay['municipality_id'] == _selectedMunicipalityId,
          )
          .toList();

      _barangays = barangaysForMunicipality
          .map((barangay) => barangay['barangay_name'] as String)
          .toList();
    }
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2C6A64),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  void _onNext(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // Validation passed
      context.read<MentorRegistrationProvider>().updatePersonalInfo(
        fullName: _fullNameController.text,
        bio: _bioController.text,
        birthdate: _selectedBirthDate!,
        unit: _unitBldgController.text,
        street: _streetController.text,
        province: _selectedProvince!,
        city: _selectedCityMunicipality!,
        barangay: _selectedBarangay!,
        zipCode: _zipCodeController.text,
      );
      context.read<MentorRegistrationProvider>().nextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF2C6A64);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: darkGreen,
                    child: const Icon(
                      Icons.edit_document,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Mentor Registration',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Full Name
            const Text(
              'Full Name',
              style: TextStyle(
                color: Color(0xFF10403B),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            TextFormField(
              controller: _fullNameController,
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty || !RegExp(r'^[A-Za-z ]+').hasMatch(v)) {
                  return 'Full name must only contain letters.';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: 'e.g. Juan Dela Cruz',
              ),
            ),
            const SizedBox(height: 20),

            // Birthdate
            const Text(
              'Date of Birth',
              style: TextStyle(
                color: Color(0xFF10403B),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            TextFormField(
              readOnly: true,
              onTap: () => _selectBirthDate(context),
              decoration: InputDecoration(
                hintText: _selectedBirthDate == null
                    ? 'Select your birthdate'
                    : DateFormat('MMMM dd, yyyy').format(_selectedBirthDate!),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              validator: (value) => _selectedBirthDate == null
                  ? 'Please select your birthdate.'
                  : null,
            ),
            const SizedBox(height: 20),

            // Bio
            const Text(
              'Bio',
              style: TextStyle(
                color: Color(0xFF10403B),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            TextFormField(
              controller: _bioController,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Tell us about yourself (optional)',
              ),
            ),
            const SizedBox(height: 20),

            // Address
            const Text(
              'Address Details',
              style: TextStyle(
                color: Color(0xFF10403B),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    controller: _unitBldgController,
                    decoration: const InputDecoration(
                      hintText: 'Unit/Bldg (Opt)',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 6,
                  child: TextFormField(
                    controller: _streetController,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Required.'
                        : null,
                    decoration: const InputDecoration(hintText: 'Street Name'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Province Dropdown
            DropdownButtonFormField<String>(
              value: _selectedProvince,
              decoration: const InputDecoration(
                hintText: 'Select Province',
                border: OutlineInputBorder(),
              ),
              items: _provinces
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedProvince = newValue;
                  _selectedCityMunicipality = null;
                  _selectedBarangay = null;
                  _citiesMunicipalities = [];
                  _barangays = [];
                  if (newValue != null) _restoreCitiesForProvince(newValue);
                });
              },
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            // City Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCityMunicipality,
              decoration: const InputDecoration(
                hintText: 'Select City',
                border: OutlineInputBorder(),
              ),
              items: _citiesMunicipalities
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: _selectedProvince == null
                  ? null
                  : (newValue) {
                      setState(() {
                        _selectedCityMunicipality = newValue;
                        _selectedBarangay = null;
                        _barangays = [];
                        if (newValue != null)
                          _restoreBarangaysForCity(newValue);
                      });
                    },
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            // Barangay Dropdown
            DropdownButtonFormField<String>(
              value: _selectedBarangay,
              decoration: const InputDecoration(
                hintText: 'Select Barangay',
                border: OutlineInputBorder(),
              ),
              items: _barangays
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              onChanged: _selectedCityMunicipality == null
                  ? null
                  : (newValue) {
                      setState(() => _selectedBarangay = newValue);
                    },
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            // Zip Code
            TextFormField(
              controller: _zipCodeController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(hintText: 'Zip (Opt)'),
              validator: (v) {
                if (v == null || v.isEmpty) return null;
                if (!RegExp(r'^\d{4}$').hasMatch(v)) return 'Must be 4 digits.';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Next Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF2C6A64),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _onNext(context),
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
