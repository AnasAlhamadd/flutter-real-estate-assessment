import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/exceptions.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/utils/cancellation_signal.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/properties_response_model.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/property_model.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/repositories/properties_repository_impl.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/properties_page_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/fixture_reader.dart';
import '../../../../helpers/mocks.dart';

void main() {
  final catalog = PropertiesResponseModel.fromJson(
    fixtureMap('products_page.json'),
  );
  final product = PropertyModel.fromJson(fixtureMap('product.json'));

  late MockPropertiesRemoteDataSource remote;
  late MockNetworkInfo networkInfo;
  late PropertiesRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(CancellationSignal()));

  setUp(() {
    remote = MockPropertiesRemoteDataSource();
    networkInfo = MockNetworkInfo();
    repository = PropertiesRepositoryImpl(
      remote: remote,
      networkInfo: networkInfo,
    );
    when(() => networkInfo.isConnected).thenAnswer((_) async => true);
  });

  PropertiesPageEntity rightValue(
    Either<Failure, PropertiesPageEntity> result,
  ) => result.getOrElse(() => throw StateError('Expected Right: $result'));

  group('full-set listings', () {
    test('search forwards the query and cancellation signal', () async {
      final signal = CancellationSignal();
      when(() => remote.searchProducts('بيت', cancellation: signal)).thenAnswer(
        (_) async =>
            PropertiesResponseModel.fromJson(fixtureMap('search_empty.json')),
      );

      final page = rightValue(
        await repository.searchProperties(query: 'بيت', cancellation: signal),
      );

      expect(page.items, isEmpty);
    });

    test('a cancelled search becomes CancelledFailure', () async {
      when(
        () => remote.searchProducts(
          'phone',
          cancellation: any(named: 'cancellation'),
        ),
      ).thenThrow(const RequestCancelledException());

      expect(
        await repository.searchProperties(query: 'phone'),
        const Left(CancelledFailure()),
      );
    });

    test('getAllProperties loads the full catalog', () async {
      when(
        () => remote.getAllProducts(cancellation: any(named: 'cancellation')),
      ).thenAnswer((_) async => catalog);

      expect(
        rightValue(await repository.getAllProperties()).items,
        hasLength(20),
      );
    });

    test('offline calls fail fast with NetworkFailure', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      expect(
        await repository.searchProperties(query: 'phone'),
        const Left(NetworkFailure()),
      );
      verifyZeroInteractions(remote);
    });
  });

  group('getPropertyDetails', () {
    test('returns the full product', () async {
      when(() => remote.getProductById(1)).thenAnswer((_) async => product);

      final result = await repository.getPropertyDetails(1);

      expect(result, Right(product.toEntity()));
    });

    test('falls back to the in-memory copy when a refetch fails', () async {
      when(() => remote.getProductById(1)).thenAnswer((_) async => product);
      await repository.getPropertyDetails(1);
      when(() => remote.getProductById(1)).thenThrow(const NetworkException());

      expect(await repository.getPropertyDetails(1), Right(product.toEntity()));
    });

    test('returns the failure when nothing is in memory', () async {
      when(
        () => remote.getProductById(0),
      ).thenThrow(const ServerException(statusCode: 404));

      expect(
        await repository.getPropertyDetails(0),
        const Left(NotFoundFailure()),
      );
    });

    test('keeps at most 20 products in memory', () async {
      when(() => remote.getProductById(any())).thenAnswer(
        (invocation) async => PropertyModel.fromJson({
          'id': invocation.positionalArguments.first,
        }),
      );
      for (var id = 1; id <= 21; id++) {
        await repository.getPropertyDetails(id);
      }
      when(
        () => remote.getProductById(any()),
      ).thenThrow(const NetworkException());

      expect(
        await repository.getPropertyDetails(1),
        const Left(NetworkFailure()),
        reason: 'the oldest entry was evicted',
      );
      expect((await repository.getPropertyDetails(21)).isRight(), isTrue);
    });
  });

  test('unexpected exceptions become UnknownFailure', () async {
    when(() => remote.getProductById(1)).thenThrow(Exception('boom'));

    expect(
      await repository.getPropertyDetails(1),
      const Left(UnknownFailure()),
    );
  });
}
