import 'package:adair_flutter_lib/utils/snack_bar.dart';
import 'package:adair_flutter_lib/wrappers/io_wrapper.dart';
import 'package:flutter/cupertino.dart';

import '../../utils/string_utils.dart';
import '../wrappers/url_launcher_wrapper.dart';

Future<void> launchStore(BuildContext context) async {
  var launcher = UrlLauncherWrapper.of(context);

  // No public App Store listing for this app yet, so this URL is
  // intentionally invalid; canLaunch below will fail gracefully and show
  // `error` instead of misdirecting users to rate a different app.
  var url = "itms-apps://apps.apple.com/app/id0?action=write-review";
  var error = Strings.of(context).morePageRateErrorApple;
  if (IoWrapper.get.isAndroid) {
    url = "https://play.google.com/store/apps/details?id=com.mera.asistani";
    error = Strings.of(context).morePageRateErrorAndroid;
  }

  if (await launcher.canLaunch(url)) {
    launcher.launch(url);
  } else if (context.mounted) {
    showErrorSnackBar(context, error);
  }
}
