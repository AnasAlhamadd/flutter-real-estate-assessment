import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_real_estate_assessment/core/constant/api_constants.dart';
import 'package:flutter_real_estate_assessment/core/error/exceptions.dart';
import 'package:flutter_real_estate_assessment/core/network/api_log_interceptor.dart';

class DioClient {
  const DioClient(this._dio);

  final Dio _dio;

  static Dio createDio({String baseUrl = ApiConstants.baseUrl}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        responseType: ResponseType.json,
      ),
    );
    if (kDebugMode) {
      dio.interceptors.add(ApiLogInterceptor());
    }
    return dio;
  }

  /// GETs a JSON object. Throws an [AppException] on any failure.
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    final data = await _get(path, queryParameters, cancelToken);
    if (data is Map<String, dynamic>) return data;
    throw const ParsingException();
  }

  /// GETs a JSON array. Throws an [AppException] on any failure.
  Future<List<dynamic>> getJsonList(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    final data = await _get(path, queryParameters, cancelToken);
    if (data is List<dynamic>) return data;
    throw const ParsingException();
  }

  Future<Object?> _get(
    String path,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  ) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}

AppException mapDioException(DioException error) => switch (error.type) {
  DioExceptionType.connectionTimeout ||
  DioExceptionType.sendTimeout ||
  DioExceptionType.receiveTimeout ||
  DioExceptionType.transformTimeout => const RequestTimeoutException(),
  DioExceptionType.connectionError ||
  DioExceptionType.badCertificate => const NetworkException(),
  DioExceptionType.badResponse => ServerException(
    statusCode: error.response?.statusCode,
  ),
  DioExceptionType.cancel => const RequestCancelledException(),
  DioExceptionType.unknown => switch (error.error) {
    SocketException() => const NetworkException(),
    FormatException() => const ParsingException(),
    _ => const UnknownException(),
  },
};
