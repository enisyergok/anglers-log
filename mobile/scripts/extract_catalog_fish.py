"""
DEPRECATED for runtime assets.

Catalog grid extraction must NOT replace existing Siren fish artwork.
Visual source of truth remains:

  assets/fish/*.svg  (per-species silhouettes)
  assets/fish/cipura.webp | levrek.webp | mercan.webp  (Siren reference)

Do not run this script to overwrite those files.
"""

raise SystemExit(
    "Refusing to extract/replace fish assets. "
    "Keep existing project visuals (see SirenFishArt / TurkishSeaFishCatalog)."
)
