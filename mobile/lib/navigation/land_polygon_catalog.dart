import 'package:latlong2/latlong.dart';

/// Simplified land obstacles for Turkish coastal routing.
///
/// These are **approximate peninsulas/islands** used to keep A→B polylines
/// on water. They are not a full OSM coastline — replace later with region
/// GeoJSON packages when available.
class LandPolygonCatalog {
  LandPolygonCatalog._();

  /// All embedded land rings (lat/lng, CCW or CW — winding irrelevant).
  static List<List<LatLng>> get all => [
        kapidag,
        armutlu,
        gelibolu,
        marmaraAdasi,
        imrali,
        buyukada,
        heyeliada,
        istanbulAsyaUc,
        bodrum,
        datca,
        cesmeKaraburun,
        foca,
        bozcaada,
        sinop,
        trabzonBurnu,
      ];

  /// Kapıdağ (Erdek) — classic Bandırma/Erdek land cut.
  static final List<LatLng> kapidag = [
    const LatLng(40.52, 27.78),
    const LatLng(40.58, 27.82),
    const LatLng(40.62, 27.92),
    const LatLng(40.60, 28.02),
    const LatLng(40.52, 28.05),
    const LatLng(40.45, 27.98),
    const LatLng(40.43, 27.88),
    const LatLng(40.46, 27.80),
  ];

  /// Armutlu / Yalova peninsula tip.
  static final List<LatLng> armutlu = [
    const LatLng(40.48, 28.78),
    const LatLng(40.55, 28.85),
    const LatLng(40.58, 28.98),
    const LatLng(40.52, 29.08),
    const LatLng(40.45, 29.05),
    const LatLng(40.42, 28.92),
    const LatLng(40.44, 28.80),
  ];

  /// Gelibolu peninsula (south tip / Dardanelles side — coarse).
  static final List<LatLng> gelibolu = [
    const LatLng(40.05, 26.15),
    const LatLng(40.25, 26.25),
    const LatLng(40.45, 26.45),
    const LatLng(40.55, 26.70),
    const LatLng(40.40, 26.85),
    const LatLng(40.15, 26.65),
    const LatLng(40.00, 26.40),
    const LatLng(39.95, 26.20),
  ];

  static final List<LatLng> marmaraAdasi = [
    const LatLng(40.64, 27.52),
    const LatLng(40.68, 27.58),
    const LatLng(40.67, 27.68),
    const LatLng(40.62, 27.70),
    const LatLng(40.58, 27.64),
    const LatLng(40.58, 27.55),
  ];

  static final List<LatLng> imrali = [
    const LatLng(40.55, 28.50),
    const LatLng(40.58, 28.55),
    const LatLng(40.56, 28.60),
    const LatLng(40.52, 28.58),
    const LatLng(40.52, 28.52),
  ];

  /// Bodrum peninsula (coarse).
  static final List<LatLng> bodrum = [
    const LatLng(36.95, 27.20),
    const LatLng(37.10, 27.25),
    const LatLng(37.15, 27.45),
    const LatLng(37.05, 27.55),
    const LatLng(36.90, 27.50),
    const LatLng(36.85, 27.35),
  ];

  /// Datça peninsula.
  static final List<LatLng> datca = [
    const LatLng(36.68, 27.35),
    const LatLng(36.78, 27.45),
    const LatLng(36.80, 27.70),
    const LatLng(36.72, 27.85),
    const LatLng(36.62, 27.75),
    const LatLng(36.60, 27.50),
  ];

  /// Çeşme / Karaburun mass (coarse).
  static final List<LatLng> cesmeKaraburun = [
    const LatLng(38.25, 26.25),
    const LatLng(38.55, 26.35),
    const LatLng(38.70, 26.55),
    const LatLng(38.55, 26.75),
    const LatLng(38.30, 26.70),
    const LatLng(38.20, 26.45),
  ];

  static final List<LatLng> bozcaada = [
    const LatLng(39.82, 25.98),
    const LatLng(39.86, 26.02),
    const LatLng(39.85, 26.10),
    const LatLng(39.80, 26.12),
    const LatLng(39.78, 26.05),
  ];

  static final List<LatLng> sinop = [
    const LatLng(42.00, 35.05),
    const LatLng(42.08, 35.10),
    const LatLng(42.08, 35.22),
    const LatLng(42.00, 35.25),
    const LatLng(41.95, 35.15),
  ];

  /// Büyükada (Princes' Islands) — coarse.
  static final List<LatLng> buyukada = [
    const LatLng(40.845, 29.105),
    const LatLng(40.870, 29.115),
    const LatLng(40.880, 29.140),
    const LatLng(40.860, 29.155),
    const LatLng(40.840, 29.140),
    const LatLng(40.838, 29.115),
  ];

  /// Heybeliada — coarse.
  static final List<LatLng> heyeliada = [
    const LatLng(40.870, 29.075),
    const LatLng(40.885, 29.085),
    const LatLng(40.885, 29.100),
    const LatLng(40.870, 29.105),
    const LatLng(40.862, 29.090),
  ];

  /// İstanbul Asian tip / Kadıköy–Maltepe coastal block (coarse, keeps
  /// Marmara–Boğaz routes from cutting inland).
  static final List<LatLng> istanbulAsyaUc = [
    const LatLng(40.95, 29.02),
    const LatLng(41.02, 29.05),
    const LatLng(41.05, 29.15),
    const LatLng(40.98, 29.20),
    const LatLng(40.90, 29.15),
    const LatLng(40.90, 29.05),
  ];

  /// Foça peninsula tip.
  static final List<LatLng> foca = [
    const LatLng(38.64, 26.72),
    const LatLng(38.70, 26.74),
    const LatLng(38.72, 26.82),
    const LatLng(38.68, 26.88),
    const LatLng(38.62, 26.82),
  ];

  /// Trabzon cape / coastal bulge.
  static final List<LatLng> trabzonBurnu = [
    const LatLng(41.00, 39.65),
    const LatLng(41.05, 39.70),
    const LatLng(41.05, 39.80),
    const LatLng(41.00, 39.82),
    const LatLng(40.97, 39.72),
  ];
}
