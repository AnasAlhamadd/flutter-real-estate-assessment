import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_real_estate_assessment/core/constant/api_constants.dart';
import 'package:flutter_real_estate_assessment/core/error/exceptions.dart';
import 'package:flutter_real_estate_assessment/core/network/dio_client.dart';
import 'package:flutter_real_estate_assessment/feature/home/data/datasource/home_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';
import '../../../../helpers/stub_http_adapter.dart';

void main() {
  late StubHttpAdapter adapter;
  late HomeRemoteDataSource dataSource;

  setUp(() {
    adapter = StubHttpAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter;
    dataSource = HomeRemoteDataSourceImpl(DioClient(dio));
  });

  void respondWith(String fixtureName, {int statusCode = 200}) {
    adapter
      ..statusCode = statusCode
      ..body = fixture(fixtureName);
  }

  test('getFeaturedProducts sorts by rating, descending', () async {
    respondWith('featured.json');

    final page = await dataSource.getFeaturedProducts(limit: 5);

    expect(adapter.lastRequest.path, '/products');
    expect(adapter.lastRequest.queryParameters, {
      'limit': 5,
      'sortBy': 'rating',
      'order': 'desc',
      'select': ApiConstants.listingFields,
    });
    expect(page.products.map((product) => product.id), [99, 80, 95, 42, 33]);
  });

  test('getCategories parses the category array', () async {
    respondWith('categories.json');

    final categories = await dataSource.getCategories();

    expect(adapter.lastRequest.path, '/products/categories');
    expect(categories, hasLength(24));
  });

  group('pages', () {
    test('getProducts pages with limit/skip and the listing fields', () async {
      respondWith('products_page.json');

      final page = await dataSource.getProducts(limit: 20, skip: 40);

      expect(adapter.lastRequest.path, '/products');
      expect(adapter.lastRequest.queryParameters, {
        'limit': 20,
        'skip': 40,
        'select': ApiConstants.listingFields,
      });
      expect(page.products, hasLength(20));
      expect(page.total, 194);
    });

    test('getProductsByCategory URL-encodes the slug', () async {
      respondWith('category_last_page.json');

      final page = await dataSource.getProductsByCategory(
        'home decor/new',
        limit: 20,
        skip: 20,
      );

      expect(
        adapter.lastRequest.uri.path,
        '/products/category/home%20decor%2Fnew',
      );
      expect(adapter.lastRequest.queryParameters['skip'], 20);
      expect(page.products, hasLength(7));
    });

    test('an unknown category is an empty page, not an error', () async {
      respondWith('category_unknown.json');

      final page = await dataSource.getProductsByCategory(
        'unknown-slug',
        limit: 20,
        skip: 0,
      );

      expect(page.products, isEmpty);
      expect(page.total, 0);
    });
  });

  group('malformed responses throw ParsingException', () {
    test('products is not a list', () {
      respondWith('products_not_a_list.json');

      expect(
        dataSource.getProducts(limit: 20, skip: 0),
        throwsA(const ParsingException()),
      );
    });

    test('categories is an object instead of an array', () {
      adapter.body = jsonEncode({'slug': 'beauty'});

      expect(dataSource.getCategories(), throwsA(const ParsingException()));
    });
  });

  test('a non-2xx status surfaces as ServerException', () {
    adapter
      ..statusCode = 500
      ..body = jsonEncode({'message': 'boom'});

    expect(
      dataSource.getProducts(limit: 20, skip: 0),
      throwsA(const ServerException(statusCode: 500)),
    );
  });
}
