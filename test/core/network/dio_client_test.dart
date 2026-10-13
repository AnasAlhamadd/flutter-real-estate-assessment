import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_real_estate_assessment/core/error/exceptions.dart';
import 'package:flutter_real_estate_assessment/core/network/dio_client.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.statusCode, this.body);

  final int statusCode;
  final String body;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
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

void main() {
  (DioClient, _StubAdapter) clientReturning(int statusCode, String body) {
    final adapter = _StubAdapter(statusCode, body);
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter;
    return (DioClient(dio), adapter);
  }

  test(
    'returns the decoded JSON object and forwards query parameters',
    () async {
      final (client, adapter) = clientReturning(
        200,
        jsonEncode({'total': 194}),
      );

      final result = await client.getJson(
        '/products',
        queryParameters: {'limit': 20},
      );

      expect(result, {'total': 194});
      expect(
        adapter.lastRequest?.uri.toString(),
        'https://example.test/products?limit=20',
      );
    },
  );

  test('throws ParsingException when the body is not a JSON object', () {
    final (client, _) = clientReturning(200, jsonEncode([1, 2, 3]));

    expect(client.getJson('/products'), throwsA(const ParsingException()));
  });

  test('throws ServerException with the status code on HTTP 500', () {
    final (client, _) = clientReturning(500, jsonEncode({'message': 'boom'}));

    expect(
      client.getJson('/products'),
      throwsA(const ServerException(statusCode: 500)),
    );
  });

  test('throws ServerException(404) for a missing resource', () {
    final (client, _) = clientReturning(404, jsonEncode({'message': 'nope'}));

    expect(
      client.getJson('/products/0'),
      throwsA(const ServerException(statusCode: 404)),
    );
  });

  test('createDio applies the API base URL and timeouts', () {
    final dio = DioClient.createDio(baseUrl: 'https://example.test');

    expect(dio.options.baseUrl, 'https://example.test');
    expect(dio.options.connectTimeout, isNotNull);
    expect(dio.options.receiveTimeout, isNotNull);
  });
}
