/// Model class representing a user's profile information collected during onboarding.
///
/// This model encapsulates personal details and address information.
/// Use [toFirestore] to convert the model to a map suitable for Firestore storage.
class UserProfileModel {
  final String fullName;
  final DateTime birthdate;
  final String bio;
  final String addressUnitBldg;
  final String addressStreet;
  final String addressBarangay;
  final String addressCity;
  final String addressProvince;
  final String addressZipCode;

  /// Creates a [UserProfileModel] with all required fields.
  UserProfileModel({
    required this.fullName,
    required this.birthdate,
    required this.bio,
    required this.addressUnitBldg,
    required this.addressStreet,
    required this.addressBarangay,
    required this.addressCity,
    required this.addressProvince,
    required this.addressZipCode,
  });

  /// Converts this model to a Firestore-compatible map with snake_case keys.
  ///
  /// The [birthdate] is stored as a Timestamp for proper querying in Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'full_name': fullName,
      'birthdate': birthdate,
      'bio': bio,
      'address_unit_bldg': addressUnitBldg,
      'address_street': addressStreet,
      'address_barangay': addressBarangay,
      'address_city': addressCity,
      'address_province': addressProvince,
      'address_zip_code': addressZipCode,
    };
  }

  /// Creates a [UserProfileModel] from a Firestore document map.
  ///
  /// Throws [TypeError] if required fields are missing or have incorrect types.
  factory UserProfileModel.fromFirestore(Map<String, dynamic> data) {
    return UserProfileModel(
      fullName: data['full_name'] as String,
      birthdate: (data['birthdate'] as DateTime),
      bio: data['bio'] as String,
      addressUnitBldg: data['address_unit_bldg'] as String,
      addressStreet: data['address_street'] as String,
      addressBarangay: data['address_barangay'] as String,
      addressCity: data['address_city'] as String,
      addressProvince: data['address_province'] as String,
      addressZipCode: data['address_zip_code'] as String,
    );
  }
}
