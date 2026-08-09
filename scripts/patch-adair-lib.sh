#!/usr/bin/env bash
# Applies offline/local Pro + Firebase stubs onto a cloned adair-flutter-lib.
# Expected layout (from repo root):
#   ../adair-flutter-lib   (clone target)
#   scripts/adair-lib-stubs/lib/... (stub sources)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LIB_ROOT="${ADAIR_FLUTTER_LIB_PATH:-${REPO_ROOT}/../adair-flutter-lib}"
STUBS="${SCRIPT_DIR}/adair-lib-stubs"

if [[ ! -d "${LIB_ROOT}/lib" ]]; then
  echo "adair-flutter-lib not found at ${LIB_ROOT}" >&2
  exit 1
fi

echo "Patching adair-flutter-lib at ${LIB_ROOT}"
cp "${STUBS}/lib/managers/subscription_manager.dart" \
  "${LIB_ROOT}/lib/managers/subscription_manager.dart"
cp "${STUBS}/lib/utils/firebase_setup.dart" \
  "${LIB_ROOT}/lib/utils/firebase_setup.dart"
cp "${STUBS}/lib/wrappers/crashlytics_wrapper.dart" \
  "${LIB_ROOT}/lib/wrappers/crashlytics_wrapper.dart"
cp "${STUBS}/lib/wrappers/firebase_wrapper.dart" \
  "${LIB_ROOT}/lib/wrappers/firebase_wrapper.dart"
cp "${STUBS}/lib/wrappers/analytics_wrapper.dart" \
  "${LIB_ROOT}/lib/wrappers/analytics_wrapper.dart"
mkdir -p "${LIB_ROOT}/lib/l10n/gen"
cp "${STUBS}/lib/l10n/adair_flutter_lib_tr.arb" "${LIB_ROOT}/lib/l10n/" || true
if [[ -f "${STUBS}/lib/l10n/gen/adair_flutter_lib_localizations_tr.dart" ]]; then
  cp "${STUBS}/lib/l10n/gen/adair_flutter_lib_localizations_tr.dart" \
    "${LIB_ROOT}/lib/l10n/gen/"
fi
if [[ -f "${STUBS}/lib/l10n/gen/adair_flutter_lib_localizations.dart" ]]; then
  cp "${STUBS}/lib/l10n/gen/adair_flutter_lib_localizations.dart" \
    "${LIB_ROOT}/lib/l10n/gen/"
fi
echo "Done."
