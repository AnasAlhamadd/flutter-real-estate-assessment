import 'dart:developer' as developer;

import 'package:dio/dio.dart';

/// Logs one block per finished request under the `API` name:
///
/// ```
/// request: GET
/// request_status: 200 (142 ms)
/// uri: https://dummyjson.com/products?limit=20
/// ```
///
/// Failures without an HTTP response print the [DioExceptionType] name
/// (e.g. `cancel`, `connectionTimeout`) as the status.
class ApiLogInterceptor extends Interceptor {
  ApiLogInterceptor({void Function(String message)? log})
    : _log = log ?? _developerLog;

  static const startedAtKey = 'api_log_started_at';

  static void _developerLog(String message) =>
      developer.log(message, name: 'API');

  final void Function(String message) _log;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[startedAtKey] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logRequest(response.requestOptions, '${response.statusCode}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode?.toString() ?? err.type.name;
    _logRequest(err.requestOptions, status);
    handler.next(err);
  }

  void _logRequest(RequestOptions options, String status) {
    _log(
      'request: ${options.method}\n'
      'request_status: $status${_elapsed(options)}\n'
      'uri: ${options.uri}',
    );
  }

  String _elapsed(RequestOptions options) {
    final startedAt = options.extra[startedAtKey];
    if (startedAt is! DateTime) return '';
    return ' (${DateTime.now().difference(startedAt).inMilliseconds} ms)';
  }
}
