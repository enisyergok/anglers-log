import 'package:latlong2/latlong.dart';

/// A downloadable offline map region (PMTiles package for Turkish waters).
///
/// Packages are produced offline by `scripts/map-data/` (GEBCO/EMODnet +
/// OpenSeaMap) and hosted or sideloaded as `.pmtiles` files.
class OfflineMapRegion {
  /// Stable id used for filenames and preferences.
  final String id;

  /// Turkish display name.
  final String nameTr;

  /// Short description shown in the region manager.
  final String descriptionTr;

  /// Suggested map center when activating this region.
  final LatLng center;

  /// Suggested initial zoom.
  final double initialZoom;

  /// Approximate bounding box (south-west / north-east) for UI only.
  final LatLng sw;
  final LatLng ne;

  /// Optional remote URL for the regional base/bathymetry PMTiles file.
  /// When null, the user can only import a local file.
  final String? downloadUrl;

  /// Local file name under the app's map-regions directory.
  final String fileName;

  const OfflineMapRegion({
    required this.id,
    required this.nameTr,
    required this.descriptionTr,
    required this.center,
    required this.initialZoom,
    required this.sw,
    required this.ne,
    required this.fileName,
    this.downloadUrl,
  });

  /// Built-in Turkish sea regions (Faz 1 catalog).
  static const List<OfflineMapRegion> catalog = [
    OfflineMapRegion(
      id: 'marmara',
      nameTr: 'Marmara Denizi',
      descriptionTr:
          'Marmara kıyıları — derinlik ısı haritası + seamark (çevrimiçi).',
      center: LatLng(40.75, 28.15),
      initialZoom: 8.5,
      sw: LatLng(40.2, 26.5),
      ne: LatLng(41.4, 30.0),
      fileName: 'marmara.pmtiles',
      // Filled when a hosted package exists; until then use "Dosyadan içe aktar".
      downloadUrl: null,
    ),
    OfflineMapRegion(
      id: 'ege',
      nameTr: 'Ege Denizi',
      descriptionTr: 'Ege kıyıları — bölgesel çevrimdışı paket.',
      center: LatLng(38.4, 26.5),
      initialZoom: 7.5,
      sw: LatLng(36.0, 25.0),
      ne: LatLng(40.8, 28.5),
      fileName: 'ege.pmtiles',
      downloadUrl: null,
    ),
    OfflineMapRegion(
      id: 'karadeniz',
      nameTr: 'Karadeniz',
      descriptionTr: 'Karadeniz kıyıları — bölgesel çevrimdışı paket.',
      center: LatLng(41.5, 35.0),
      initialZoom: 7.0,
      sw: LatLng(40.8, 27.5),
      ne: LatLng(42.5, 42.0),
      fileName: 'karadeniz.pmtiles',
      downloadUrl: null,
    ),
    OfflineMapRegion(
      id: 'akdeniz',
      nameTr: 'Akdeniz',
      descriptionTr: 'Akdeniz kıyıları — bölgesel çevrimdışı paket.',
      center: LatLng(36.5, 32.0),
      initialZoom: 7.0,
      sw: LatLng(35.5, 27.0),
      ne: LatLng(37.5, 36.5),
      fileName: 'akdeniz.pmtiles',
      downloadUrl: null,
    ),
  ];

  static OfflineMapRegion? byId(String? id) {
    if (id == null) {
      return null;
    }
    for (final region in catalog) {
      if (region.id == id) {
        return region;
      }
    }
    return null;
  }
}
