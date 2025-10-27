import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

/// PersonalInfoStep captures name, birth date, bio, and a structured address
/// using cascading Province -> City/Municipality -> Barangay dropdowns.
///
/// Data source:
/// - assets/locations/province.json      with keys: { province_id, province_name }
/// - assets/locations/municipality.json  with keys: { municipality_id, province_id, municipality_name }
/// - assets/locations/barangay.json      with keys: { barangay_id, municipality_id, barangay_name }
///
/// Contract:
/// - Call [validateAndSave] before advancing to ensure required fields are set.
/// - Read getters ([fullName], [birthMonth]/[birthDay]/[birthYear], [bio],
///   and [addressDetails]) to persist to the provider.
/// - Dropdowns are controlled via [initialValue] and [ValueKey] to avoid
///   deprecated patterns and to guarantee visual resets when parent values
///   change.

class PersonalInfoStep extends StatefulWidget {
  const PersonalInfoStep({super.key});

  @override
  PersonalInfoStepState createState() => PersonalInfoStepState();
}

class PersonalInfoStepState extends State<PersonalInfoStep> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  // Address fields
  final TextEditingController _unitBldgController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();

  // Date picker state
  DateTime? _selectedBirthDate;

  // Dropdown state for location
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
    _loadLocationData();
  }

  /// Load location data from JSON files
  Future<void> _loadLocationData() async {
    try {
      // Load all three JSON files
      final String provincesJson = await rootBundle.loadString(
        'assets/locations/province.json',
      );
      final String municipalitiesJson = await rootBundle.loadString(
        'assets/locations/municipality.json',
      );
      final String barangaysJson = await rootBundle.loadString(
        'assets/locations/barangay.json',
      );

      // Parse JSON data
      final List<dynamic> provincesData = json.decode(provincesJson);
      final List<dynamic> municipalitiesData = json.decode(municipalitiesJson);
      final List<dynamic> barangaysData = json.decode(barangaysJson);

      // Store the full data
      _provincesData = List<Map<String, dynamic>>.from(provincesData);
      _municipalitiesData = List<Map<String, dynamic>>.from(municipalitiesData);
      _barangaysData = List<Map<String, dynamic>>.from(barangaysData);

      // Extract province names for the first dropdown
      final List<String> provinceNames = _provincesData
          .map((province) => province['province_name'] as String)
          .toList();

      setState(() {
        _provinces = provinceNames;
      });
      debugPrint(
        'Successfully loaded ${_provinces.length} provinces, ${_municipalitiesData.length} municipalities, ${_barangaysData.length} barangays',
      );
    } catch (e) {
      debugPrint('Error loading location data: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      // Fallback to placeholder data if JSON loading fails
      setState(() {
        _provinces = ['Metro Manila', 'Cebu', 'Davao del Sur'];
      });
    }
  }

  /// Show date picker for birthdate selection
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

  /// Validate the form and save values. Returns true if valid.
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form == null) return true;
    final valid = form.validate();
    if (valid) form.save();
    return valid;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _unitBldgController.dispose();
    _streetController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  /// Sanitized full name (letters and spaces) or null when empty.
  String? get fullName {
    final value = _nameController.text.trim();
    return value.isEmpty ? null : value;
  }

  /// Two-digit month component (MM) or null if no date selected.
  String? get birthMonth {
    return _selectedBirthDate?.month.toString().padLeft(2, '0');
  }

  /// Two-digit day component (dd) or null if no date selected.
  String? get birthDay {
    return _selectedBirthDate?.day.toString().padLeft(2, '0');
  }

  /// Four-digit year component (yyyy) or null if no date selected.
  String? get birthYear {
    return _selectedBirthDate?.year.toString();
  }

  /// Short bio string or null when empty.
  String? get bio {
    final value = _bioController.text.trim();
    return value.isEmpty ? null : value;
  }

  // Structured address details getter
  Map<String, String?> get addressDetails => {
    'unitBldg': _unitBldgController.text.trim().isEmpty
        ? null
        : _unitBldgController.text.trim(),
    'street': _streetController.text.trim().isEmpty
        ? null
        : _streetController.text.trim(),
    'barangay': _selectedBarangay,
    'cityMunicipality': _selectedCityMunicipality,
    'province': _selectedProvince,
    'zip': _zipCodeController.text.trim().isEmpty
        ? null
        : _zipCodeController.text.trim(),
  };

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF2C6A64);
    // Scrollable in case of small screens/keyboard overlap
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Header section
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
                    'Complete your profile',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Full name field
            const Text(
              'Full Name',
              style: TextStyle(
                color: Color(0xFF10403B),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            TextFormField(
              controller: _nameController,
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty || !RegExp(r'^[A-Za-z ]+$').hasMatch(v)) {
                  return 'Full name cannot be empty and must only contain letters and spaces.';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: 'e.g. Juan Dela Cruz',
              ),
            ),
            const SizedBox(height: 20),
            // Birthdate picker (read-only field opens date picker)
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
              validator: (value) {
                if (_selectedBirthDate == null) {
                  return 'Please select your birthdate.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Bio (optional)
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
            // Address — structured
            const Text(
              'Address Details',
              style: TextStyle(
                color: Color(0xFF10403B),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            // Row 1: Unit/Bldg (optional) + Street Name (required)
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
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'This field cannot be empty.';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(hintText: 'Street Name'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Province Dropdown
            const Text(
              'Province',
              style: TextStyle(
                color: Color(0xFF10403B),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              // The ValueKey forces the widget to rebuild when the selection
              // changes so dependent dropdowns reset reliably.
              key: ValueKey('province_$_selectedProvince'),
              initialValue: _selectedProvince,
              decoration: const InputDecoration(
                hintText: 'Select Province',
                border: OutlineInputBorder(),
              ),
              items: _provinces.map((String province) {
                return DropdownMenuItem<String>(
                  value: province,
                  child: Text(province),
                );
              }).toList(), // return list of DropdownMenuItem for provinces
              onChanged: (String? newValue) {
                setState(() {
                  _selectedProvince = newValue;
                  _selectedCityMunicipality = null;
                  _selectedBarangay = null;
                  _barangays = [];

                  // Load cities/municipalities for the selected province
                  if (newValue != null && _provincesData.isNotEmpty) {
                    // Find the province_id for the selected province
                    final selectedProvinceData = _provincesData.firstWhere(
                      (province) => province['province_name'] == newValue,
                      orElse: () => <String, dynamic>{},
                    );

                    if (selectedProvinceData.isNotEmpty) {
                      _selectedProvinceId =
                          selectedProvinceData['province_id'] as int;

                      // Filter municipalities by province_id
                      final municipalitiesForProvince = _municipalitiesData
                          .where(
                            (municipality) =>
                                municipality['province_id'] ==
                                _selectedProvinceId,
                          )
                          .toList();

                      _citiesMunicipalities = municipalitiesForProvince
                          .map(
                            (municipality) =>
                                municipality['municipality_name'] as String,
                          )
                          .toList();
                    } else {
                      _selectedProvinceId = null;
                      _citiesMunicipalities = [];
                    }
                  } else {
                    _selectedProvinceId = null;
                    _citiesMunicipalities = [];
                  }
                });
                debugPrint(
                  'Selected Province: $newValue (ID: $_selectedProvinceId)',
                );
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a province.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            // City/Municipality Dropdown
            const Text(
              'City / Municipality',
              style: TextStyle(
                color: Color(0xFF10403B),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              // Reset and disable until a province is chosen; ValueKey ensures
              // a clean rebuild when the province changes.
              key: ValueKey('city_$_selectedCityMunicipality'),
              initialValue: _selectedCityMunicipality,
              decoration: const InputDecoration(
                hintText: 'Select City/Municipality',
                border: OutlineInputBorder(),
              ),
              items: _citiesMunicipalities.map((String city) {
                return DropdownMenuItem<String>(value: city, child: Text(city));
              }).toList(), // return list of DropdownMenuItem for cities
              onChanged: _selectedProvince == null
                  ? null
                  : (String? newValue) {
                      setState(() {
                        _selectedCityMunicipality = newValue;
                        _selectedBarangay = null;

                        // Load barangays for the selected city/municipality
                        if (newValue != null &&
                            _municipalitiesData.isNotEmpty) {
                          // Find the municipality_id for the selected city/municipality
                          final selectedMunicipalityData = _municipalitiesData
                              .firstWhere(
                                (municipality) =>
                                    municipality['municipality_name'] ==
                                        newValue &&
                                    municipality['province_id'] ==
                                        _selectedProvinceId,
                                orElse: () => <String, dynamic>{},
                              );

                          if (selectedMunicipalityData.isNotEmpty) {
                            _selectedMunicipalityId =
                                selectedMunicipalityData['municipality_id']
                                    as int;

                            // Filter barangays by municipality_id
                            final barangaysForMunicipality = _barangaysData
                                .where(
                                  (barangay) =>
                                      barangay['municipality_id'] ==
                                      _selectedMunicipalityId,
                                )
                                .toList();

                            _barangays = barangaysForMunicipality
                                .map(
                                  (barangay) =>
                                      barangay['barangay_name'] as String,
                                )
                                .toList();
                          } else {
                            _selectedMunicipalityId = null;
                            _barangays = [];
                          }
                        } else {
                          _selectedMunicipalityId = null;
                          _barangays = [];
                        }
                      });
                      debugPrint(
                        'Selected City/Municipality: $newValue (ID: $_selectedMunicipalityId)',
                      );
                    },
              validator: (value) {
                if (value == null) {
                  return 'Please select a city/municipality.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            // Barangay Dropdown
            const Text(
              'Barangay',
              style: TextStyle(
                color: Color(0xFF10403B),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              // Enabled only when a city/municipality is selected.
              key: ValueKey('barangay_$_selectedBarangay'),
              initialValue: _selectedBarangay,
              decoration: const InputDecoration(
                hintText: 'Select Barangay',
                border: OutlineInputBorder(),
              ),
              items: _barangays.map((String barangay) {
                return DropdownMenuItem<String>(
                  value: barangay,
                  child: Text(barangay),
                );
              }).toList(), // return list of DropdownMenuItem for barangays
              onChanged: _selectedCityMunicipality == null
                  ? null
                  : (String? newValue) {
                      setState(() {
                        _selectedBarangay = newValue;
                      });
                      debugPrint('Selected Barangay: $newValue');
                    },
              validator: (value) {
                if (value == null) {
                  return 'Please select a barangay.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            // Zip Code (optional, numeric)
            const Text(
              'Zip Code (Optional)',
              style: TextStyle(
                color: Color(0xFF10403B),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _zipCodeController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) return null; // optional
                if (!RegExp(r'^\d{4}$').hasMatch(v)) {
                  return 'Zip code must be 4 digits.';
                }
                return null;
              },
              decoration: const InputDecoration(hintText: 'Zip (Opt)'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ); // return SingleChildScrollView
  }
}
