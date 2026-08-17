import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/map/flutter_map_controller.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/widgets/default_flutter_map.dart';

import 'stubbed_managers.dart';

class StubbedMapController {
  late final FlutterMapController value;

  final StubbedManagers _managers;

  StubbedMapController(this._managers);

  /// Unlike Mapbox, [DefaultFlutterMap] creates a real, testable controller
  /// synchronously in initState and invokes `onMapCreated` with it right
  /// away, so there's no native map load to wait for. This just grabs that
  /// already-created controller off the widget's state.
  Future<void> finishLoading(WidgetTester tester) async {
    value =
        (tester.state(find.byType(DefaultFlutterMap)) as dynamic).controller
            as FlutterMapController;
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
  }

  void moveMap({bool isMoving = false}) {
    value.debugSimulateMapMove(isMoving: isMoving);
  }

  void stubCameraPosition(CameraPosition position) {
    value.fmController.move(position.latLng.point, position.zoom);
  }
}
