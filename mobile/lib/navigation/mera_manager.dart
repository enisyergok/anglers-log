import 'dart:async';
import 'dart:convert';

import 'package:adair_flutter_lib/utils/log.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

/// Local-first fishing ground (mera) pin — target species, depth and bottom
/// type notes. Persisted entirely on-device; never leaves the phone.
class MeraSpot {
  final String id;
  final double lat;
  final double lng;
  final double? depthM;
  final String? bottomType;
  final String? note;
  final String? targetSpecies;
  final int timestampMs;

  const MeraSpot({
    required this.id,
    required this.lat,
    required this.lng,
    this.depthM,
    this.bottomType,
    this.note,
    this.targetSpecies,
    required this.timestampMs,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'lat': lat,
    'lng': lng,
    if (depthM != null) 'depthM': depthM,
    if (bottomType != null) 'bottomType': bottomType,
    if (note != null) 'note': note,
    if (targetSpecies != null) 'targetSpecies': targetSpecies,
    'timestampMs': timestampMs,
  };

  factory MeraSpot.fromJson(Map<String, dynamic> json) => MeraSpot(
    id: json['id'] as String,
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
    depthM: (json['depthM'] as num?)?.toDouble(),
    bottomType: json['bottomType'] as String?,
    note: json['note'] as String?,
    targetSpecies: json['targetSpecies'] as String?,
    timestampMs: json['timestampMs'] as int,
  );

  Map<String, dynamic> _toRow() => {
    'id': id,
    'lat': lat,
    'lng': lng,
    'depth_m': depthM,
    'bottom_type': bottomType,
    'note': note,
    'target_species': targetSpecies,
    'timestamp_ms': timestampMs,
  };

  factory MeraSpot._fromRow(Map<String, dynamic> row) => MeraSpot(
    id: row['id'] as String,
    lat: (row['lat'] as num).toDouble(),
    lng: (row['lng'] as num).toDouble(),
    depthM: (row['depth_m'] as num?)?.toDouble(),
    bottomType: row['bottom_type'] as String?,
    note: row['note'] as String?,
    targetSpecies: row['target_species'] as String?,
    timestampMs: row['timestamp_ms'] as int,
  );

  MeraSpot copyWith({
    double? depthM,
    String? bottomType,
    String? note,
    String? targetSpecies,
    bool clearNote = false,
    bool clearBottomType = false,
    bool clearTargetSpecies = false,
  }) {
    return MeraSpot(
      id: id,
      lat: lat,
      lng: lng,
      depthM: depthM ?? this.depthM,
      bottomType: clearBottomType ? null : (bottomType ?? this.bottomType),
      note: clearNote ? null : (note ?? this.note),
      targetSpecies: clearTargetSpecies
          ? null
          : (targetSpecies ?? this.targetSpecies),
      timestampMs: timestampMs,
    );
  }
}

/// Persists mera spots in a dedicated on-device SQLite database (separate
/// from the app's core entity database). Fully offline; export/import
/// without cloud.
class MeraManager {
  static const _dbName = 'mera_spots.db';
  static const _table = 'mera_spots';

  static var _instance = MeraManager._();
  static MeraManager get get => _instance;

  @visibleForTesting
  static void set(MeraManager m) => _instance = m;

  @visibleForTesting
  static void reset() => _instance = MeraManager._();

  MeraManager._();

  final _log = const Log('MeraManager');
  final _controller = StreamController<void>.broadcast();
  final _spots = <MeraSpot>[];
  Database? _db;

  Stream<void> get stream => _controller.stream;
  List<MeraSpot> get spots => List.unmodifiable(_spots);

  Future<void> init() async {
    try {
      final path = p.join(await getDatabasesPath(), _dbName);
      _db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) => db.execute('''
          CREATE TABLE $_table (
            id TEXT PRIMARY KEY,
            lat REAL NOT NULL,
            lng REAL NOT NULL,
            depth_m REAL,
            bottom_type TEXT,
            note TEXT,
            target_species TEXT,
            timestamp_ms INTEGER NOT NULL
          );
        '''),
      );
      final rows = await _db!.query(_table, orderBy: 'timestamp_ms ASC');
      _spots
        ..clear()
        ..addAll(rows.map(MeraSpot._fromRow));
    } catch (e) {
      _log.e(e, reason: 'Failed to load mera spots');
    }
    _notify();
  }

  Future<Database> _ensureDb() async {
    if (_db == null) {
      await init();
    }
    return _db!;
  }

  Future<MeraSpot> add({
    required double lat,
    required double lng,
    double? depthM,
    String? bottomType,
    String? note,
    String? targetSpecies,
  }) async {
    final spot = MeraSpot(
      id: const Uuid().v4(),
      lat: lat,
      lng: lng,
      depthM: depthM,
      bottomType: bottomType,
      note: note,
      targetSpecies: targetSpecies,
      timestampMs: DateTime.now().millisecondsSinceEpoch,
    );
    final db = await _ensureDb();
    await db.insert(_table, spot._toRow());
    _spots.add(spot);
    _notify();
    return spot;
  }

  Future<void> remove(String id) async {
    final db = await _ensureDb();
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
    _spots.removeWhere((s) => s.id == id);
    _notify();
  }

  Future<void> update(MeraSpot spot) async {
    final i = _spots.indexWhere((s) => s.id == spot.id);
    if (i < 0) return;
    final db = await _ensureDb();
    await db.update(
      _table,
      spot._toRow(),
      where: 'id = ?',
      whereArgs: [spot.id],
    );
    _spots[i] = spot;
    _notify();
  }

  MeraSpot? byId(String id) {
    for (final s in _spots) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// JSON export for QR/file share.
  String exportJson() => const JsonEncoder.withIndent(
    '  ',
  ).convert(_spots.map((e) => e.toJson()).toList());

  Future<int> importJson(String json) async {
    final raw = jsonDecode(json) as List<dynamic>;
    final db = await _ensureDb();
    var added = 0;
    for (final e in raw) {
      final spot = MeraSpot.fromJson(e as Map<String, dynamic>);
      if (_spots.any((s) => s.id == spot.id)) {
        continue;
      }
      await db.insert(_table, spot._toRow());
      _spots.add(spot);
      added++;
    }
    _notify();
    return added;
  }

  /// Minimal GPX of mera waypoints.
  String exportGpx() {
    final buf = StringBuffer()
      ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
      ..writeln('<gpx version="1.1" creator="MeraAsistani">')
      ..writeln('<metadata><name>Mera noktaları</name></metadata>');
    for (final s in _spots) {
      buf.writeln(
        '<wpt lat="${s.lat}" lon="${s.lng}"><name>${s.bottomType ?? 'mera'}</name>'
        '<desc>depth=${s.depthM ?? ''} ${s.targetSpecies ?? ''} ${s.note ?? ''}</desc></wpt>',
      );
    }
    buf.writeln('</gpx>');
    return buf.toString();
  }

  void _notify() {
    if (!_controller.isClosed) {
      _controller.add(null);
    }
  }
}
