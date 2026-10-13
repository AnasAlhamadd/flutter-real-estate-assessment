import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_real_estate_assessment/core/error/exceptions.dart';
import 'package:flutter_real_estate_assessment/core/network/dio_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final requestOptions = RequestOptions(path: '/products');

  DioException dioException(
    DioExceptionType type, {
    Object? error,
    int? code,
  }) => DioException(
    requestOptions: requestOptions,
    type: type,
    error: error,
    response: code == null
        ? null
        : Response<void>(requestOptions: requestOptions, statusCode: code),
  );

  final cases = <String, (DioException, AppException)>{
    'connection timeout': (
      dioException(DioExceptionType.connectionTimeout),
      const RequestTimeoutException(),
    ),
    'send timeout': (
      dioException(DioExceptionType.sendTimeout),
      const RequestTimeoutException(),
    ),
    'receive timeout': (
      dioException(DioExceptionType.receiveTimeout),
      const RequestTimeoutException(),
    ),
    'transform timeout': (
      dioException(DioExceptionType.transformTimeout),
      const RequestTimeoutException(),
    ),
    'connection error': (
      dioException(DioExceptionType.connectionError),
      const NetworkException(),
    ),
    'bad certificate': (
      dioException(DioExceptionType.badCertificate),
      const NetworkException(),
    ),
    'HTTP 404': (
      dioException(DioExceptionType.badResponse, code: 404),
      const ServerException(statusCode: 404),
    ),
    'HTTP 500': (
      dioException(DioExceptionType.badResponse, code: 500),
      const ServerException(statusCode: 500),
    ),
    'cancelled': (
      dioException(DioExceptionType.cancel),
      const RequestCancelledException(),
    ),
    'unknown socket error': (
      dioException(
        DioExceptionType.unknown,
        error: const SocketException('down'),
      ),
      const NetworkException(),
    ),
    'unknown format error': (
      dioException(DioExceptionType.unknown, error: const FormatException()),
      const ParsingException(),
    ),
    'unknown other error': (
      dioException(DioExceptionType.unknown, error: StateError('x')),
      const UnknownException(),
    ),
  };

  cases.forEach((name, testCase) {
    final (input, expected) = testCase;
    test('maps $name to ${expected.runtimeType}', () {
      expect(mapDioException(input), expected);
    });
  });
}
