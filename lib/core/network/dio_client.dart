import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_real_estate_assessment/core/constant/api_constants.dart';
import 'package:flutter_real_estate_assessment/core/error/exceptions.dart';

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
      dio.interceptors.add(LogInterceptor(responseBody: false));
    }
    return dio;
  }

  /// GETs a JSON object. Throws an [AppException] on any failure.
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      throw const ParsingException();
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
