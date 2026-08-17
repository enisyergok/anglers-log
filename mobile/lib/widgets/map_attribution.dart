import 'package:flutter/material.dart';
import 'package:mobile/utils/map_utils.dart';

class MapAttribution extends StatelessWidget {
  final MapType? mapType;

  const MapAttribution({this.mapType});

  @override
  Widget build(BuildContext context) {
    var mapType = this.mapType ?? MapType.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.black45,
      child: Text(
        mapType.attribution,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}
