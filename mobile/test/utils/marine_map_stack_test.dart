import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/map_utils.dart';

void main() {
  group('marine HD free stack constants', () {
    test('ocean is the default fallback MapType', () {
      expect(MapType.fromId(null), isNull);
      expect(MapType.ocean.isMarine, isTrue);
      expect(MapType.satellite.isMarine, isFalse);
    });

    test('EMODnet and Ocean Reference URLs are set', () {
      expect(emodnetBathymetryWmsBaseUrl, contains('emodnet-bathymetry'));
      expect(emodnetBathymetryWmsLayer, 'emodnet:mean');
      expect(emodnetBathymetryWmsStyle, 'multicolour');
      expect(emodnetContoursWmsLayer, 'emodnet:contours');
      expect(esriOceanReferenceUrl, contains('World_Ocean_Reference'));
      expect(MapType.ocean.url, contains('World_Ocean_Base'));
    });
  });
}
