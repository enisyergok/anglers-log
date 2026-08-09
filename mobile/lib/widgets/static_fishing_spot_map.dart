import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/utils/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/fishing_spot_details.dart';
import 'package:mobile/widgets/map_attribution.dart';

import '../res/dimen.dart';
import 'fishing_spot_map.dart';

/// A widget that displays [FishingSpot] details on a constrained map.
///
/// See:
///  - [FishingSpotMap]
///  - [EditCoordinatesPage]
///  - [DefaultMapboxMap]
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
            padding: widget.padding ?? insetsHorizontalDefaultTopDefault,
            width: double.infinity,
            height: _mapHeight,
            child: ClipRRect(
              borderRadius: defaultBorderRadius,
              child: Stack(
                children: [
                  Positioned.fill(child: _buildMap()),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: insetsSmall,
                      child: MapboxAttribution(mapType: _mapType),
                    ),
                  ),
                  Center(
                    child: SvgPicture.asset(
                      'assets/active-pin.svg',
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
    final latLng = widget.fishingSpot.latLng;
    return IgnorePointer(
      child: fm.FlutterMap(
        options: fm.MapOptions(
          initialCenter: ll.LatLng(latLng.lat, latLng.lng),
          initialZoom: _mapZoom,
          interactionOptions: const fm.InteractionOptions(
            flags: fm.InteractiveFlag.none,
          ),
        ),
        children: [
          fm.TileLayer(
            urlTemplate: _mapType.url,
            subdomains: const ['a', 'b', 'c', 'd'],
            userAgentPackageName: mapTileUserAgentPackageName,
          ),
          fm.TileLayer(
            urlTemplate: openSeaMapSeamarkUrl,
            userAgentPackageName: mapTileUserAgentPackageName,
          ),
        ],
      ),
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
