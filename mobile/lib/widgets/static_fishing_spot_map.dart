import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/map/flutter_map_controller.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/fishing_spot_details.dart';
import 'package:mobile/widgets/map_attribution.dart';

import '../res/dimen.dart';
import 'fishing_spot_map.dart';

/// A widget that displays [FishingSpot] details on a constrained,
/// non-interactive map.
///
/// See:
///  - [FishingSpotMap]
///  - [EditCoordinatesPage]
///  - [DefaultFlutterMap]
class StaticFishingSpotMap extends StatefulWidget {
  final FishingSpot fishingSpot;
  final EdgeInsets? padding;

  const StaticFishingSpotMap(this.fishingSpot, {this.padding});

  @override
  State<StaticFishingSpotMap> createState() => _StaticFishingSpotMapState();
}

class _StaticFishingSpotMapState extends State<StaticFishingSpotMap> {
  static const _mapHeight = 200.0;
  static const _mapZoom = 11.0;
  static const _pinSize = 25.0;

  late MapType _mapType;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mapType = MapType.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => push(context, FishingSpotMap.selected(widget.fishingSpot)),
      child: Column(
        children: [
          Container(
            padding: insetsHorizontalDefaultTopDefault,
            width: double.infinity,
            height: _mapHeight,
            child: ClipRRect(
              borderRadius: defaultBorderRadius,
              child: Stack(
                children: [
                  Positioned.fill(child: IgnorePointer(child: _buildMap())),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: insetsSmall,
                      child: MapAttribution(mapType: _mapType),
                    ),
                  ),
                  Center(
                    child: SvgPicture.asset(
                      "assets/active-pin.svg",
                      width: _pinSize,
                      height: _pinSize,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildDetails(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return fm.FlutterMap(
      options: fm.MapOptions(
        initialCenter: widget.fishingSpot.latLng.point,
        initialZoom: _mapZoom,
        interactionOptions: const fm.InteractionOptions(
          flags: fm.InteractiveFlag.none,
        ),
      ),
      children: [
        fm.TileLayer(
          urlTemplate: _mapType.urlTemplate,
          subdomains: _mapType.subdomains,
          userAgentPackageName: "com.cohenadair.anglerslog",
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return FishingSpotDetails(
      widget.fishingSpot,
      isListItem: true,
      showRightChevron: true,
    );
  }
}
