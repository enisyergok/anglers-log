import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:sqflite/sqflite.dart';

/// Offline raster tiles from an MBTiles (SQLite) archive.
///
/// Compatible with protobuf ^4 (unlike flutter_map_pmtiles / pmtiles).
class MbtilesTileProvider extends TileProvider {
  final Database _db;

  MbtilesTileProvider._(this._db);

  static Future<MbtilesTileProvider> open(String path) async {
    final db = await openDatabase(path, readOnly: true, singleInstance: false);
    return MbtilesTileProvider._(db);
  }

  Future<void> close() => _db.close();

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return _MbtilesImageProvider(_db, coordinates);
  }
}

class _MbtilesImageProvider extends ImageProvider<_MbtilesImageProvider> {
  final Database db;
  final TileCoordinates coordinates;

  const _MbtilesImageProvider(this.db, this.coordinates);

  @override
  Future<_MbtilesImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture(this);
  }

  @override
  ImageStreamCompleter loadImage(
    _MbtilesImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _load(decode),
      scale: 1,
      debugLabel: 'mbtiles://${coordinates.z}/${coordinates.x}/${coordinates.y}',
    );
  }

  Future<ui.Codec> _load(ImageDecoderCallback decode) async {
    // MBTiles uses TMS row numbering.
    final z = coordinates.z;
    final x = coordinates.x;
    final yTms = (1 << z) - 1 - coordinates.y;

    final rows = await db.query(
      'tiles',
      columns: ['tile_data'],
      where: 'zoom_level = ? AND tile_column = ? AND tile_row = ?',
      whereArgs: [z, x, yTms],
      limit: 1,
    );

    if (rows.isEmpty) {
      // Transparent 1x1 PNG
      return decode(
        await ui.ImmutableBuffer.fromUint8List(_transparentPng),
      );
    }

    final bytes = rows.first['tile_data'];
    if (bytes is! Uint8List) {
      return decode(
        await ui.ImmutableBuffer.fromUint8List(_transparentPng),
      );
    }
    return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
  }

  @override
  bool operator ==(Object other) =>
      other is _MbtilesImageProvider &&
      other.coordinates == coordinates &&
      other.db == db;

  @override
  int get hashCode => Object.hash(db, coordinates);

  static final Uint8List _transparentPng = Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
    0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
    0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
  ]);
}
