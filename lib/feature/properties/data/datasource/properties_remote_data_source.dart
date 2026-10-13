import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_real_estate_assessment/core/constant/api_constants.dart';
import 'package:flutter_real_estate_assessment/core/error/exceptions.dart';
import 'package:flutter_real_estate_assessment/core/network/dio_client.dart';
import 'package:flutter_real_estate_assessment/core/utils/cancellation_signal.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/category_model.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/properties_response_model.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/property_model.dart';

/// Talks to DummyJSON. Throws [AppException]s only.
abstract interface class PropertiesRemoteDataSource {
  Future<PropertiesResponseModel> getProducts({
    required int limit,
    required int skip,
  });

  Future<PropertiesResponseModel> getProductsByCategory(
    String slug, {
    required int limit,
    required int skip,
  });

  /// Every product matching [query] (`limit=0`).
  Future<PropertiesResponseModel> searchProducts(
    String query, {
    CancellationSignal? cancellation,
  });

  /// The whole catalog (`limit=0`).
  Future<PropertiesResponseModel> getAllProducts({
    CancellationSignal? cancellation,
  });

  Future<PropertiesResponseModel> getFeaturedProducts({required int limit});

  Future<PropertyModel> getProductById(int id);

  Future<List<CategoryModel>> getCategories();
}

class PropertiesRemoteDataSourceImpl implements PropertiesRemoteDataSource {
  const PropertiesRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<PropertiesResponseModel> getProducts({
    required int limit,
    required int skip,
  }) => _getPage(ApiConstants.products, {'limit': limit, 'skip': skip});

  @override
  Future<PropertiesResponseModel> getProductsByCategory(
    String slug, {
    required int limit,
    required int skip,
  }) => _getPage(ApiConstants.productsByCategory(slug), {
    'limit': limit,
    'skip': skip,
  });

  @override
  Future<PropertiesResponseModel> searchProducts(
    String query, {
    CancellationSignal? cancellation,
  }) => _getPage(ApiConstants.searchProducts, {
    'q': query,
    'limit': ApiConstants.allItems,
  }, cancellation: cancellation);

  @override
  Future<PropertiesResponseModel> getAllProducts({
    CancellationSignal? cancellation,
  }) => _getPage(ApiConstants.products, {
    'limit': ApiConstants.allItems,
  }, cancellation: cancellation);

  @override
  Future<PropertiesResponseModel> getFeaturedProducts({required int limit}) =>
      _getPage(ApiConstants.products, {
        'limit': limit,
        'sortBy': 'rating',
        'order': 'desc',
      });

  @override
  Future<PropertyModel> getProductById(int id) async {
    final json = await _client.getJson(ApiConstants.productById(id));
    return _parse(() => PropertyModel.fromJson(json));
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final json = await _client.getJsonList(ApiConstants.categories);
    return _parse(() => CategoryModel.listFromJson(json));
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
