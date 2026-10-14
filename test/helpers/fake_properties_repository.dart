import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/utils/cancellation_signal.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/properties_page_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/repositories/properties_repository.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_property_details_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/data/datasource/property_extras_mock_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/data/repositories/property_extras_repository_impl.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/domain/repositories/property_extras_repository.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/domain/usecases/get_property_extras_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/cubit/property_details_cubit.dart';

import 'sample_properties.dart';

/// In-memory [PropertiesRepository] for widget tests. Details come from
/// [details] by id (unknown ids are `NotFoundFailure`); [gate] holds every
/// details response until it completes, so loading states can be observed.
///
/// A full set is [fullSets]`[query]` (`''` for the whole catalog), or the
/// sample items whose title contains the query. [fullSetGate] holds those.
class FakePropertiesRepository implements PropertiesRepository {
  FakePropertiesRepository({
    Map<int, Either<Failure, PropertyEntity>>? details,
    this.fullSets = const {},
  }) : details = details ?? {1: Right(sampleDetailedProperty)};

  Map<int, Either<Failure, PropertyEntity>> details;
  Map<String, Either<Failure, PropertiesPageEntity>> fullSets;
  Future<void>? gate;
  Future<void>? fullSetGate;

  /// Every details request, by id.
  final List<int> detailRequests = [];

  /// Every full-set request, as `<query>` or `<query>:refresh`.
  final List<String> fullSetRequests = [];

  @override
  Future<Either<Failure, PropertyEntity>> getPropertyDetails(int id) async {
    detailRequests.add(id);
    await gate;
    return details[id] ?? const Left(NotFoundFailure());
  }

  @override
  Future<Either<Failure, PropertiesPageEntity>> searchProperties({
    required String query,
    CancellationSignal? cancellation,
    bool forceRefresh = false,
  }) => _fullSet(query, forceRefresh: forceRefresh);

  @override
  Future<Either<Failure, PropertiesPageEntity>> getAllProperties({
    CancellationSignal? cancellation,
    bool forceRefresh = false,
  }) => _fullSet('', forceRefresh: forceRefresh);

  Future<Either<Failure, PropertiesPageEntity>> _fullSet(
    String query, {
    required bool forceRefresh,
  }) async {
    fullSetRequests.add(forceRefresh ? '$query:refresh' : query);
    await fullSetGate;
    return fullSets[query] ??
        Right(
          pageOf(
            sampleProperties
                .where((item) => item.title.toLowerCase().contains(query))
                .toList(),
          ),
        );
  }
}

/// [extras] defaults to the app's mock source.
PropertyDetailsCubit propertyDetailsCubitFor(
  PropertiesRepository repository, {
  PropertyExtrasRepository extras = const PropertyExtrasRepositoryImpl(
    mockDataSource: PropertyExtrasMockDataSource(),
  ),
}) => PropertyDetailsCubit(
  getPropertyDetails: GetPropertyDetailsUseCase(repository),
  getPropertyExtras: GetPropertyExtrasUseCase(extras),
);
