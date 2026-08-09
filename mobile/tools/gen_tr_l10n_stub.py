#!/usr/bin/env python3
"""Generate Turkish Flutter gen-l10n Dart files from ARB without Flutter SDK.

Clones method signatures from the English generated Dart file and fills string
bodies from the matching Turkish ARB. Also patches the parent localizations.dart
lookup / supportedLocales to include Locale('tr').

Usage:
  python tools/gen_tr_l10n_stub.py
  python tools/gen_tr_l10n_stub.py --also-adair
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

MOBILE_ROOT = Path(__file__).resolve().parents[1]
REPO_ROOT = MOBILE_ROOT.parents[1]  # fish/
ADAIR_ROOT = REPO_ROOT / "adair-flutter-lib"


def load_arb(path: Path) -> dict[str, str]:
    data = json.loads(path.read_text(encoding="utf-8"))
    return {k: v for k, v in data.items() if not k.startswith("@") and isinstance(v, str)}


def arb_to_dart_literal(arb_value: str, param_names: list[str]) -> str:
    """Convert an ARB message to a Dart single-quoted string literal (with quotes)."""
    # ICU apostrophe escape -> real apostrophe
    text = arb_value.replace("''", "'")

    # Protect placeholders before escaping $. Use ${name} when the next char
    # would otherwise extend the Dart identifier (e.g. {numOfYears}y).
    protected: dict[str, str] = {}
    for i, name in enumerate(sorted(param_names, key=len, reverse=True)):
        while True:
            m = re.search(re.escape("{" + name + "}"), text)
            if not m:
                break
            end = m.end()
            nxt = text[end] if end < len(text) else ""
            token = f"\0PH{i}_{m.start()}\0"
            if nxt and (nxt.isalnum() or nxt == "_"):
                protected[token] = f"${{{name}}}"
            else:
                protected[token] = f"${name}"
            text = text[: m.start()] + token + text[end:]

    # Escape for Dart single-quoted string
    text = text.replace("\\", "\\\\")
    text = text.replace("'", "\\'")
    text = text.replace("$", "\\$")
    text = text.replace("\n", "\\n")
    text = text.replace("\r", "\\r")

    for token, replacement in protected.items():
        text = text.replace(token, replacement)

    return f"'{text}'"


def parse_en_methods(en_dart: str, class_name: str) -> list[dict]:
    """Parse getters/methods from the primary EN localization class body."""
    # Extract primary class only (stop before any following top-level class).
    m2 = re.search(
        rf"class {re.escape(class_name)} extends \w+ \{{",
        en_dart,
    )
    if not m2:
        raise SystemExit(f"Could not find class {class_name}")
    rest = en_dart[m2.end() :]
    next_class = re.search(r"\nclass \w+", rest)
    body = rest[: next_class.start()] if next_class else rest
    # Strip the closing brace of the primary class.
    body = body.rsplit("}", 1)[0]

    methods: list[dict] = []
    seen: set[str] = set()
    # Match @override blocks for getters and methods
    pattern = re.compile(
        r"@override\s+"
        r"(?:String get (?P<getter>\w+)\s*=>|"
        r"String (?P<method>\w+)\((?P<params>[^)]*)\)\s*\{)",
        re.MULTILINE,
    )
    for match in pattern.finditer(body):
        if match.group("getter"):
            name = match.group("getter")
            kind = "getter"
            params: list[tuple[str, str]] = []
        else:
            name = match.group("method")
            kind = "method"
            params_raw = match.group("params").strip()
            params = []
            if params_raw:
                for part in params_raw.split(","):
                    part = part.strip()
                    if not part:
                        continue
                    type_name, param_name = part.rsplit(" ", 1)
                    params.append((type_name.strip(), param_name.strip()))
        if name in seen:
            continue
        seen.add(name)
        methods.append({"name": name, "kind": kind, "params": params})
    return methods


def emit_class(
    *,
    class_name: str,
    base_class: str,
    locale_code: str,
    language_label: str,
    methods: list[dict],
    translations: dict[str, str],
    import_parent: str,
) -> str:
    lines: list[str] = [
        "// ignore: unused_import",
        "import 'package:intl/intl.dart' as intl;",
        f"import '{import_parent}';",
        "",
        "// ignore_for_file: type=lint",
        "",
        f"/// The translations for {language_label} (`{locale_code}`).",
        f"class {class_name} extends {base_class} {{",
        f"  {class_name}([String locale = '{locale_code}']) : super(locale);",
        "",
    ]

    missing: list[str] = []
    for method in methods:
        name = method["name"]
        if name not in translations:
            missing.append(name)
            continue
        param_names = [p[1] for p in method["params"]]
        literal = arb_to_dart_literal(translations[name], param_names)

        lines.append("  @override")
        if method["kind"] == "getter":
            # Match Flutter gen-l10n wrapping style roughly
            if len(literal) > 70:
                lines.append(f"  String get {name} =>")
                lines.append(f"      {literal};")
            else:
                lines.append(f"  String get {name} => {literal};")
        else:
            params_sig = ", ".join(f"{t} {n}" for t, n in method["params"])
            lines.append(f"  String {name}({params_sig}) {{")
            lines.append(f"    return {literal};")
            lines.append("  }")
        lines.append("")

    if missing:
        raise SystemExit(
            f"Missing {len(missing)} translations for {class_name}: {missing[:10]}"
        )

    # Remove trailing blank line before closing brace
    while lines and lines[-1] == "":
        lines.pop()
    lines.append("}")
    lines.append("")
    return "\n".join(lines)


def patch_parent_localizations(
    path: Path,
    *,
    import_line: str,
    locale_entry: str,
    lang_code: str,
    lookup_case: str,
) -> None:
    text = path.read_text(encoding="utf-8")

    if import_line not in text:
        # Insert after last sibling localization import
        if "adair_flutter_lib_localizations_" in import_line:
            text = re.sub(
                r"(import 'adair_flutter_lib_localizations_\w+\.dart';\n)"
                r"(?!import 'adair_flutter_lib_localizations_)",
                rf"\1{import_line}\n",
                text,
                count=1,
            )
        else:
            text = re.sub(
                r"(import 'localizations_\w+\.dart';\n)(?!import 'localizations_)",
                rf"\1{import_line}\n",
                text,
                count=1,
            )

    # supportedLocales
    if locale_entry not in text:
        text = re.sub(
            r"(static const List<Locale> supportedLocales = <Locale>\[\n)"
            r"((?:    Locale\([^\]]+\),\n)*)"
            r"(  \];)",
            rf"\1\2    {locale_entry},\n\3",
            text,
            count=1,
        )

    # isSupported language list
    text = re.sub(
        rf"(<String>\[[^\]]*?)('{lang_code}')?(\])",
        lambda m: m.group(0)
        if f"'{lang_code}'" in m.group(0)
        else m.group(1).rstrip()
        + ("" if m.group(1).rstrip().endswith("[") else ", ")
        + f"'{lang_code}'"
        + m.group(3)
        if "<String>" in m.group(0)
        else m.group(0),
        text,
        count=1,
    )
    # More reliable isSupported patch:
    text = re.sub(
        r"(bool isSupported\(Locale locale\) =>\s*<String>\[)([^\]]+)(\]\.contains)",
        lambda m: m.group(1)
        + (
            m.group(2)
            if f"'{lang_code}'" in m.group(2)
            else m.group(2).rstrip() + f", '{lang_code}'"
        )
        + m.group(3),
        text,
        count=1,
    )

    # lookup switch (language-only)
    if lookup_case not in text:
        text = re.sub(
            r"(// Lookup logic when only language code is specified\.\s*"
            r"switch \(locale\.languageCode\) \{\n)"
            r"((?:    case '[^']+':\n      return \w+\(\);\n)*)",
            rf"\1\2{lookup_case}\n",
            text,
            count=1,
        )

    path.write_text(text, encoding="utf-8")
    print(f"Patched {path}")


def generate_pair(
    *,
    arb_path: Path,
    en_dart_path: Path,
    out_dart_path: Path,
    parent_path: Path,
    en_class: str,
    tr_class: str,
    base_class: str,
    import_parent: str,
    import_tr: str,
    language_label: str,
) -> None:
    translations = load_arb(arb_path)
    en_text = en_dart_path.read_text(encoding="utf-8")
    methods = parse_en_methods(en_text, en_class)
    print(f"{en_class}: parsed {len(methods)} methods; arb has {len(translations)} keys")

    out = emit_class(
        class_name=tr_class,
        base_class=base_class,
        locale_code="tr",
        language_label=language_label,
        methods=methods,
        translations=translations,
        import_parent=import_parent,
    )
    out_dart_path.write_text(out, encoding="utf-8")
    print(f"Wrote {out_dart_path}")

    patch_parent_localizations(
        parent_path,
        import_line=import_tr,
        locale_entry="Locale('tr')",
        lang_code="tr",
        lookup_case=f"    case 'tr':\n      return {tr_class}();",
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--also-adair",
        action="store_true",
        help="Also generate adair_flutter_lib Turkish gen files",
    )
    args = parser.parse_args()

    generate_pair(
        arb_path=MOBILE_ROOT / "lib/l10n/localizations_tr.arb",
        en_dart_path=MOBILE_ROOT / "lib/l10n/gen/localizations_en.dart",
        out_dart_path=MOBILE_ROOT / "lib/l10n/gen/localizations_tr.dart",
        parent_path=MOBILE_ROOT / "lib/l10n/gen/localizations.dart",
        en_class="AnglersLogLocalizationsEn",
        tr_class="AnglersLogLocalizationsTr",
        base_class="AnglersLogLocalizations",
        import_parent="localizations.dart",
        import_tr="import 'localizations_tr.dart';",
        language_label="Turkish",
    )

    # Update map attribution strings in TR ARB (and regenerate TR dart getters
    # for those keys if ARB was already loaded — caller should update ARB first).
    if args.also_adair:
        generate_pair(
            arb_path=ADAIR_ROOT / "lib/l10n/adair_flutter_lib_tr.arb",
            en_dart_path=ADAIR_ROOT
            / "lib/l10n/gen/adair_flutter_lib_localizations_en.dart",
            out_dart_path=ADAIR_ROOT
            / "lib/l10n/gen/adair_flutter_lib_localizations_tr.dart",
            parent_path=ADAIR_ROOT
            / "lib/l10n/gen/adair_flutter_lib_localizations.dart",
            en_class="AdairFlutterLibLocalizationsEn",
            tr_class="AdairFlutterLibLocalizationsTr",
            base_class="AdairFlutterLibLocalizations",
            import_parent="adair_flutter_lib_localizations.dart",
            import_tr="import 'adair_flutter_lib_localizations_tr.dart';",
            language_label="Turkish",
        )

    return 0


if __name__ == "__main__":
    sys.exit(main())
