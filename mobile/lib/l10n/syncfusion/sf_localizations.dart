import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/localizations.dart';

import 'sf_localizations_en_override.dart';
import 'sf_localizations_es_override.dart';

class SfLocalizationsOverrideDelegate
    extends LocalizationsDelegate<SfLocalizations> {
  const SfLocalizationsOverrideDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<SfLocalizations> load(Locale locale) {
    switch (locale.languageCode) {
      case 'es':
        return SynchronousFuture<SfLocalizations>(SfLocalizationsEsOverride());
      default:
        // Fall back to English for locales that don't have a dedicated
        // override yet, rather than throwing and crashing app startup.
        return SynchronousFuture<SfLocalizations>(SfLocalizationsEnOverride());
    }
  }

  @override
  bool shouldReload(LocalizationsDelegate<SfLocalizations> old) => false;
}
