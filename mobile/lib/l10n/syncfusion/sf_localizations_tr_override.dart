import 'package:adair_flutter_lib/l10n/sf_localizations_en_base.dart';

/// Allows overriding of default text values in an [SfCalendar] widget
/// (Turkish).
class SfLocalizationsTrOverride extends SfLocalizationsEnBase {
  SfLocalizationsTrOverride();

  @override
  String get noEventsCalendarLabel => "Av veya gezi yok";
}
