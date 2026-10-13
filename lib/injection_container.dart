import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_real_estate_assessment/core/network/dio_client.dart';
import 'package:flutter_real_estate_assessment/core/network/network_info.dart';
import 'package:flutter_real_estate_assessment/core/services/phone_dialer.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/data/datasource/favorites_local_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/domain/repositories/favorites_repository.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/domain/usecases/get_favorites_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/domain/usecases/save_favorites_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/domain/usecases/toggle_favorite_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:flutter_real_estate_assessment/feature/home/data/datasource/home_local_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/home/data/datasource/home_remote_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/home/data/repositories/home_repository_impl.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/repositories/home_repository.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/usecases/get_categories_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/usecases/get_featured_properties_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/usecases/get_recommendations_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/home/presentation/cubit/home_cubit.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/datasource/properties_remote_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/repositories/properties_repository_impl.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/repositories/properties_repository.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/filter_properties_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_property_details_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/search_properties_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/data/datasource/property_extras_mock_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/data/repositories/property_extras_repository_impl.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/domain/repositories/property_extras_repository.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/domain/usecases/get_property_extras_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/cubit/property_details_cubit.dart';
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
    ..registerLazySingleton<PhoneDialer>(UrlLauncherPhoneDialer.new)
    // Data sources
    ..registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<HomeLocalDataSource>(
      () => HomeLocalDataSourceImpl(sl()),
    )
    ..registerLazySingleton<PropertiesRemoteDataSource>(
      () => PropertiesRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<FavoritesLocalDataSource>(
      () => FavoritesLocalDataSourceImpl(sl()),
    )
    // this mock: stands in for a remote source until an API has these fields.
    ..registerLazySingleton(PropertyExtrasMockDataSource.new)
    // Repositories
    ..registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(remote: sl(), local: sl(), networkInfo: sl()),
    )
    ..registerLazySingleton<PropertiesRepository>(
      () => PropertiesRepositoryImpl(remote: sl(), networkInfo: sl()),
    )
    ..registerLazySingleton<FavoritesRepository>(
      () => FavoritesRepositoryImpl(sl()),
    )
    ..registerLazySingleton<PropertyExtrasRepository>(
      () => PropertyExtrasRepositoryImpl(mockDataSource: sl()),
    )
    // Use cases
    ..registerLazySingleton(() => GetFeaturedPropertiesUseCase(sl()))
    ..registerLazySingleton(() => GetCategoriesUseCase(sl()))
    ..registerLazySingleton(() => GetRecommendationsUseCase(sl()))
    ..registerLazySingleton(() => SearchPropertiesUseCase(sl()))
    ..registerLazySingleton(() => GetPropertyDetailsUseCase(sl()))
    ..registerLazySingleton(() => GetPropertyExtrasUseCase(sl()))
    ..registerLazySingleton(FilterPropertiesUseCase.new)
    ..registerLazySingleton(() => GetFavoritesUseCase(sl()))
    ..registerLazySingleton(() => SaveFavoritesUseCase(sl()))
    ..registerLazySingleton(ToggleFavoriteUseCase.new)
    // Cubits
    ..registerFactory(
      () => HomeCubit(
        getFeaturedProperties: sl(),
        getCategories: sl(),
        getRecommendations: sl(),
        connectivityChanges: sl<NetworkInfo>().onStatusChange,
      ),
    )
    ..registerFactory(
      () => PropertyDetailsCubit(
        getPropertyDetails: sl(),
        getPropertyExtras: sl(),
      ),
    )
    ..registerFactory(
      () => FavoritesCubit(
        getFavorites: sl(),
        saveFavorites: sl(),
        toggleFavorite: sl(),
      ),
    );
}
