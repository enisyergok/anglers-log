import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  group('distanceBetween', () {
    test('Invalid input', () {
      expect(distanceBetween(LatLng(lat: -45.0, lng: -75.0), null), 0);
      expect(distanceBetween(null, LatLng(lat: 89, lng: 150)), 0);
    });

    test('Normal case', () {
      expect(
        distanceBetween(
          LatLng(lat: -45.0, lng: -75.0),
          LatLng(lat: 89, lng: 150),
        ),
        29105052.801043,
      );
    });
  });

  group('mapBounds', () {
    test('Invalid input', () {
      expect(latLngsToBounds({}), isNull);
    });

    test('Normal case', () {
      var bounds = fishingSpotMapBounds({
        FishingSpot()
          ..lat = 50
          ..lng = 1,
        FishingSpot()
          ..lat = -45
          ..lng = 150,
        FishingSpot()
          ..lat = -10
          ..lng = 35,
        FishingSpot()
          ..lat = 89
          ..lng = -75,
      })!;
      expect(bounds.southwest, LatLng(lat: -45.0, lng: -75.0));
      expect(bounds.northeast, LatLng(lat: 89, lng: 150));
    });
  });

  group('mapIconColor', () {
    test('White icon', () {
      expect(mapIconColor(MapType.satellite), Colors.white);
    });

    test('Black icon', () {
      expect(mapIconColor(MapType.light), Colors.black);
    });
  });

  group('GpsMapTrail', () {
    test(
      'retired Mapbox SymbolTrail suite',
      () {},
      skip: 'Needs FakeMapController after Mapbox removal',
    );
  });

  testWidgets(
    'updateMapAttributionMargin does nothing when controller is null',
    (tester) async {
      final context = await pumpContext(tester, (_) => const SizedBox());
      updateMapAttributionMargin(GlobalKey(), null, context);
    },
  );

  testWidgets(
    'updateMapAttributionMargin calls with 0 when key has no context',
    (tester) async {
      final managers = await StubbedManagers.create();
      when(managers.lib.ioWrapper.isAndroid).thenReturn(false);

      final mockController = MockMapController();
      when(
        mockController.updateLogoAndAttributionMarginBottom(any),
      ).thenAnswer((_) async {});
      final context = await pumpContext(tester, (_) => const SizedBox());
      updateMapAttributionMargin(GlobalKey(), mockController, context);
      verify(mockController.updateLogoAndAttributionMarginBottom(0)).called(1);
    },
  );

  testWidgets(
    'updateMapAttributionMargin calls with 0 when rendered height is zero',
    (tester) async {
      final managers = await StubbedManagers.create();
      when(managers.lib.ioWrapper.isAndroid).thenReturn(false);

      final mockController = MockMapController();
      when(
        mockController.updateLogoAndAttributionMarginBottom(any),
      ).thenAnswer((_) async {});

      final key = GlobalKey();
      final context = await pumpContext(
        tester,
        (_) => Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(key: key, height: 0, width: 100.0),
          ),
        ),
      );

      updateMapAttributionMargin(key, mockController, context);

      verify(mockController.updateLogoAndAttributionMarginBottom(0)).called(1);
    },
  );

  testWidgets(
    'updateMapAttributionMargin calls with height plus margin when rendered height is positive',
    (tester) async {
      final managers = await StubbedManagers.create();
      when(managers.lib.ioWrapper.isAndroid).thenReturn(false);

      final mockController = MockMapController();
      when(
        mockController.updateLogoAndAttributionMarginBottom(any),
      ).thenAnswer((_) async {});

      final key = GlobalKey();
      final context = await pumpContext(
        tester,
        (_) => Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(key: key, height: 100.0, width: 100.0),
          ),
        ),
      );

      updateMapAttributionMargin(key, mockController, context);

      verify(
        mockController.updateLogoAndAttributionMarginBottom(
          100.0 + 2 * paddingDefault,
        ),
      ).called(1);
    },
  );

  testWidgets(
    'updateMapAttributionMargin adds Android bottom inset when rendered height is zero',
    (tester) async {
      final managers = await StubbedManagers.create();
      when(managers.lib.ioWrapper.isAndroid).thenReturn(true);

      final mockController = MockMapController();
      when(
        mockController.updateLogoAndAttributionMarginBottom(any),
      ).thenAnswer((_) async {});

      const bottomInset = 34.0;
      final context = await pumpContext(
        tester,
        (_) => const SizedBox(),
        mediaQueryData: const MediaQueryData(
          viewPadding: EdgeInsets.only(bottom: bottomInset),
        ),
      );

      updateMapAttributionMargin(GlobalKey(), mockController, context);

      verify(
        mockController.updateLogoAndAttributionMarginBottom(bottomInset),
      ).called(1);
    },
  );

  testWidgets(
    'updateMapAttributionMargin adds Android bottom inset when rendered height is positive',
    (tester) async {
      final managers = await StubbedManagers.create();
      when(managers.lib.ioWrapper.isAndroid).thenReturn(true);

      final mockController = MockMapController();
      when(
        mockController.updateLogoAndAttributionMarginBottom(any),
      ).thenAnswer((_) async {});

      final key = GlobalKey();
      const bottomInset = 34.0;
      final context = await pumpContext(
        tester,
        (_) => Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(key: key, height: 100.0, width: 100.0),
          ),
        ),
        mediaQueryData: const MediaQueryData(
          viewPadding: EdgeInsets.only(bottom: bottomInset),
        ),
      );

      updateMapAttributionMargin(key, mockController, context);

      verify(
        mockController.updateLogoAndAttributionMarginBottom(
          100.0 + 2 * paddingDefault + bottomInset,
        ),
      ).called(1);
    },
  );
}
