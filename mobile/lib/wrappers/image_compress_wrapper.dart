import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../app_manager.dart';

class ImageCompressWrapper {
  static ImageCompressWrapper of(BuildContext context) =>
      AppManager.get.imageCompressWrapper;

  Future<Uint8List?> compress(String path, int quality, int? size) async {
    // Run the (potentially slow) native compression call on a background
    // isolate so it doesn't block the UI thread.
    // https://github.com/OpenFlutter/flutter_image_compress/issues/131
    var rootIsolateToken = RootIsolateToken.instance;
    var args = _CompressArgs(path, quality, size, rootIsolateToken);

    if (rootIsolateToken == null) {
      // No root isolate token is available (e.g. in a unit test host
      // isolate); fall back to running on the current isolate.
      return _compress(args);
    }

    return compute(_compress, args);
  }
}

@immutable
class _CompressArgs {
  final String path;
  final int quality;
  final int? size;
  final RootIsolateToken? rootIsolateToken;

  const _CompressArgs(this.path, this.quality, this.size, this.rootIsolateToken);
}

/// A top-level function, safe to pass to [compute], that runs the actual
/// native image compression. Platform channel calls require the background
/// isolate's binary messenger to be initialized with the root isolate's
/// token before use.
Future<Uint8List?> _compress(_CompressArgs args) async {
  var rootIsolateToken = args.rootIsolateToken;
  if (rootIsolateToken != null) {
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
  }

  if (args.size == null) {
    // Note that passing null minWidth/minHeight will not use the
    // default values in compressWithFile, so we have to explicitly
    // exclude minWidth/minHeight when we don't have a size.
    return await FlutterImageCompress.compressWithFile(
      args.path,
      quality: args.quality,
    );
  }

  return await FlutterImageCompress.compressWithFile(
    args.path,
    quality: args.quality,
    minWidth: args.size!,
    minHeight: args.size!,
  );
}
