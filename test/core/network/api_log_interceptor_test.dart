import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_real_estate_assessment/core/network/api_log_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.statusCode, {this.hang = false});

  final int statusCode;
  final bool hang;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (hang) await Completer<void>().future;
    return ResponseBody.fromString(
      jsonEncode({'ok': true}),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late List<String> logs;

  Dio dioReturning(int statusCode, {bool hang = false}) {
    logs = [];
    return Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = _StubAdapter(statusCode, hang: hang)
      ..interceptors.add(ApiLogInterceptor(log: logs.add));
  }

  test('logs method, status and full uri for a successful request', () async {
    final dio = dioReturning(200);

    await dio.get<dynamic>(
      '/products',
      queryParameters: {'limit': 5, 'sortBy': 'rating'},
    );

    expect(logs, hasLength(1));
    final lines = logs.single.split('\n');
    expect(lines[0], 'request: GET');
    expect(lines[1], matches(RegExp(r'^request_status: 200 \(\d+ ms\)$')));
    expect(
      lines[2],
      'uri: https://example.test/products?limit=5&sortBy=rating',
    );
  });

  test('logs the HTTP status code of a failed response', () async {
    final dio = dioReturning(404);

    await expectLater(
      dio.get<dynamic>('/products/0'),
      throwsA(isA<DioException>()),
    );

    expect(logs.single, contains('request_status: 404'));
    expect(logs.single, contains('uri: https://example.test/products/0'));
  });

  test('logs the error type when a request is cancelled in flight', () async {
    final dio = dioReturning(200, hang: true);
    final cancelToken = CancelToken();

    final request = dio.get<dynamic>('/products', cancelToken: cancelToken);
    await Future<void>.delayed(Duration.zero);
    cancelToken.cancel();

    await expectLater(request, throwsA(isA<DioException>()));

    expect(logs.single, contains('request_status: cancel'));
  });
}
