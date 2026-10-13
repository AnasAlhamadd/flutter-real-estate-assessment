import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_real_estate_assessment/core/network/dio_client.dart';
import 'package:flutter_real_estate_assessment/core/network/network_info.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/datasource/properties_local_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/datasource/properties_remote_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/repositories/properties_repository_impl.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/repositories/properties_repository.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/filter_properties_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_categories_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_featured_properties_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_properties_by_category_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_properties_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_property_details_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/search_properties_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  final preferences = await SharedPreferences.getInstance();

  // External
  sl
    ..registerLazySingleton<SharedPreferences>(() => preferences)
    ..registerLazySingleton<Connectivity>(Connectivity.new)
    ..registerLazySingleton<Dio>(DioClient.createDio)
    // Core
    ..registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()))
    ..registerLazySingleton<DioClient>(() => DioClient(sl()))
    // Data sources
    ..registerLazySingleton<PropertiesRemoteDataSource>(
      () => PropertiesRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<PropertiesLocalDataSource>(
      () => PropertiesLocalDataSourceImpl(sl()),
    )
    // Repositories
    ..registerLazySingleton<PropertiesRepository>(
      () => PropertiesRepositoryImpl(
        remote: sl(),
        local: sl(),
        networkInfo: sl(),
      ),
    )
    // Use cases
    ..registerLazySingleton(() => GetPropertiesUseCase(sl()))
    ..registerLazySingleton(() => GetPropertiesByCategoryUseCase(sl()))
    ..registerLazySingleton(() => SearchPropertiesUseCase(sl()))
    ..registerLazySingleton(() => GetFeaturedPropertiesUseCase(sl()))
    ..registerLazySingleton(() => GetCategoriesUseCase(sl()))
    ..registerLazySingleton(() => GetPropertyDetailsUseCase(sl()))
    ..registerLazySingleton(FilterPropertiesUseCase.new);
}
