import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Records every request and answers with a fixed status and body.
/// With [hang] set, it never answers, so cancellation can be tested.
class StubHttpAdapter implements HttpClientAdapter {
  StubHttpAdapter({this.statusCode = 200, this.body = '{}', this.hang = false});

  int statusCode;
  String body;
  bool hang;
  final List<RequestOptions> requests = [];

  RequestOptions get lastRequest => requests.last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (hang) await Completer<void>().future;
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
