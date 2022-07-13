import 'dart:io';
import 'dart:typed_data';
import 'package:xxh3/xxh3.dart';

/// A utility for hashing one or more files with the XXH3 hashing algorithm.
class FileHasher {
  FileHasher._();

  var _digest = 0;

  final _chunk = <int>[];

  /// Hashes and clears the contents of [_chunk].
  void _hashChunk(int seed, Uint8List? secret) {
    _digest ^= xxh3(Uint8List.fromList(_chunk), seed: seed, secret: secret);
    _chunk.clear();
  }

  /// Chunks and hashes the provided [data].
  ///
  /// Any bytes remaining in [_chunk] that don't
  /// meet the [chunkSize] will not be hashed.
  void _processData(
    List<int> data,
    int chunkSize,
    int seed,
    Uint8List? secret,
  ) {
    var bytesRemaining = data.length;
    while (bytesRemaining > 0) {
      final remainder = chunkSize - _chunk.length;
      final chunkStart = data.length - bytesRemaining;
      if (remainder > bytesRemaining) {
        _chunk.addAll(data.sublist(chunkStart));
        bytesRemaining = 0;
      } else {
        _chunk.addAll(data.sublist(chunkStart, chunkStart + remainder));
        bytesRemaining -= remainder;
        _hashChunk(seed, secret);
      }
    }
  }

  /// Hashes the provided [file] in chunks with the XXH3 hashing algorithm.
  ///
  /// [chunkSize] defines the number of bytes hashed with each chunk.
  static Future<int> hash(
    File file, {
    int chunkSize = 2500,
    int seed = 0,
    Uint8List? secret,
  }) async {
    final hasher = FileHasher._();
    await for (var data in file.openRead()) {
      hasher._processData(data, chunkSize, seed, secret);
    }
    if (hasher._chunk.isNotEmpty) hasher._hashChunk(seed, secret);
    return hasher._digest;
  }

  /// Synchronously hashes the provided [file] in
  /// chunks with the XXH3 hashing algorithm.
  ///
  /// [chunkSize] defines the number of bytes hashed with each chunk.
  static int hashSync(
    File file, {
    int chunkSize = 2500,
    int seed = 0,
    Uint8List? secret,
  }) {
    final hasher = FileHasher._();
    hasher._processData(file.readAsBytesSync(), chunkSize, seed, secret);
    if (hasher._chunk.isNotEmpty) hasher._hashChunk(seed, secret);
    return hasher._digest;
  }

  /// Hashes the provided [files] in their listed order
  /// in chunks with the XXH3 hashing algorithm.
  ///
  /// [chunkSize] defines the number of bytes hashed with each chunk.
  static Future<int> smash(
    List<File> files, {
    int chunkSize = 2500,
    int seed = 0,
    Uint8List? secret,
  }) async {
    final hasher = FileHasher._();
    for (var file in files) {
      await for (var data in file.openRead()) {
        hasher._processData(data, chunkSize, seed, secret);
      }
    }
    if (hasher._chunk.isNotEmpty) hasher._hashChunk(seed, secret);
    return hasher._digest;
  }

  /// Synchronously hashes the provided [files] in their listed
  /// order in chunks with the XXH3 hashing algorithm.
  ///
  /// [chunkSize] defines the number of bytes hashed with each chunk.
  static int smashSync(
    List<File> files, {
    int chunkSize = 2500,
    int seed = 0,
    Uint8List? secret,
  }) {
    final hasher = FileHasher._();
    for (var file in files) {
      hasher._processData(file.readAsBytesSync(), chunkSize, seed, secret);
    }
    if (hasher._chunk.isNotEmpty) hasher._hashChunk(seed, secret);
    return hasher._digest;
  }
}

/// Extends [File] with methods ([xxh3] and [xxh3Sync]) for hashing the
/// contents of the file in chunks with the XXH3 hashing algorithm.
extension HashFile on File {
  /// Hashes the file in chunks with the XXH3 hashing algorithm.
  ///
  /// [chunkSize] defines the number of bytes hashed with each chunk.
  Future<int> xxh3({
    int chunkSize = 2500,
    int seed = 0,
    Uint8List? secret,
  }) async =>
      FileHasher.hash(this, chunkSize: chunkSize, seed: seed, secret: secret);

  /// Synchronously hashes the file in chunks with the XXH3 hashing algorithm.
  ///
  /// [chunkSize] defines the number of bytes hashed with each chunk.
  int xxh3Sync({
    int chunkSize = 2500,
    int seed = 0,
    Uint8List? secret,
  }) =>
      FileHasher.hashSync(this,
          chunkSize: chunkSize, seed: seed, secret: secret);
}
