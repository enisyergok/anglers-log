import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/localizations.dart';

import 'sf_localizations_en_override.dart';
import 'sf_localizations_es_override.dart';
import 'sf_localizations_tr_override.dart';

class SfLocalizationsOverrideDelegate
    extends LocalizationsDelegate<SfLocalizations> {
  const SfLocalizationsOverrideDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'es', 'tr'].contains(locale.languageCode);

  @override
  Future<SfLocalizations> load(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return SynchronousFuture<SfLocalizations>(SfLocalizationsEnOverride());
      case 'es':
        return SynchronousFuture<SfLocalizations>(SfLocalizationsEsOverride());
      case 'tr':
        return SynchronousFuture<SfLocalizations>(SfLocalizationsTrOverride());
    }
    throw FlutterError('Unsupported locale "$locale".');
  }

  @override
  bool shouldReload(LocalizationsDelegate<SfLocalizations> old) => false;
}
