# Bölgesel harita veri hattı (MBTiles)

Bu klasör, **çevrimdışı** harita paketlerinin üretim yeridir.
Online varsayılan (ücretsiz en iyi görüntü):

1. **Esri World Ocean Base** — deniz basemap
2. **EMODnet Bathymetry** (`emodnet:mean` / `multicolour` + `contours`) — Avrupa/Türkiye kıyı derinliği
3. **Esri Ocean Reference** — kontur / etiket
4. **OpenSeaMap seamarks** — şamandıra / fener

Uygulama paketleri `MapRegionManager` ile indirir veya dosyadan içe aktarır.

> **Not:** PMTiles yerine **MBTiles** kullanıyoruz — uygulama `protobuf ^4`
> gerektiriyor; `flutter_map_pmtiles` ise protobuf ^3 ile çakışıyordu.

## Hedef çıktı

| Dosya | Bölge |
|-------|--------|
| `marmara.mbtiles` | Marmara Denizi |
| `ege.mbtiles` | Ege Denizi |
| `karadeniz.mbtiles` | Karadeniz |
| `akdeniz.mbtiles` | Akdeniz |

## Kaynaklar (ücretsiz)

- **EMODnet Bathymetry** (birincil kıyı derinliği)
- GEBCO (küresel yedek)
- OpenSeaMap
- **S-57 ENC kullanma**

## Üretim (özet)

```text
1. Bölge bbox ile EMODnet/GEBCO GeoTIFF indir
2. Renk skalası ile raster üret (GDAL / QGIS)
3. gdal2tiles veya benzeri → XYZ PNG klasörü
4. mb-util / tippecanoe / rio-mbtiles → *.mbtiles
5. Uygulama: Dosyadan aktar (.mbtiles)
```

`build_region_packages.py` demo sığlık GeoJSON üretir.
Online HD katmanlar için uygulama kodu `map_utils.dart` + `default_mapbox_map.dart`.
