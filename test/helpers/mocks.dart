import 'package:flutter_real_estate_assessment/core/network/network_info.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/data/datasource/favorites_local_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/home/data/datasource/home_local_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/home/data/datasource/home_remote_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/repositories/home_repository.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/usecases/get_categories_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/usecases/get_featured_properties_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/usecases/get_recommendations_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/datasource/properties_remote_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/repositories/properties_repository.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_property_details_usecase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockHomeRemoteDataSource extends Mock implements HomeRemoteDataSource {}

class MockHomeLocalDataSource extends Mock implements HomeLocalDataSource {}

class MockHomeRepository extends Mock implements HomeRepository {}

class MockPropertiesRemoteDataSource extends Mock
    implements PropertiesRemoteDataSource {}

class MockPropertiesRepository extends Mock implements PropertiesRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockGetFeaturedPropertiesUseCase extends Mock
    implements GetFeaturedPropertiesUseCase {}

class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

class MockGetRecommendationsUseCase extends Mock
    implements GetRecommendationsUseCase {}

class MockFavoritesLocalDataSource extends Mock
    implements FavoritesLocalDataSource {}

class MockGetPropertyDetailsUseCase extends Mock
    implements GetPropertyDetailsUseCase {}
