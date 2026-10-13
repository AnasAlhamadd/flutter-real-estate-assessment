import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_property_details_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/data/datasource/property_extras_mock_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/domain/entities/property_extras_entity.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/domain/usecases/get_property_extras_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  test('asks the repository for the property id', () async {
    final repository = MockPropertyExtrasRepository();
    when(
      () => repository.getPropertyExtras(7),
    ).thenAnswer((_) async => const Right(PropertyExtrasMockDataSource.sample));

    final result = await GetPropertyExtrasUseCase(repository)(
      const PropertyDetailsParams(id: 7),
    );

    expect(
      result,
      const Right<Failure, PropertyExtrasEntity>(
        PropertyExtrasMockDataSource.sample,
      ),
    );
    verify(() => repository.getPropertyExtras(7)).called(1);
  });
}
