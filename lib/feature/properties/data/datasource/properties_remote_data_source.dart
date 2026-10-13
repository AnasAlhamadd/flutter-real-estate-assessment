import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_real_estate_assessment/core/constant/api_constants.dart';
import 'package:flutter_real_estate_assessment/core/error/exceptions.dart';
import 'package:flutter_real_estate_assessment/core/network/dio_client.dart';
import 'package:flutter_real_estate_assessment/core/utils/cancellation_signal.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/properties_response_model.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/property_model.dart';

/// Search, full catalog and details from DummyJSON. Throws [AppException]s
/// only.
abstract interface class PropertiesRemoteDataSource {
  /// Every product matching [query] (`limit=0`).
  Future<PropertiesResponseModel> searchProducts(
    String query, {
    CancellationSignal? cancellation,
  });

  /// [limit] products matching [query], starting at [skip].
  Future<PropertiesResponseModel> searchProductsPage(
    String query, {
    required int skip,
    required int limit,
    CancellationSignal? cancellation,
  });

  /// The whole catalog (`limit=0`).
  Future<PropertiesResponseModel> getAllProducts({
    CancellationSignal? cancellation,
  });

  Future<PropertyModel> getProductById(int id);
}

class PropertiesRemoteDataSourceImpl implements PropertiesRemoteDataSource {
  const PropertiesRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<PropertiesResponseModel> searchProducts(
    String query, {
    CancellationSignal? cancellation,
  }) => _getPage(ApiConstants.searchProducts, {
    'q': query,
    'limit': ApiConstants.allItems,
  }, cancellation: cancellation);

  @override
  Future<PropertiesResponseModel> searchProductsPage(
    String query, {
    required int skip,
    required int limit,
    CancellationSignal? cancellation,
  }) => _getPage(ApiConstants.searchProducts, {
    'q': query,
    'limit': limit,
    'skip': skip,
  }, cancellation: cancellation);

  @override
  Future<PropertiesResponseModel> getAllProducts({
    CancellationSignal? cancellation,
  }) => _getPage(ApiConstants.products, {
    'limit': ApiConstants.allItems,
  }, cancellation: cancellation);

  @override
  Future<PropertyModel> getProductById(int id) async {
    final json = await _client.getJson(ApiConstants.productById(id));
    return _parse(() => PropertyModel.fromJson(json));
  }

  Future<PropertiesResponseModel> _getPage(
    String path,
    Map<String, dynamic> query, {
    CancellationSignal? cancellation,
  }) async {
    final json = await _client.getJson(
      path,
      queryParameters: {...query, 'select': ApiConstants.listingFields},
      cancelToken: _cancelTokenFor(cancellation),
    );
    return _parse(() => PropertiesResponseModel.fromJson(json));
  }

  CancelToken? _cancelTokenFor(CancellationSignal? signal) {
    if (signal == null) return null;
    if (signal.isCancelled) throw const RequestCancelledException();
    final token = CancelToken();
    unawaited(signal.whenCancelled.then((_) => token.cancel()));
    return token;
  }

  T _parse<T>(T Function() parse) {
    try {
      return parse();
    } on FormatException {
      throw const ParsingException();
    }
  }
}
