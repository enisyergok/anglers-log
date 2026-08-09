from pathlib import Path

out = Path(__file__).resolve().parents[1] / "assets" / "fish"
out.mkdir(parents=True, exist_ok=True)

fish = [
    ("cipura", "#C9D6DE", "#27D46C", "deep"),
    ("levrek", "#B7C5CE", "#1198EE", "bass"),
    ("mercan", "#D4A574", "#FF514B", "spotty"),
    ("lufer", "#7FA8C4", "#1198EE", "bluefish"),
    ("cinekop", "#8BB3C9", "#6F8793", "bluefish_young"),
    ("sarikanat", "#A8C4B0", "#FFD22F", "bluefish_young"),
    ("palamut", "#6E8FA8", "#FF514B", "bonito"),
    ("torik", "#5E7F99", "#FFD22F", "bonito_big"),
    ("orkinos", "#4A6B86", "#1198EE", "tuna"),
    ("uskumru", "#7A96A8", "#193947", "mackerel"),
    ("kolyoz", "#89A3B2", "#6F8793", "mackerel"),
    ("hamsi", "#AFC2CE", "#1198EE", "tiny"),
    ("sardalya", "#B8C9D2", "#27D46C", "sardine"),
    ("caca", "#B0BFC8", "#8FA0AA", "tiny"),
    ("istavrit", "#9BB0BE", "#FFD22F", "jack"),
    ("barbun", "#D08A6A", "#FF514B", "mullet_red"),
    ("tekir", "#C9876E", "#FFD22F", "mullet_red"),
    ("mezgit", "#C5CED4", "#8FA0AA", "whiting"),
    ("kalkan", "#B8B09E", "#6F8793", "turbot"),
    ("dil", "#C9BEA8", "#A8B8C2", "sole"),
    ("karagoz", "#A9B7C0", "#02111B", "bream_dark"),
    ("sargoz", "#C2CDD4", "#27D46C", "bream"),
    ("mirmir", "#B7C0C7", "#6F8793", "bream_long"),
    ("kupes", "#AEBCC4", "#1198EE", "bream_slim"),
    ("izmarit", "#AAB8C1", "#FFD22F", "picarel"),
    ("orfoz", "#8E9AA3", "#FF514B", "grouper"),
    ("lahos", "#7F8D97", "#FFD22F", "grouper"),
    ("sinagrit", "#9AAAB4", "#1198EE", "dentex"),
    ("fangri", "#B59A7A", "#FF514B", "dentex"),
    ("akya", "#8FA8B8", "#27D46C", "leerfish"),
    ("kefal", "#A7B6BF", "#6F8793", "mullet"),
    ("zargana", "#9EB2BD", "#1198EE", "needle"),
    ("iskorpit", "#C08A6E", "#FF514B", "scorpion"),
    ("kirlangic", "#B89A78", "#FFD22F", "gurnard"),
    ("minakop", "#9EAEB8", "#1198EE", "drum"),
    ("eskina", "#95A5B0", "#6F8793", "drum"),
    ("granyoz", "#8798A4", "#27D46C", "meagre"),
    ("vatoz", "#8A9088", "#6F8793", "ray"),
    ("kalamar", "#9AA7B0", "#1198EE", "squid"),
    ("ahtapot", "#8B7A90", "#FF514B", "octopus"),
    ("karides", "#D4A090", "#FF514B", "shrimp"),
    ("istakoz", "#B86A5A", "#FF514B", "lobster"),
    ("lipsoz", "#A0AEB6", "#8FA0AA", "wrasse"),
    ("gelincik", "#B0A090", "#6F8793", "weasel"),
    ("horozbina", "#A89880", "#FFD22F", "blenny"),
    ("kayabaligi", "#9A9E90", "#6F8793", "goby"),
    ("ispendek", "#B2C0C8", "#27D46C", "bream"),
    ("melanur", "#8E9BA4", "#02111B", "bream_dark"),
    ("lafina", "#A8B5BC", "#1198EE", "bass"),
    ("pacoz", "#9CA8B0", "#6F8793", "bass"),
    ("gumus", "#D0D8DE", "#1198EE", "silverside"),
    ("trakonya", "#A89878", "#FF514B", "weever"),
    ("diger", "#9AA7B0", "#6F8793", "generic"),
]


def wrap(inner: str) -> str:
    return (
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 240 100" fill="none">\n'
        f"  {inner}\n"
        "</svg>\n"
    )


def eye(x: int, y: int) -> str:
    return f'<circle cx="{x}" cy="{y}" r="3.2" fill="#02111B"/>'


def svg_for(fill: str, accent: str, style: str) -> str:
    if style == "deep":
        return wrap(
            f'<ellipse cx="120" cy="52" rx="88" ry="28" fill="{fill}"/>'
            f'<path d="M40 52 L8 30 L8 74 Z" fill="{accent}" opacity=".55"/>'
            f'<path d="M95 28 Q120 12 145 28" stroke="{accent}" stroke-width="3" fill="none"/>'
            + eye(175, 46)
        )
    if style == "bass":
        return wrap(
            f'<ellipse cx="118" cy="50" rx="92" ry="22" fill="{fill}"/>'
            f'<path d="M35 50 L5 28 L12 50 L5 72 Z" fill="{accent}" opacity=".5"/>'
            f'<path d="M150 22 L170 50 L150 78" stroke="{accent}" stroke-width="4" fill="none"/>'
            '<path d="M70 40 H140" stroke="#6F8793" stroke-width="1.5"/>'
            '<path d="M70 50 H145" stroke="#6F8793" stroke-width="1.5"/>'
            '<path d="M70 60 H138" stroke="#6F8793" stroke-width="1.5"/>'
            + eye(178, 44)
        )
    if style == "spotty":
        return wrap(
            f'<ellipse cx="120" cy="54" rx="78" ry="30" fill="{fill}"/>'
            f'<path d="M48 54 L14 36 L18 54 L14 72 Z" fill="{accent}" opacity=".45"/>'
            f'<circle cx="100" cy="48" r="5" fill="{accent}" opacity=".85"/>'
            f'<circle cx="118" cy="58" r="4" fill="{accent}" opacity=".7"/>'
            f'<circle cx="136" cy="46" r="4.5" fill="{accent}" opacity=".75"/>'
            '<path d="M90 28 Q120 8 150 28" stroke="#FFD22F" stroke-width="2.5" fill="none"/>'
            + eye(168, 48)
        )
    if style in ("bluefish", "bluefish_young"):
        mark = (
            f'<path d="M90 36 Q120 50 150 36" stroke="{accent}" stroke-width="2" fill="none"/>'
            if style == "bluefish_young"
            else '<path d="M70 42 H160 M70 58 H155" stroke="#6F8793" stroke-width="1.4"/>'
        )
        return wrap(
            f'<path d="M28 50 C55 28 95 22 140 28 C175 34 195 42 210 50 C195 58 175 66 140 72 C95 78 55 72 28 50 Z" fill="{fill}"/>'
            f'<path d="M28 50 L4 30 L10 50 L4 70 Z" fill="{accent}" opacity=".55"/>'
            f'<path d="M185 44 L200 50 L185 56" stroke="{accent}" stroke-width="2.5" fill="none"/>'
            + mark
            + eye(188, 46)
        )
    if style in ("bonito", "bonito_big", "tuna"):
        ry = {"bonito": 20, "bonito_big": 24, "tuna": 28}[style]
        rx = {"bonito": 95, "bonito_big": 98, "tuna": 100}[style]
        finlets = "".join(
            f'<circle cx="{x}" cy="32" r="2" fill="{accent}"/>' for x in (150, 160, 170)
        )
        return wrap(
            f'<ellipse cx="120" cy="50" rx="{rx}" ry="{ry}" fill="{fill}"/>'
            + finlets
            + f'<path d="M40 50 L8 36 L14 50 L8 64 Z" fill="{accent}" opacity=".5"/>'
            f'<path d="M70 40 Q110 34 160 42" stroke="{accent}" stroke-width="2.5" fill="none"/>'
            + eye(190, 45)
        )
    if style == "mackerel":
        waves = "".join(
            f'<path d="M{x} 34 Q{x + 10} 28 {x + 20} 34" stroke="{accent}" stroke-width="2" fill="none"/>'
            for x in range(60, 160, 22)
        )
        return wrap(
            f'<ellipse cx="120" cy="50" rx="96" ry="18" fill="{fill}"/>'
            + waves
            + f'<path d="M30 50 L6 32 L12 50 L6 68 Z" fill="{accent}" opacity=".5"/>'
            + eye(190, 45)
        )
    if style in ("tiny", "sardine", "silverside"):
        return wrap(
            f'<ellipse cx="120" cy="50" rx="70" ry="12" fill="{fill}"/>'
            f'<path d="M55 50 L30 40 L34 50 L30 60 Z" fill="{accent}" opacity=".5"/>'
            f'<path d="M80 50 H160" stroke="{accent}" stroke-width="1.5" opacity=".7"/>'
            + eye(170, 47)
        )
    if style == "jack":
        return wrap(
            f'<ellipse cx="120" cy="50" rx="90" ry="20" fill="{fill}"/>'
            f'<path d="M100 42 L160 42 L160 58 L100 58 Z" fill="{accent}" opacity=".25"/>'
            f'<path d="M35 50 L8 34 L14 50 L8 66 Z" fill="{accent}" opacity=".5"/>'
            + eye(185, 45)
        )
    if style == "mullet_red":
        return wrap(
            f'<ellipse cx="120" cy="52" rx="80" ry="22" fill="{fill}"/>'
            f'<path d="M175 60 Q180 70 170 74" stroke="{accent}" stroke-width="2" fill="none"/>'
            f'<path d="M182 58 Q190 68 178 74" stroke="{accent}" stroke-width="2" fill="none"/>'
            f'<path d="M70 42 H150 M70 52 H155 M70 62 H148" stroke="{accent}" stroke-width="1.5" opacity=".6"/>'
            f'<path d="M45 52 L18 38 L22 52 L18 66 Z" fill="{accent}" opacity=".45"/>'
            + eye(175, 46)
        )
    if style == "whiting":
        return wrap(
            f'<ellipse cx="120" cy="50" rx="95" ry="16" fill="{fill}"/>'
            f'<path d="M185 55 L195 62" stroke="{accent}" stroke-width="2"/>'
            f'<path d="M30 50 L6 36 L12 50 L6 64 Z" fill="{accent}" opacity=".45"/>'
            + eye(188, 45)
        )
    if style == "turbot":
        return wrap(
            f'<ellipse cx="120" cy="50" rx="70" ry="40" fill="{fill}"/>'
            '<circle cx="150" cy="42" r="3" fill="#02111B"/>'
            '<circle cx="138" cy="38" r="3" fill="#02111B"/>'
            f'<circle cx="100" cy="50" r="4" fill="{accent}" opacity=".4"/>'
            f'<circle cx="120" cy="58" r="3" fill="{accent}" opacity=".35"/>'
        )
    if style == "sole":
        return wrap(
            f'<ellipse cx="120" cy="50" rx="95" ry="26" fill="{fill}"/>'
            '<circle cx="185" cy="42" r="2.8" fill="#02111B"/>'
            '<circle cx="175" cy="38" r="2.5" fill="#02111B"/>'
            f'<path d="M40 35 Q120 22 200 35" stroke="{accent}" stroke-width="2" fill="none"/>'
        )
    if style in ("bream", "bream_dark", "bream_long", "bream_slim"):
        ry = {"bream": 30, "bream_dark": 28, "bream_long": 22, "bream_slim": 20}[style]
        blotch = (
            f'<circle cx="95" cy="50" r="7" fill="{accent}" opacity=".55"/>'
            if "dark" in style
            else f'<path d="M90 28 Q120 10 150 28" stroke="{accent}" stroke-width="3" fill="none"/>'
        )
        return wrap(
            f'<ellipse cx="120" cy="52" rx="82" ry="{ry}" fill="{fill}"/>'
            + blotch
            + f'<path d="M45 52 L16 36 L20 52 L16 68 Z" fill="{accent}" opacity=".4"/>'
            + eye(170, 46)
        )
    if style == "grouper":
        mott = "".join(
            f'<circle cx="{x}" cy="{y}" r="4" fill="{accent}" opacity=".35"/>'
            for x, y in ((80, 40), (100, 60), (120, 42), (140, 58))
        )
        return wrap(
            f'<ellipse cx="115" cy="52" rx="85" ry="34" fill="{fill}"/>'
            f'<path d="M175 55 Q190 58 178 65" stroke="{accent}" stroke-width="3" fill="none"/>'
            + mott
            + f'<path d="M40 52 L10 34 L16 52 L10 70 Z" fill="{accent}" opacity=".4"/>'
            + eye(172, 44)
        )
    if style == "dentex":
        return wrap(
            f'<ellipse cx="120" cy="50" rx="88" ry="26" fill="{fill}"/>'
            f'<path d="M185 52 L198 48 L185 56 Z" fill="{accent}"/>'
            f'<path d="M90 28 Q125 8 155 28" stroke="{accent}" stroke-width="3" fill="none"/>'
            f'<path d="M38 50 L8 32 L14 50 L8 68 Z" fill="{accent}" opacity=".45"/>'
            + eye(175, 44)
        )
    if style == "leerfish":
        return wrap(
            f'<path d="M25 50 C60 24 110 20 160 28 C190 34 210 42 220 50 C210 58 190 66 160 72 C110 80 60 76 25 50 Z" fill="{fill}"/>'
            f'<path d="M70 42 H180" stroke="{accent}" stroke-width="3"/>'
            f'<path d="M25 50 L2 28 L8 50 L2 72 Z" fill="{accent}" opacity=".5"/>'
            + eye(195, 45)
        )
    if style == "mullet":
        stripes = "".join(
            f'<path d="M60 {y} H170" stroke="{accent}" stroke-width="1.5" opacity=".5"/>'
            for y in (40, 48, 56)
        )
        return wrap(
            f'<ellipse cx="120" cy="50" rx="90" ry="20" fill="{fill}"/>'
            + stripes
            + f'<path d="M35 50 L8 36 L14 50 L8 64 Z" fill="{accent}" opacity=".45"/>'
            + eye(185, 45)
        )
    if style == "needle":
        return wrap(
            f'<ellipse cx="120" cy="50" rx="105" ry="8" fill="{fill}"/>'
            f'<path d="M210 50 L238 48 L238 52 Z" fill="{accent}"/>'
            f'<path d="M20 50 L2 40 L6 50 L2 60 Z" fill="{accent}" opacity=".5"/>'
            + eye(200, 47)
        )
    if style == "scorpion":
        spines = "".join(
            f'<path d="M{x} 35 L{x + 4} 12 L{x + 8} 35" fill="{accent}" opacity=".7"/>'
            for x in (90, 110, 130, 150)
        )
        return wrap(
            f'<ellipse cx="120" cy="55" rx="70" ry="28" fill="{fill}"/>'
            + spines
            + f'<path d="M55 55 L28 42 L34 55 L28 68 Z" fill="{accent}" opacity=".45"/>'
            + eye(165, 48)
        )
    if style == "gurnard":
        return wrap(
            f'<ellipse cx="125" cy="52" rx="75" ry="24" fill="{fill}"/>'
            f'<path d="M80 52 Q100 20 140 28 Q120 52 80 52 Z" fill="{accent}" opacity=".35"/>'
            f'<path d="M55 52 L28 40 L34 52 L28 64 Z" fill="{accent}" opacity=".45"/>'
            + eye(175, 46)
        )
    if style in ("drum", "meagre"):
        return wrap(
            f'<ellipse cx="120" cy="50" rx="92" ry="24" fill="{fill}"/>'
            f'<path d="M185 58 Q192 68 180 72" stroke="{accent}" stroke-width="2.5" fill="none"/>'
            f'<path d="M85 30 Q120 12 150 30" stroke="{accent}" stroke-width="3" fill="none"/>'
            f'<path d="M35 50 L8 34 L14 50 L8 66 Z" fill="{accent}" opacity=".45"/>'
            + eye(180, 44)
        )
    if style == "ray":
        return wrap(
            f'<ellipse cx="110" cy="50" rx="70" ry="38" fill="{fill}"/>'
            f'<path d="M40 50 Q70 15 110 20 Q150 15 180 50 Q150 85 110 80 Q70 85 40 50 Z" fill="{fill}"/>'
            f'<path d="M180 50 L230 55 L180 60 Z" fill="{accent}" opacity=".5"/>'
            '<circle cx="125" cy="42" r="3" fill="#02111B"/>'
        )
    if style == "squid":
        tent = "".join(
            f'<path d="M130 50 Q{160 + i * 8} {35 + i * 5} {200 + i * 4} {30 + i * 8}" stroke="{accent}" stroke-width="2.2" fill="none"/>'
            for i in range(5)
        )
        return wrap(
            f'<ellipse cx="90" cy="50" rx="50" ry="22" fill="{fill}"/>'
            + tent
            + f'<path d="M50 35 Q90 18 130 35" stroke="{accent}" stroke-width="2" fill="none"/>'
            + eye(110, 48)
        )
    if style == "octopus":
        arms = "".join(
            f'<path d="M120 50 Q{80 + i * 15} 70 {60 + i * 20} 90" stroke="{accent}" stroke-width="3.5" fill="none" opacity=".8"/>'
            for i in range(6)
        )
        return wrap(
            f'<ellipse cx="120" cy="38" rx="36" ry="28" fill="{fill}"/>'
            + arms
            + eye(108, 36)
            + eye(132, 36)
        )
    if style == "shrimp":
        return wrap(
            f'<path d="M60 55 Q90 30 140 40 Q170 48 190 55 Q170 62 140 68 Q90 75 60 55 Z" fill="{fill}"/>'
            f'<path d="M185 50 L230 30 M185 52 L225 45" stroke="{accent}" stroke-width="1.8" fill="none"/>'
            f'<path d="M60 55 L30 40 L35 55 L30 70 Z" fill="{accent}" opacity=".5"/>'
            + eye(175, 50)
        )
    if style == "lobster":
        return wrap(
            f'<ellipse cx="110" cy="50" rx="55" ry="24" fill="{fill}"/>'
            f'<path d="M155 40 L210 25 L200 45 Z" fill="{accent}"/>'
            f'<path d="M155 60 L210 75 L200 55 Z" fill="{accent}"/>'
            f'<path d="M150 40 L200 20 M150 42 L195 35" stroke="{accent}" stroke-width="1.6" fill="none"/>'
            f'<path d="M60 50 L25 38 L30 50 L25 62 Z" fill="{accent}" opacity=".5"/>'
            + eye(145, 44)
        )
    if style == "wrasse":
        return wrap(
            f'<ellipse cx="120" cy="52" rx="80" ry="26" fill="{fill}"/>'
            f'<ellipse cx="175" cy="55" rx="10" ry="6" fill="{accent}" opacity=".45"/>'
            f'<path d="M80 30 Q120 12 155 30" stroke="{accent}" stroke-width="3" fill="none"/>'
            f'<path d="M48 52 L18 38 L24 52 L18 66 Z" fill="{accent}" opacity=".4"/>'
            + eye(168, 46)
        )
    if style == "weasel":
        spots = "".join(
            f'<circle cx="{x}" cy="50" r="3" fill="{accent}" opacity=".5"/>'
            for x in (80, 100, 120, 140)
        )
        return wrap(
            f'<ellipse cx="120" cy="50" rx="88" ry="18" fill="{fill}"/>'
            + spots
            + f'<path d="M38 50 L10 36 L16 50 L10 64 Z" fill="{accent}" opacity=".45"/>'
            + eye(180, 45)
        )
    if style == "blenny":
        return wrap(
            f'<ellipse cx="120" cy="55" rx="70" ry="22" fill="{fill}"/>'
            f'<path d="M100 40 L120 18 L140 40" fill="{accent}" opacity=".6"/>'
            f'<path d="M55 55 L30 44 L36 55 L30 66 Z" fill="{accent}" opacity=".45"/>'
            + eye(165, 48)
        )
    if style == "goby":
        return wrap(
            f'<ellipse cx="120" cy="55" rx="75" ry="20" fill="{fill}"/>'
            f'<ellipse cx="110" cy="72" rx="18" ry="6" fill="{accent}" opacity=".4"/>'
            f'<path d="M50 55 L25 44 L30 55 L25 66 Z" fill="{accent}" opacity=".45"/>'
            + eye(170, 48)
        )
    if style == "picarel":
        return wrap(
            f'<ellipse cx="120" cy="50" rx="85" ry="16" fill="{fill}"/>'
            f'<circle cx="100" cy="50" r="5" fill="{accent}" opacity=".55"/>'
            f'<path d="M40 50 L14 38 L20 50 L14 62 Z" fill="{accent}" opacity=".45"/>'
            + eye(180, 46)
        )
    if style == "weever":
        return wrap(
            f'<ellipse cx="120" cy="55" rx="85" ry="18" fill="{fill}"/>'
            f'<path d="M90 45 L100 20 L110 45" fill="{accent}" opacity=".7"/>'
            f'<path d="M40 55 L14 44 L20 55 L14 66 Z" fill="{accent}" opacity=".45"/>'
            + eye(180, 50)
        )
    return wrap(
        f'<ellipse cx="120" cy="50" rx="80" ry="22" fill="{fill}"/>'
        f'<path d="M45 50 L18 36 L24 50 L18 64 Z" fill="{accent}" opacity=".45"/>'
        + eye(170, 46)
    )


for slug, fill, accent, style in fish:
    (out / f"{slug}.svg").write_text(svg_for(fill, accent, style), encoding="utf-8")

print(f"wrote {len(fish)} svgs to {out}")
