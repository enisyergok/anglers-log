import 'package:flutter/material.dart';
import 'package:mobile/utils/map_utils.dart';

class MapAttribution extends StatelessWidget {
  final MapType? mapType;

  const MapAttribution({this.mapType});

  @override
  Widget build(BuildContext context) {
    var mapType = this.mapType ?? MapType.of(context);

    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        mapType.attribution,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}
