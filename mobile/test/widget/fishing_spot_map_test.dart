import 'package:flutter_test/flutter_test.dart';

/// Legacy Mapbox-specific FishingSpotMap widget tests were removed with the
/// Mapbox → flutter_map migration. Behaviour is covered by Mera UI smoke tests
/// and manual/CI APK runs. Restore targeted flutter_map widget tests later.
void main() {
  test('FishingSpotMap Mapbox tests retired', () {
    expect(true, isTrue);
  }, skip: 'Requires rewrite for flutter_map (Mapbox removed)');
}
