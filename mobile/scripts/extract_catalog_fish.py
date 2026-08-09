"""Extract per-species fish art from the Siren 8x8 catalog grid."""
from __future__ import annotations

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "reference" / "fish_species_catalog_8x8.png"
OUT = ROOT / "assets" / "fish"

# Row-major 8x8 → app slug. None = skip. Never cross-map species.
GRID: list[str | None] = [
    "cipura",
    "levrek",
    "mercan",
    "sinagrit",
    "tranca",
    "karagoz",
    "sargoz",
    "mirmir",
    "minakop",
    "eskina",
    "lahos",
    "orfoz",
    "granyoz",  # Grida / Epinephelus costae
    "barbun",
    "tekir",
    "kefal",
    "istavrit",
    "hamsi",
    "sardalya",
    "uskumru",
    "kolyoz",
    "palamut",
    "torik",
    "lufer",
    "cinekop",
    "kofana",
    "mezgit",
    "bakalyaro",
    "berlam",
    "kirlangic",
    "iskorpit",
    "kalkan",
    "dil",
    "trakonya",  # Pisi / Trachinus
    "dulger",
    "zargana",
    "gumus",
    "izmarit",
    "kupes",
    "melanur",
    "lahoz",
    "akya",
    "kilic",
    "orkinos",
    "tirsi",
    "caca",
    "horozbina",
    "gelincik",
    "kayabaligi",
    "vatoz",
    "ringa",
    "mersin",
    None,
    None,
    None,
    None,
    "laos",
    "sokar",
    "izmir_kaya",
    "mene",
    "sivri",
    "turna",
    "arapsaci",
    "mercan_siyah",
]


def extract_fish(cell: Image.Image) -> Image.Image:
    w, h = cell.size
    art = cell.crop((2, 1, w - 2, int(h * 0.64))).convert("RGBA")
    px = art.load()
    assert px is not None
    for y in range(art.height):
        for x in range(art.width):
            r, g, b, a = px[x, y]
            if r + g + b < 70:
                px[x, y] = (0, 0, 0, 0)
    bbox = art.getbbox()
    if bbox:
        art = art.crop(bbox)
    # Upscale for sharper UI on high-DPI screens
    art = art.resize((art.width * 3, art.height * 3), Image.Resampling.LANCZOS)
    pad = 8
    canvas = Image.new(
        "RGBA", (art.width + pad * 2, art.height + pad * 2), (0, 0, 0, 0)
    )
    canvas.paste(art, (pad, pad), art)
    return canvas


def main() -> None:
    if not SRC.exists():
        raise SystemExit(f"Missing catalog image: {SRC}")
    im = Image.open(SRC).convert("RGBA")
    w, h = im.size
    cols = rows = 8
    cw, ch = w / cols, h / rows
    OUT.mkdir(parents=True, exist_ok=True)
    written: list[str] = []
    for idx, slug in enumerate(GRID):
        if slug is None:
            continue
        r, c = divmod(idx, cols)
        box = (int(c * cw), int(r * ch), int((c + 1) * cw), int((r + 1) * ch))
        fish = extract_fish(im.crop(box))
        dest = OUT / f"{slug}.webp"
        fish.save(dest, "WEBP", quality=92, method=6)
        written.append(f"{slug}\t{fish.size[0]}x{fish.size[1]}\t{dest.stat().st_size}")
    (OUT / "_catalog_extract_log.txt").write_text("\n".join(written), encoding="utf-8")
    print(f"wrote {len(written)} webp assets to {OUT}")


if __name__ == "__main__":
    main()
