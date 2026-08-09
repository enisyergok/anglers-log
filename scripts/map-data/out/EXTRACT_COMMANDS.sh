#!/usr/bin/env bash
# Produce regional *.mbtiles (not PMTiles — app uses protobuf ^4).
# Example pipeline: GDAL GeoTIFF → gdal2tiles → mb-util → name.mbtiles
set -euo pipefail

# Region bboxes (west,south,east,north) — use with gdal_translate -projwin
# marmara: bbox=26.5,40.2,30.0,41.4 maxzoom=12 → marmara.mbtiles
# gdal_translate -projwin 26.5 41.4 30.0 40.2 source.tif marmara.tif
# ege: bbox=25.0,36.0,28.5,40.8 maxzoom=11 → ege.mbtiles
# gdal_translate -projwin 25.0 40.8 28.5 36.0 source.tif ege.tif
# karadeniz: bbox=27.5,40.8,42.0,42.5 maxzoom=11 → karadeniz.mbtiles
# gdal_translate -projwin 27.5 42.5 42.0 40.8 source.tif karadeniz.tif
# akdeniz: bbox=27.0,35.5,36.5,37.5 maxzoom=11 → akdeniz.mbtiles
# gdal_translate -projwin 27.0 37.5 36.5 35.5 source.tif akdeniz.tif

# Then: app → Çevrimdışı Harita Bölgeleri → Dosyadan aktar (.mbtiles)
