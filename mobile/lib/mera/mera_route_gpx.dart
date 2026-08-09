import 'package:latlong2/latlong.dart';
import 'package:mobile/mera/mera_route_manager.dart';

/// GPX import/export for Mera routes (waypoints as route points).
class MeraRouteGpx {
  MeraRouteGpx._();

  static String export(MeraRoute route) {
    final buf = StringBuffer()
      ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
      ..writeln(
        '<gpx version="1.1" creator="MeraAsistan" xmlns="http://www.topografix.com/GPX/1/1">',
      )
      ..writeln('<rte><name>${_xml(route.name)}</name>');
    for (var i = 0; i < route.points.length; i++) {
      final p = route.points[i];
      final label = p.label ?? '${i + 1}';
      buf.writeln(
        '<rtept lat="${p.lat}" lon="${p.lng}"><name>${_xml(label)}</name></rtept>',
      );
    }
    buf.writeln('</rte></gpx>');
    return buf.toString();
  }

  /// Parses rtept / trkpt / wpt coordinates into LatLng list.
  static List<LatLng> parsePoints(String gpx) {
    final out = <LatLng>[];
    final re = RegExp(
      r'<(?:rtept|trkpt|wpt)\s+[^>]*lat="([-0-9.]+)"\s+lon="([-0-9.]+)"',
      caseSensitive: false,
    );
    for (final m in re.allMatches(gpx)) {
      final lat = double.tryParse(m.group(1)!);
      final lng = double.tryParse(m.group(2)!);
      if (lat != null && lng != null) {
        out.add(LatLng(lat, lng));
      }
    }
    // Alternate attribute order lon/lat
    if (out.isEmpty) {
      final re2 = RegExp(
        r'<(?:rtept|trkpt|wpt)\s+[^>]*lon="([-0-9.]+)"\s+lat="([-0-9.]+)"',
        caseSensitive: false,
      );
      for (final m in re2.allMatches(gpx)) {
        final lng = double.tryParse(m.group(1)!);
        final lat = double.tryParse(m.group(2)!);
        if (lat != null && lng != null) {
          out.add(LatLng(lat, lng));
        }
      }
    }
    return out;
  }

  static String _xml(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}
