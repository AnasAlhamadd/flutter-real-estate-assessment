import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_back_button.dart';
import 'package:flutter_real_estate_assessment/core/widget/favorite_button.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_top_bar.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_favorites_repository.dart';
import '../../../../helpers/pump_widget.dart';
import '../../../../helpers/sample_properties.dart';

Future<FakeFavoritesRepository> _pump(
  WidgetTester tester, {
  PropertyEntity? property,
  Locale locale = AppLocalization.english,
}) async {
  final favorites = FakeFavoritesRepository();
  await pumpLocalizedWidget(
    tester,
    BlocProvider(
      create: (_) => favoritesCubitFor(favorites)..load(),
      child: Align(
        alignment: Alignment.topCenter,
        child: DetailsTopBar(property: property),
      ),
    ),
    locale: locale,
  );
  return favorites;
}

void main() {
  testWidgets('back at the start, heart at the end', (tester) async {
    await _pump(tester, property: sampleProperties.first);

    final back = tester.getCenter(find.byType(AppBackButton));
    final heart = tester.getCenter(find.byType(FavoriteButton));
    expect(back.dx, closeTo(AppSizes.detailsTopBarPadding + 14, 0.5));
    expect(
      heart.dx,
      closeTo(
        AppSizes.designSize.width - AppSizes.detailsTopBarPadding - 14,
        0.5,
      ),
    );
  });

  testWidgets('mirrors in Arabic', (tester) async {
    await _pump(
      tester,
      property: sampleProperties.first,
      locale: AppLocalization.arabic,
    );

    expect(
      tester.getCenter(find.byType(AppBackButton)).dx,
      greaterThan(tester.getCenter(find.byType(FavoriteButton)).dx),
    );
  });

  testWidgets('the heart saves the property as a favorite', (tester) async {
    final favorites = await _pump(tester, property: sampleProperties.first);

    await tester.tap(find.byType(FavoriteButton));
    await tester.pumpAndSettle();

    expect(favorites.saved.map((p) => p.id), [sampleProperties.first.id]);
    expect(
      tester.widget<FavoriteButton>(find.byType(FavoriteButton)).isFavorite,
      isTrue,
    );
  });

  testWidgets('no heart without a property', (tester) async {
    await _pump(tester);

    expect(find.byType(AppBackButton), findsOneWidget);
    expect(find.byType(FavoriteButton), findsNothing);
  });
}
