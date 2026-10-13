import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_real_estate_assessment/core/constant/api_constants.dart';
import 'package:flutter_real_estate_assessment/core/error/exceptions.dart';
import 'package:flutter_real_estate_assessment/core/network/dio_client.dart';
import 'package:flutter_real_estate_assessment/core/utils/cancellation_signal.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/datasource/properties_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';
import '../../../../helpers/stub_http_adapter.dart';

void main() {
  late StubHttpAdapter adapter;
  late PropertiesRemoteDataSource dataSource;

  setUp(() {
    adapter = StubHttpAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter;
    dataSource = PropertiesRemoteDataSourceImpl(DioClient(dio));
  });

  void respondWith(String fixtureName, {int statusCode = 200}) {
    adapter
      ..statusCode = statusCode
      ..body = fixture(fixtureName);
  }

  group('full-set requests', () {
    test('searchProducts asks for the full matching set', () async {
      respondWith('search_results.json');

      final page = await dataSource.searchProducts('phone');

      expect(adapter.lastRequest.path, '/products/search');
      expect(adapter.lastRequest.queryParameters, {
        'q': 'phone',
        'limit': 0,
        'select': ApiConstants.listingFields,
      });
      expect(page.products, hasLength(23));
    });

    test('Arabic search text is sent as-is and yields no results', () async {
      respondWith('search_empty.json');

      final page = await dataSource.searchProducts('بيت');

      expect(adapter.lastRequest.queryParameters['q'], 'بيت');
      expect(page.products, isEmpty);
    });

    test('getAllProducts requests the whole catalog', () async {
      respondWith('search_results.json');

      await dataSource.getAllProducts();

      expect(adapter.lastRequest.path, '/products');
      expect(adapter.lastRequest.queryParameters, {
        'limit': 0,
        'select': ApiConstants.listingFields,
      });
    });
  });

  test('getProductById fetches the full object without select', () async {
    respondWith('product.json');

    final product = await dataSource.getProductById(1);

    expect(adapter.lastRequest.path, '/products/1');
    expect(adapter.lastRequest.queryParameters, isEmpty);
    expect(product.reviews, hasLength(3));
  });

  group('malformed responses throw ParsingException', () {
    test('products is not a list', () {
      respondWith('products_not_a_list.json');

      expect(
        dataSource.searchProducts('phone'),
        throwsA(const ParsingException()),
      );
    });

    test('a product without an id', () {
      adapter.body = jsonEncode({'title': 'No id'});

      expect(dataSource.getProductById(1), throwsA(const ParsingException()));
    });
  });

  test('HTTP errors surface as ServerException', () {
    adapter
      ..statusCode = 404
      ..body = jsonEncode({'message': "Product with id '0' not found"});

    expect(
      dataSource.getProductById(0),
      throwsA(const ServerException(statusCode: 404)),
    );
  });

  group('cancellation', () {
    test('an already cancelled signal sends no request', () async {
      final signal = CancellationSignal()..cancel();

      await expectLater(
        dataSource.searchProducts('phone', cancellation: signal),
        throwsA(const RequestCancelledException()),
      );
      expect(adapter.requests, isEmpty);
    });

    test('cancelling an in-flight search aborts it', () async {
      adapter.hang = true;
      final signal = CancellationSignal();

      final request = dataSource.searchProducts('phone', cancellation: signal);
      await pumpEventQueue();
      signal.cancel();

      await expectLater(request, throwsA(const RequestCancelledException()));
    });
  });
}
