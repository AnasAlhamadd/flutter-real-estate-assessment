import 'package:flutter_real_estate_assessment/core/constant/api_constants.dart';
import 'package:flutter_real_estate_assessment/core/error/exceptions.dart';
import 'package:flutter_real_estate_assessment/core/network/dio_client.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/category_model.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/properties_response_model.dart';

/// Home's DummyJSON requests. Throws [AppException]s only.
abstract interface class HomeRemoteDataSource {
  Future<PropertiesResponseModel> getFeaturedProducts({required int limit});

  Future<List<CategoryModel>> getCategories();

  Future<PropertiesResponseModel> getProducts({
    required int limit,
    required int skip,
  });

  Future<PropertiesResponseModel> getProductsByCategory(
    String slug, {
    required int limit,
    required int skip,
  });
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  const HomeRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<PropertiesResponseModel> getFeaturedProducts({required int limit}) =>
      _getPage(ApiConstants.products, {
        'limit': limit,
        'sortBy': 'rating',
        'order': 'desc',
      });

  @override
  Future<List<CategoryModel>> getCategories() async {
    final json = await _client.getJsonList(ApiConstants.categories);
    return _parse(() => CategoryModel.listFromJson(json));
  }

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

  Future<PropertiesResponseModel> _getPage(
    String path,
    Map<String, dynamic> query,
  ) async {
    final json = await _client.getJson(
      path,
      queryParameters: {...query, 'select': ApiConstants.listingFields},
    );
    return _parse(() => PropertiesResponseModel.fromJson(json));
  }

  T _parse<T>(T Function() parse) {
    try {
      return parse();
    } on FormatException {
      throw const ParsingException();
    }
  }
}
