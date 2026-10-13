import 'package:flutter_real_estate_assessment/core/network/network_info.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/datasource/properties_local_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/datasource/properties_remote_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/repositories/properties_repository.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_categories_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_featured_properties_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_properties_by_category_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_properties_usecase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockPropertiesRemoteDataSource extends Mock
    implements PropertiesRemoteDataSource {}

class MockPropertiesLocalDataSource extends Mock
    implements PropertiesLocalDataSource {}

class MockPropertiesRepository extends Mock implements PropertiesRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockGetFeaturedPropertiesUseCase extends Mock
    implements GetFeaturedPropertiesUseCase {}

class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

class MockGetPropertiesUseCase extends Mock implements GetPropertiesUseCase {}

class MockGetPropertiesByCategoryUseCase extends Mock
    implements GetPropertiesByCategoryUseCase {}
