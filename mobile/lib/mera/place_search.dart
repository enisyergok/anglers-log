import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/utils/map_utils.dart';

class PlaceSearchHit {
  const PlaceSearchHit({
    required this.name,
    required this.lat,
    required this.lng,
  });

  final String name;
  final double lat;
  final double lng;
}

/// Free OpenStreetMap Nominatim geocoder (no API key).
abstract final class PlaceSearch {
  static final _coordRe = RegExp(
    r'^\s*(-?\d+(?:\.\d+)?)\s*[,;\s]\s*(-?\d+(?:\.\d+)?)\s*$',
  );

  static Future<List<PlaceSearchHit>> search(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.length < 2) return const [];

    final coord = _coordRe.firstMatch(query);
    if (coord != null) {
      final a = double.parse(coord.group(1)!);
      final b = double.parse(coord.group(2)!);
      // Turkey-ish: lat ~36-42, lng ~26-45 — accept either order.
      final lat = (a.abs() <= 90 && b.abs() <= 180) ? a : b;
      final lng = (a.abs() <= 90 && b.abs() <= 180) ? b : a;
      if (lat.abs() > 90 || lng.abs() > 180) return const [];
      return [
        PlaceSearchHit(
          name: '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
          lat: lat,
          lng: lng,
        ),
      ];
    }

    Future<List<PlaceSearchHit>> run({String? countrycodes}) async {
      final params = <String, String>{
        'q': query,
        'format': 'json',
        'addressdetails': '0',
        'limit': '8',
      };
      if (countrycodes != null) params['countrycodes'] = countrycodes;
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', params);
      final res = await http.get(
        uri,
        headers: {
          'User-Agent': mapTileUserAgentPackageName,
          'Accept-Language': 'tr',
        },
      );
      if (res.statusCode != 200) return const [];
      final list = jsonDecode(res.body);
      if (list is! List) return const [];
      return list
          .whereType<Map>()
          .map((e) {
            final lat = double.tryParse('${e['lat']}');
            final lng = double.tryParse('${e['lon']}');
            final name = '${e['display_name'] ?? ''}'.trim();
            if (lat == null || lng == null || name.isEmpty) return null;
            return PlaceSearchHit(name: name, lat: lat, lng: lng);
          })
          .whereType<PlaceSearchHit>()
          .toList();
    }

    var hits = await run(countrycodes: 'tr');
    if (hits.isEmpty) hits = await run();
    return hits;
  }
}
