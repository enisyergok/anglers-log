import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:flutter/material.dart';
import 'package:mobile/res/style.dart';

import '../../utils/string_utils.dart';

/// Local-backup notice. Cloud Google Sign-In is disabled for offline builds.
class CloudAuth extends StatelessWidget {
  final EdgeInsets? padding;

  const CloudAuth({this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? insetsZero,
      child: Text(
        Strings.of(context).cloudAuthDescription,
        style: stylePrimary(context),
      ),
    );
  }
}
