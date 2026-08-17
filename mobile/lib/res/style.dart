import 'package:adair_flutter_lib/app_config.dart';
import 'package:adair_flutter_lib/res/theme.dart';
import 'package:flutter/material.dart';

const FontWeight fontWeightBold = FontWeight.w500;

const TextStyle styleHeading = TextStyle(
  fontSize: 18,
  fontWeight: fontWeightBold,
);

const TextStyle styleHeadingSmall = TextStyle(
  fontSize: 14,
  fontWeight: fontWeightBold,
);

TextStyle styleHyperlink(BuildContext context) => stylePrimary(
  context,
).copyWith(color: Colors.blue, decoration: TextDecoration.underline);

TextStyle styleError(BuildContext context) =>
    stylePrimary(context).copyWith(color: Colors.red);

TextStyle styleWarning(BuildContext context) =>
    stylePrimary(context).copyWith(color: Colors.orange);

TextStyle styleSuccess(BuildContext context) =>
    stylePrimary(context).copyWith(color: Colors.green);

TextStyle styleSecondarySubtext(BuildContext context) =>
    TextStyle(fontSize: 13.0, color: styleSecondary(context).color);

TextStyle styleNote(BuildContext context) =>
    stylePrimary(context).copyWith(fontStyle: FontStyle.italic);

TextStyle stylePrimary(BuildContext context, {bool enabled = true}) {
  return Theme.of(context).textTheme.titleMedium!.copyWith(
    color: enabled
        ? Theme.of(context).textTheme.titleMedium!.color
        : Theme.of(context).disabledColor,
  );
}

TextStyle styleSecondary(BuildContext context) =>
    stylePrimary(context).copyWith(color: Colors.grey);

TextStyle styleSubtitle(BuildContext context, {bool enabled = true}) {
  return Theme.of(context).textTheme.titleSmall!.copyWith(
    color: enabled ? Colors.grey : Theme.of(context).disabledColor,
    fontWeight: FontWeight.normal,
  );
}

TextStyle styleListHeading(BuildContext context) {
  return Theme.of(
    context,
  ).textTheme.bodyLarge!.copyWith(color: AppConfig.get.colorAppTheme);
}

List<BoxShadow> boxShadowDefault(BuildContext context) {
  return [
    BoxShadow(
      color: context.colorBoxShadow,
      blurRadius: 1.0,
      offset: const Offset(0, 1.0),
    ),
  ];
}

/// Corner radius used for elevated, "Champions League"-style card surfaces
/// (stat tiles, summary cards). Kept distinct from [defaultBorderRadius] so
/// existing floating UI (buttons, sheets) is unaffected.
const double cardCornerRadius = 18.0;

const BorderRadius cardBorderRadius = BorderRadius.all(
  Radius.circular(cardCornerRadius),
);

/// A soft, multi-layer shadow used to give accent-colored cards a sense of
/// depth and polish. [accent] is blended into the shadow color so the glow
/// feels tied to the card rather than a generic drop shadow.
List<BoxShadow> boxShadowElevated(Color accent) {
  return [
    BoxShadow(
      color: accent.withValues(alpha: 0.35),
      blurRadius: 18.0,
      spreadRadius: -4.0,
      offset: const Offset(0, 10.0),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 8.0,
      offset: const Offset(0, 3.0),
    ),
  ];
}

/// A refined upward-cast shadow for surfaces anchored to the bottom of the
/// screen, such as the main navigation bar.
List<BoxShadow> boxShadowFloatingBar(BuildContext context) {
  return [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      blurRadius: 16.0,
      offset: const Offset(0, -4.0),
    ),
  ];
}
