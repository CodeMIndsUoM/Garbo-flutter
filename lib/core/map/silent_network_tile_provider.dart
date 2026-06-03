import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart';
import 'package:http/retry.dart';

/// Suppresses harmless aborted tile fetches that can occur while the map is
/// rebuilding, pruning old tiles, or when a page is disposed mid-request.
class SilentNetworkTileProvider extends TileProvider {
  SilentNetworkTileProvider({super.headers, BaseClient? httpClient})
    : httpClient = httpClient ?? RetryClient(Client());

  final BaseClient httpClient;

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return _SilentFlutterMapNetworkImageProvider(
      url: getTileUrl(coordinates, options),
      fallbackUrl: getTileFallbackUrl(coordinates, options),
      headers: headers,
      httpClient: httpClient,
    );
  }

  @override
  void dispose() {
    httpClient.close();
    super.dispose();
  }
}

@immutable
class _SilentFlutterMapNetworkImageProvider
    extends ImageProvider<_SilentFlutterMapNetworkImageProvider> {
  const _SilentFlutterMapNetworkImageProvider({
    required this.url,
    required this.fallbackUrl,
    required this.headers,
    required this.httpClient,
  });

  final String url;
  final String? fallbackUrl;
  final Map<String, String> headers;
  final BaseClient httpClient;

  @override
  Future<_SilentFlutterMapNetworkImageProvider> obtainKey(
    ImageConfiguration configuration,
  ) {
    return SynchronousFuture<_SilentFlutterMapNetworkImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    _SilentFlutterMapNetworkImageProvider key,
    ImageDecoderCallback decode,
  ) {
    final chunkEvents = StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode),
      chunkEvents: chunkEvents.stream,
      scale: 1,
      debugLabel: url,
      informationCollector: () => [
        DiagnosticsProperty('URL', url),
        DiagnosticsProperty('Fallback URL', fallbackUrl),
        DiagnosticsProperty('Current provider', key),
      ],
    );
  }

  Future<Codec> _loadAsync(
    _SilentFlutterMapNetworkImageProvider key,
    StreamController<ImageChunkEvent> chunkEvents,
    ImageDecoderCallback decode, {
    bool useFallback = false,
  }) async {
    try {
      final bytes = await httpClient.readBytes(
        Uri.parse(useFallback ? fallbackUrl ?? '' : url),
        headers: headers,
      );
      return decode(await ImmutableBuffer.fromUint8List(bytes)).catchError((
        dynamic error,
      ) {
        if (_isAbortedRequest(error)) {
          return _decodeTransparentImage(decode);
        }
        if (useFallback || fallbackUrl == null) {
          throw error as Object;
        }
        return _loadAsync(key, chunkEvents, decode, useFallback: true);
      });
    } catch (error) {
      if (_isAbortedRequest(error)) {
        return _decodeTransparentImage(decode);
      }
      if (useFallback || fallbackUrl == null) {
        rethrow;
      }
      return _loadAsync(key, chunkEvents, decode, useFallback: true);
    }
  }

  Future<Codec> _decodeTransparentImage(ImageDecoderCallback decode) async {
    return decode(
      await ImmutableBuffer.fromUint8List(TileProvider.transparentImage),
    );
  }

  bool _isAbortedRequest(Object error) {
    final message = error.toString().toLowerCase();
    return error is ClientException &&
            (message.contains('request aborted') ||
                message.contains('aborttrigger')) ||
        message.contains('requestabortedexception');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is _SilentFlutterMapNetworkImageProvider &&
          fallbackUrl == null &&
          url == other.url);

  @override
  int get hashCode =>
      Object.hashAll([url, if (fallbackUrl != null) fallbackUrl]);
}
