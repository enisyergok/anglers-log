import 'package:http/http.dart' as http;

/// Approximate depth sample from free EMODnet WMS GetFeatureInfo.
///
/// Not survey-grade / not for navigation — returns null when unavailable.
class DepthSampler {
  DepthSampler._();

  static Future<double?> sampleMeters({
    required double lat,
    required double lng,
  }) async {
    try {
      // Tiny bbox around the point (degrees).
      const d = 0.01;
      final minLon = lng - d;
      final maxLon = lng + d;
      final minLat = lat - d;
      final maxLat = lat + d;
      final uri = Uri.parse(
        'https://ows.emodnet-bathymetry.eu/wms?'
        'SERVICE=WMS&VERSION=1.1.1&REQUEST=GetFeatureInfo'
        '&LAYERS=emodnet%3Amean&QUERY_LAYERS=emodnet%3Amean'
        '&STYLES=multicolour&SRS=EPSG%3A4326'
        '&BBOX=$minLon,$minLat,$maxLon,$maxLat'
        '&WIDTH=101&HEIGHT=101&X=50&Y=50'
        '&INFO_FORMAT=text%2Fplain',
      );
      final res = await http
          .get(uri, headers: {'User-Agent': 'MeraAsistan/1.0'})
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      return parseFeatureInfo(res.body);
    } catch (_) {
      return null;
    }
  }

  /// Parses plain-text GetFeatureInfo bodies for a numeric depth (meters).
  static double? parseFeatureInfo(String body) {
    // Common patterns: "GRAY_INDEX = -42.3" or "value = 42.3" (positive down).
    final patterns = [
      RegExp(r'GRAY_INDEX\s*[:=]\s*(-?\d+(?:\.\d+)?)', caseSensitive: false),
      RegExp(r'(?:elevation|depth|value|BAND1)\s*[:=]\s*(-?\d+(?:\.\d+)?)',
          caseSensitive: false),
      RegExp(r'(-?\d+(?:\.\d+)?)\s*m(?:eters?)?\b', caseSensitive: false),
    ];
    for (final re in patterns) {
      final m = re.firstMatch(body);
      if (m == null) continue;
      final v = double.tryParse(m.group(1)!);
      if (v == null) continue;
      // Bathymetry often negative = below sea level; report positive depth.
      final depth = v.abs();
      if (depth > 0 && depth < 12000) return depth;
    }
    return null;
  }
}
