import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:adair_flutter_lib/wrappers/path_provider_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

/// "Balık almadım" konum bildirimi — yerel JSON.
class MeraNoCatchReport {
  final String id;
  final double? lat;
  final double? lng;
  final String? note;
  final int timestampMs;

  const MeraNoCatchReport({
    required this.id,
    this.lat,
    this.lng,
    this.note,
    required this.timestampMs,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    if (lat != null) 'lat': lat,
    if (lng != null) 'lng': lng,
    if (note != null) 'note': note,
    'timestampMs': timestampMs,
  };

  factory MeraNoCatchReport.fromJson(Map<String, dynamic> json) =>
      MeraNoCatchReport(
        id: json['id'] as String,
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
        note: json['note'] as String?,
        timestampMs: json['timestampMs'] as int,
      );
}

class MeraNoCatchManager {
  static const _fileName = 'mera_no_catch.json';

  static var _instance = MeraNoCatchManager._();
  static MeraNoCatchManager get get => _instance;

  @visibleForTesting
  static void set(MeraNoCatchManager m) => _instance = m;

  @visibleForTesting
  static void reset() => _instance = MeraNoCatchManager._();

  MeraNoCatchManager._();

  final _controller = StreamController<void>.broadcast();
  Stream<void> get stream => _controller.stream;

  List<MeraNoCatchReport> _items = [];
  var _loaded = false;

  List<MeraNoCatchReport> get items => List.unmodifiable(_items);

  Future<void> ensureLoaded() async {
    if (_loaded) {
      return;
    }
    try {
      final file = await _file();
      if (await file.exists()) {
        final raw = jsonDecode(await file.readAsString()) as List<dynamic>;
        _items = raw
            .map((e) => MeraNoCatchReport.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      _items = [];
    }
    _loaded = true;
  }

  Future<MeraNoCatchReport> add({
    double? lat,
    double? lng,
    String? note,
  }) async {
    await ensureLoaded();
    final report = MeraNoCatchReport(
      id: const Uuid().v4(),
      lat: lat,
      lng: lng,
      note: note,
      timestampMs: DateTime.now().millisecondsSinceEpoch,
    );
    _items = [report, ..._items];
    await _persist();
    _controller.add(null);
    return report;
  }

  Future<File> _file() async {
    final docs = await PathProviderWrapper.get.appDocumentsPath;
    return File(p.join(docs, _fileName));
  }

  Future<void> _persist() async {
    final file = await _file();
    await file.writeAsString(
      jsonEncode(_items.map((e) => e.toJson()).toList()),
    );
  }
}
