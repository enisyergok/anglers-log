import 'package:http/http.dart' as http;
import 'dart:convert';

/// Free Open-Meteo Marine snapshot for the navigation HUD.
class MarineTelemetry {
  final double? waterTempC;
  final double? waveHeightM;
  final double? windSpeedKmh;
  final double? windDirectionDeg;

  const MarineTelemetry({
    this.waterTempC,
    this.waveHeightM,
    this.windSpeedKmh,
    this.windDirectionDeg,
  });

  static Future<MarineTelemetry?> fetch(double lat, double lng) async {
    final uri = Uri.https('marine-api.open-meteo.com', '/v1/marine', {
      'latitude': lat.toString(),
      'longitude': lng.toString(),
      'current':
          'sea_surface_temperature,wave_height,wind_wave_height',
      'timezone': 'auto',
    });
    final marine = await http.get(uri);
    Map<String, dynamic>? marineJson;
    if (marine.statusCode == 200) {
      marineJson = jsonDecode(marine.body) as Map<String, dynamic>;
    }

    final forecastUri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': lat.toString(),
      'longitude': lng.toString(),
      'current': 'wind_speed_10m,wind_direction_10m',
      'timezone': 'auto',
    });
    final forecast = await http.get(forecastUri);
    Map<String, dynamic>? forecastJson;
    if (forecast.statusCode == 200) {
      forecastJson = jsonDecode(forecast.body) as Map<String, dynamic>;
    }

    final mCurrent = marineJson?['current'] as Map<String, dynamic>?;
    final fCurrent = forecastJson?['current'] as Map<String, dynamic>?;

    return MarineTelemetry(
      waterTempC: (mCurrent?['sea_surface_temperature'] as num?)?.toDouble(),
      waveHeightM:
          (mCurrent?['wave_height'] as num?)?.toDouble() ??
          (mCurrent?['wind_wave_height'] as num?)?.toDouble(),
      windSpeedKmh: (fCurrent?['wind_speed_10m'] as num?)?.toDouble(),
      windDirectionDeg: (fCurrent?['wind_direction_10m'] as num?)?.toDouble(),
    );
  }
}
