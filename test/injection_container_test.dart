import 'package:flutter_real_estate_assessment/feature/home/domain/repositories/home_repository.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/usecases/get_categories_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/usecases/get_featured_properties_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/usecases/get_recommendations_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/home/presentation/cubit/home_cubit.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/repositories/properties_repository.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/filter_properties_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_property_details_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/search_properties_usecase.dart';
import 'package:flutter_real_estate_assessment/injection_container.dart' as di;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(di.sl.reset);

  test('resolves the Home repository and its use cases', () async {
    await di.init();

    expect(di.sl<HomeRepository>(), isNotNull);
    expect(di.sl<GetFeaturedPropertiesUseCase>(), isNotNull);
    expect(di.sl<GetCategoriesUseCase>(), isNotNull);
    expect(di.sl<GetRecommendationsUseCase>(), isNotNull);
  });

  test('resolves the properties repository and its use cases', () async {
    await di.init();

    expect(di.sl<PropertiesRepository>(), isNotNull);
    expect(di.sl<SearchPropertiesUseCase>(), isNotNull);
    expect(di.sl<GetPropertyDetailsUseCase>(), isNotNull);
    expect(di.sl<FilterPropertiesUseCase>(), isNotNull);
  });

  test('creates a new HomeCubit for every Home screen', () async {
    await di.init();

    final first = di.sl<HomeCubit>();
    final second = di.sl<HomeCubit>();
    addTearDown(() async {
      await first.close();
      await second.close();
    });

    expect(identical(first, second), isFalse);
  });
}
