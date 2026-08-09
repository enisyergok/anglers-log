#!/usr/bin/env python3
"""Produce a demo regional PMTiles stub + shallow GeoJSON for Balıkçı Günlüğü.

Full EMODnet/GEBCO heatmaps need GDAL + pmtiles CLI. This script:
  1. Writes Marmara shallow demo GeoJSON (matches NavGeo catalog).
  2. Documents how to extract a real basemap cutout with `pmtiles extract`.

Usage:
  python scripts/map-data/build_region_packages.py
"""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "out"
OUT.mkdir(exist_ok=True)

MARMARA_SHALLOW = {
    "type": "FeatureCollection",
    "features": [
        {
            "type": "Feature",
            "properties": {"name": "demo-shallow-1", "max_depth_m": 5},
            "geometry": {
                "type": "Polygon",
                "coordinates": [
                    [
                        [28.85, 40.95],
                        [29.05, 40.95],
                        [29.05, 40.85],
                        [28.85, 40.85],
                        [28.85, 40.95],
                    ]
                ],
            },
        },
        {
            "type": "Feature",
            "properties": {"name": "demo-shallow-2", "max_depth_m": 5},
            "geometry": {
                "type": "Polygon",
                "coordinates": [
                    [
                        [27.20, 40.40],
                        [27.45, 40.40],
                        [27.45, 40.28],
                        [27.20, 40.28],
                        [27.20, 40.40],
                    ]
                ],
            },
        },
    ],
}

REGIONS = {
    "marmara": {"bbox": "26.5,40.2,30.0,41.4", "maxzoom": 12},
    "ege": {"bbox": "25.0,36.0,28.5,40.8", "maxzoom": 11},
    "karadeniz": {"bbox": "27.5,40.8,42.0,42.5", "maxzoom": 11},
    "akdeniz": {"bbox": "27.0,35.5,36.5,37.5", "maxzoom": 11},
}


def main() -> None:
    geo = OUT / "marmara_shallow_demo.geojson"
    geo.write_text(json.dumps(MARMARA_SHALLOW, indent=2), encoding="utf-8")
    print(f"Wrote {geo}")

    guide = OUT / "EXTRACT_COMMANDS.sh"
    lines = [
        "#!/usr/bin/env bash",
        "# Requires: https://github.com/protomaps/go-pmtiles/releases",
        "# Pick a daily basemap from https://maps.protomaps.com/builds",
        "set -euo pipefail",
        'SRC="${1:-https://build.protomaps.com/20260730.pmtiles}"',
        "",
    ]
    for name, meta in REGIONS.items():
        lines.append(
            f'pmtiles extract "$SRC" "{name}.pmtiles" '
            f'--bbox={meta["bbox"]} --maxzoom={meta["maxzoom"]}'
        )
    lines.append("")
    lines.append("# Then: app → Çevrimdışı Harita Bölgeleri → Dosyadan aktar")
    guide.write_text("\n".join(lines), encoding="utf-8")
    print(f"Wrote {guide}")
    print("Done. For bathymetry heatmap rasters use GDAL + EMODnet/GEBCO (see README.md).")


if __name__ == "__main__":
    main()
