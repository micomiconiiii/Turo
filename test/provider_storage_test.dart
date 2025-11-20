import 'package:flutter_test/flutter_test.dart';
import 'package:turo/presentation/mentee_onboarding/providers/mentee_onboarding_provider.dart';

void main() {
  group('MenteeOnboardingProvider.setAddressDetails', () {
    test('composes full address in expected order and skips empties', () {
      final provider = MenteeOnboardingProvider();

      provider.setAddressDetails({
        'unitBldg': 'Unit 5B One Plaza',
        'street': 'Main St',
        'barangay': 'Barangay 123',
        'cityMunicipality': 'Makati City',
        'province': 'Metro Manila',
        'zip': '1234',
      });

      expect(provider.addressDetails['unitBldg'], 'Unit 5B One Plaza');
      expect(provider.addressDetails['street'], 'Main St');
      expect(provider.addressDetails['barangay'], 'Barangay 123');
      expect(provider.addressDetails['cityMunicipality'], 'Makati City');
      expect(provider.addressDetails['province'], 'Metro Manila');
      expect(provider.addressDetails['zip'], '1234');

      // Expect the single-line composed address in order
      expect(
        provider.address,
        'Unit 5B One Plaza, Main St, Barangay 123, Makati City, Metro Manila, 1234',
      );
    });

    test('skips null/empty parts when composing address', () {
      final provider = MenteeOnboardingProvider();

      provider.setAddressDetails({
        'unitBldg': '',
        'street': 'Science Rd',
        'barangay': null,
        'cityMunicipality': 'Quezon City',
        'province': 'Metro Manila',
        'zip': '',
      });

      expect(provider.address, 'Science Rd, Quezon City, Metro Manila');
    });
  });
}
