import 'package:csv/csv.dart';
import 'package:flutter/material.dart';

import '../app_manager.dart';

class CsvWrapper {
  static CsvWrapper of(BuildContext context) => AppManager.get.csvWrapper;

  const CsvWrapper();

  String convert(List<List?>? rows) => const ListToCsvConverter().convert(rows);
}

/// A top-level function, safe to pass to [IsolatesWrapper.computeCsv], that
/// converts CSV rows to their string representation off the main isolate.
String csvConvert(List<List<String>> rows) =>
    const ListToCsvConverter().convert(rows);
