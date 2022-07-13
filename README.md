# file_hasher

A utility for hashing one or more files with the XXH3 hashing algorithm.

`file_hasher` relies on the [xxh3](https://pub.dev/packages/xxh3) package.

## About

`file_hasher` works by splitting files into chunks, individually hashing
each chunk with the [XXH3](https://github.com/Cyan4973/xxHash/) hashing
algorithm, then combining each hash with the existing digest with the
bit-wise exclusive-or operator (`^`), and returning the result.

The [FileHasher] utility class provides a method to hash individual files,
[hash], as well as a method to hash multiple files, [smash], and their
synchronous variants, [hashSync] and [smashSync].

## Usage

```dart
import 'package:file_hasher/file_hasher.dart';
```

### hash & hashSync

The [hash] and [hashSync] methods hash the contents of a single file.

[hash] streams the contents of a file, while [hashSync] reads the file
synchronously then processes the file data.

```dart
final file = File.fromUri(Uri.file('path/to/file'));

// Asynchronously hash the file.
print(await FileHasher.hash(file));

// Synchronously hash the file.
print(FileHasher.hashSync(file));
```

### smash & smashSync

The [smash] and [smashSync] methods hash the contents of multiple files
in the order they're listed.

[smash] streams the contents of the files, while [smashSync] reads the files
synchronously then processes the file data.

```dart
final files = <File>[
  File.fromUri(Uri.file('path/to/file1')),
  File.fromUri(Uri.file('path/to/file2')),
  File.fromUri(Uri.file('path/to/file3')),
];

// Asynchronously hash the files.
print(await FileHasher.smash(files));

// Synchronously hash the files.
print(FileHasher.smashSync(files));
```

### File extension methods

`file_hasher` extends the [File] object from the `dart:io` package with two
methods: [xxh3] and [xxh3Sync]; which call [FileHasher]'s [hash] and [hashSync]
methods respectively.

```dart
// Asynchronously hash the file.
print(await file.xxh3());

// Synchronously hash the files.
print(file.xxh3Sync());
```

## Parameters

Each of the methods provided by [FileHasher], as well as the [File] extension
methods, have 3 optional parameters: [chunkSize], [seed], and [secret].

See below for details.

```dart
final hash = await FileHasher.hash(
  file,
  chunkSize: 500,
  seed: 20220713,
  secret: mySecretUint8List,
);
```

### chunkSize

[chunkSize] sets the number of bytes to include in each chunk of data being
hashed; changing the [chunkSize] will result in different hashes being returned
for any files containing more bytes than the [chunkSize].

[chunkSize] defaults to `2500`.

### seed

A [seed] can be provided as an [int] to randomize the hash function.

[seed] defaults to `0`.

### secret

An optional [secret] can also be provided as a [Uint8List] to
randomize the hash function.

If provided, the [secret] must be at least `136` bytes.

__Note:__ Per [XXH3](https://github.com/Cyan4973/xxHash/) and the
[xxh3](https://pub.dev/packagex/xxh3) package, the secret must
look like a bunch of random bytes as the quality of the secret impacts
the dispersion of the hash algorithm. "Trivial" or structured data such
as repeated sequences or a text document should be avoided.

__Note:__ [Uint8List] can be imported from the `dart:typed_data` package
and can be constructed from a list of [int]s.
