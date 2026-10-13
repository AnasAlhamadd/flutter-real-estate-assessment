import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/data/datasource/property_extras_mock_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/data/repositories/property_extras_repository_impl.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/domain/entities/property_extras_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  group('PropertyExtrasMockDataSource', () {
    test('returns the Figma sample for every property', () async {
      const source = PropertyExtrasMockDataSource();

      expect(
        await source.getPropertyExtras(1),
        PropertyExtrasMockDataSource.sample,
      );
      expect(
        await source.getPropertyExtras(99),
        PropertyExtrasMockDataSource.sample,
      );
    });

    test('the sample matches the Figma Details screen', () {
      const sample = PropertyExtrasMockDataSource.sample;

      expect(
        (sample.bedrooms, sample.bathrooms, sample.areaSqft),
        (8, 3, 2000),
      );
      expect(sample.agent.name, 'Natasya Wilodra');
      expect(sample.agent.role, AgentRole.owner);
      expect(sample.facilities, PropertyFacility.values);
      expect(sample.reviewLikes, [938, 254, 61]);
    });

    test('the agent number is a fictional 555-01xx number', () {
      expect(
        PropertyExtrasMockDataSource.sample.agent.phone,
        matches(RegExp(r'^\+1555010\d$')),
      );
    });
  });

  group('PropertyExtrasRepositoryImpl', () {
    test('wraps the mock source in Right', () async {
      const repository = PropertyExtrasRepositoryImpl(
        mockDataSource: PropertyExtrasMockDataSource(),
      );

      expect(
        await repository.getPropertyExtras(1),
        const Right<Failure, PropertyExtrasEntity>(
          PropertyExtrasMockDataSource.sample,
        ),
      );
    });

    test('a throwing source becomes UnknownFailure', () async {
      final source = MockPropertyExtrasMockDataSource();
      when(() => source.getPropertyExtras(any())).thenThrow(StateError('x'));
      final repository = PropertyExtrasRepositoryImpl(mockDataSource: source);

      expect(
        await repository.getPropertyExtras(1),
        const Left<Failure, PropertyExtrasEntity>(UnknownFailure()),
      );
    });
  });
}
