import 'package:flutter/material.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/wrappers/url_launcher_wrapper.dart';

import '../../utils/string_utils.dart';
import '../map/map_controller.dart';
import 'bottom_sheet_picker.dart';
import 'button.dart';
import 'our_bottom_sheet.dart';

class MapboxAttribution extends StatelessWidget {
  static const _urlOpenStreetMap = 'https://www.openstreetmap.org/copyright';
  static const _urlOpenSeaMap = 'https://www.openseamap.org/';
  static const _urlCarto = 'https://carto.com/attribution/';
  static const _urlEsri =
      'https://www.esri.com/en-us/legal/terms/full-master-agreement';
  static const _urlOsmEdit = 'https://www.openstreetmap.org/fixthemap';

  final MapType? mapType;
  final MapController? mapController;

  const MapboxAttribution({this.mapType, this.mapController});

  @override
  Widget build(BuildContext context) {
    final color = mapIconColor(mapType ?? MapType.of(context));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            '© OSM · OpenSeaMap · CARTO · Esri',
            style: styleSubtitle(context).copyWith(color: color, fontSize: 10),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        MinimumIconButton(
          icon: Icons.info_outline,
          onTap: () => showOurBottomSheet(context, _buildPicker),
        ),
      ],
    );
  }

  BottomSheetPicker _buildPicker(BuildContext context) {
    return BottomSheetPicker<String>(
      title: 'Map data',
      itemStyle: styleHyperlink(context),
      items: {
        Strings.of(context).mapAttributionOpenStreetMap: _urlOpenStreetMap,
        '© OpenSeaMap': _urlOpenSeaMap,
        '© CARTO': _urlCarto,
        '© Esri': _urlEsri,
        Strings.of(context).mapAttributionImproveThisMap: _urlOsmEdit,
      },
      onPicked: (url) => UrlLauncherWrapper.of(context).launch(url!),
    );
  }
}
