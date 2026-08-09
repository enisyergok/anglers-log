import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/default_mapbox_map.dart';
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
    when(managers.propertiesManager.mapboxApiKey).thenReturn('KEY');
    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);
  });

  testWidgets('Renders flutter_map for zero start position', (tester) async {
    await pumpMap(
      tester,
      mapController,
      DefaultMapboxMap(startPosition: LatLngs.zero),
    );
    expect(find.byType(FlutterMap), findsOneWidget);
  });

  testWidgets('Renders flutter_map for valid start position', (tester) async {
    await pumpMap(
      tester,
      mapController,
      DefaultMapboxMap(startPosition: LatLng(lat: 1, lng: 2)),
    );
    expect(find.byType(FlutterMap), findsOneWidget);
  });
}
