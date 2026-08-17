import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/default_flutter_map.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_managers.dart';
import '../mocks/stubbed_map_controller.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;
  late StubbedMapController mapController;

  setUp(() async {
    managers = await StubbedManagers.create();
    mapController = StubbedMapController(managers);
    when(managers.userPreferenceManager.mapType).thenReturn(MapType.light.id);
    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);
  });

  testWidgets("Single symbol management", (tester) async {
    await pumpMap(tester, mapController, const DefaultFlutterMap());

    const lat = 5.0;
    const lng = 2.0;
    final symbol = Symbol(options: SymbolOptions(latLng: LatLng(lat: lat, lng: lng)));

    await mapController.value.addSymbol(symbol);
    expect(mapController.value.symbols.length, 1);
    expect(mapController.value.symbols.first.latLng.lat, lat);
    expect(mapController.value.symbols.first.latLng.lng, lng);

    await mapController.value.removeSymbol(mapController.value.symbols.first);
    expect(mapController.value.symbols.isEmpty, isTrue);
  });

  testWidgets("Multi symbol management", (tester) async {
    await pumpMap(tester, mapController, const DefaultFlutterMap());

    final symbol1 = Symbol(
      options: SymbolOptions(latLng: LatLng(lat: 5.0, lng: 2.0)),
    );
    final symbol2 = Symbol(
      options: SymbolOptions(latLng: LatLng(lat: 10.0, lng: 8.0)),
    );

    await mapController.value.addSymbols([symbol1, symbol2]);
    expect(mapController.value.symbols.length, 2);

    await mapController.value.removeSymbols(mapController.value.symbols);
    expect(mapController.value.symbols.isEmpty, isTrue);
  });

  testWidgets("clearSymbols clears all symbols", (tester) async {
    await pumpMap(tester, mapController, const DefaultFlutterMap());

    await mapController.value.addSymbol(
      Symbol(options: SymbolOptions(latLng: LatLng(lat: 5.0, lng: 2.0))),
    );
    expect(mapController.value.symbols.length, 1);

    await mapController.value.clearSymbols();
    expect(mapController.value.symbols.isEmpty, isTrue);
  });

  testWidgets("updateSymbol updates the symbol", (tester) async {
    await pumpMap(tester, mapController, const DefaultFlutterMap());

    await mapController.value.addSymbol(
      Symbol(options: SymbolOptions(latLng: LatLng(lat: 5.0, lng: 2.0))),
    );
    var symbol = mapController.value.symbols.first;
    expect(symbol.metadata.hasFishingSpot(), isFalse);

    symbol.metadata = SymbolMetadata(
      fishingSpot: FishingSpot(name: "Test fishing spot"),
    );
    await mapController.value.updateSymbol(symbol);
    expect(mapController.value.symbols.first.metadata.hasFishingSpot(), isTrue);
  });

  testWidgets("Symbol tapped callback management", (tester) async {
    await pumpMap(tester, mapController, const DefaultFlutterMap());

    var tapped = <Symbol>[];
    void onSymbolTapped(Symbol s) => tapped.add(s);

    mapController.value.addOnSymbolTapped(onSymbolTapped);
    expect(mapController.value.onSymbolTappedCallbacks.length, 1);

    final symbol = Symbol(options: SymbolOptions(latLng: LatLngs.zero));
    mapController.value.handleSymbolTap(symbol);
    expect(tapped, [symbol]);

    mapController.value.removeOnSymbolTapped(onSymbolTapped);
    expect(mapController.value.onSymbolTappedCallbacks.isEmpty, isTrue);
  });

  testWidgets("moveCamera updates camera position", (tester) async {
    await pumpMap(tester, mapController, const DefaultFlutterMap());

    await mapController.value.moveCamera(
      CameraPosition(latLng: LatLng(lat: 10, lng: 20), zoom: 8),
    );

    var position = await mapController.value.cameraPosition();
    expect(position.latLng.lat, closeTo(10, 0.001));
    expect(position.latLng.lng, closeTo(20, 0.001));
    expect(position.zoom, 8);
  });

  testWidgets("animateCamera updates camera position", (tester) async {
    await pumpMap(tester, mapController, const DefaultFlutterMap());

    await mapController.value.animateCamera(
      CameraPosition(latLng: LatLng(lat: -5, lng: -15), zoom: 6),
      easeIn: true,
    );

    var position = await mapController.value.cameraPosition();
    expect(position.latLng.lat, closeTo(-5, 0.001));
    expect(position.latLng.lng, closeTo(-15, 0.001));
    expect(position.zoom, 6);
  });

  testWidgets("animateToBounds exits early for null bounds", (tester) async {
    await pumpMap(tester, mapController, const DefaultFlutterMap());
    await mapController.value.animateToBounds(null);
    // No exception is thrown; nothing to assert beyond that.
  });

  testWidgets("setMapType updates mapType and notifies listeners", (
    tester,
  ) async {
    await pumpMap(tester, mapController, const DefaultFlutterMap());

    var notified = false;
    mapController.value.addListener(() => notified = true);

    await mapController.value.setMapType(MapType.satellite);
    expect(mapController.value.mapType, MapType.satellite);
    expect(notified, isTrue);
  });

  testWidgets("moveMap updates isCameraMoving", (tester) async {
    await pumpMap(tester, mapController, const DefaultFlutterMap());

    var callCount = 0;
    mapController.value.onMapMoveCallback = () => callCount++;

    mapController.moveMap(isMoving: true);
    expect(mapController.value.isCameraMoving, isTrue);
    expect(callCount, 1);

    mapController.moveMap(isMoving: false);
    expect(mapController.value.isCameraMoving, isFalse);
    expect(callCount, 2);
  });
}
