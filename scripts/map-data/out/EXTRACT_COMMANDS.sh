#!/usr/bin/env bash
# Requires: https://github.com/protomaps/go-pmtiles/releases
# Pick a daily basemap from https://maps.protomaps.com/builds
set -euo pipefail
SRC="${1:-https://build.protomaps.com/20260730.pmtiles}"

pmtiles extract "$SRC" "marmara.pmtiles" --bbox=26.5,40.2,30.0,41.4 --maxzoom=12
pmtiles extract "$SRC" "ege.pmtiles" --bbox=25.0,36.0,28.5,40.8 --maxzoom=11
pmtiles extract "$SRC" "karadeniz.pmtiles" --bbox=27.5,40.8,42.0,42.5 --maxzoom=11
pmtiles extract "$SRC" "akdeniz.pmtiles" --bbox=27.0,35.5,36.5,37.5 --maxzoom=11

# Then: app → Çevrimdışı Harita Bölgeleri → Dosyadan aktar