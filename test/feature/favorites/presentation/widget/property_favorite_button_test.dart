import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/utils/formatters.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_real_estate_assessment/core/widget/favorite_button.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/presentation/widget/favorites_failure_listener.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/presentation/widget/property_favorite_button.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/featured_property_card.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/property_grid_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_favorites_repository.dart';
import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_widget.dart';
import '../../../../helpers/translations.dart';

const _property = PropertyEntity(
  id: 42,
  title: 'Essence Mascara Lash Princess',
  price: 1234567.89,
  rating: 4.94,
  category: 'beauty',
  brand: 'Essence',
);

/// Where Figma puts the heart, from the card edges, for the current scale.
typedef _Slot = ({double end, double bottom, double size});

_Slot _featuredSlot() => (
  end: AppSizes.featuredContentHorizontalPadding.r,
  bottom: AppSizes.featuredContentBottomPadding.r,
  size: AppSizes.featuredHeartSize.r,
);

_Slot _gridSlot() => (
  end: AppSizes.gridCardPaddingSide.w,
  bottom: AppSizes.gridCardPaddingBottom.h,
  size: AppSizes.gridHeartSize.r,
);

class _Case {
  const _Case(this.name, this.card, this.cardBuilder, this.slot);

  final String name;
  final Type card;
  final Widget Function(VoidCallback onTap) cardBuilder;
  final _Slot Function() slot;
}

final _cases = [
  _Case(
    'FeaturedPropertyCard',
    FeaturedPropertyCard,
    (onTap) => Center(
      child: FeaturedPropertyCard(
        property: _property,
        onTap: onTap,
        favoriteButton: const PropertyFavoriteButton(
          property: _property,
          variant: FavoriteButtonVariant.onImage,
        ),
      ),
    ),
    _featuredSlot,
  ),
  _Case(
    'PropertyGridCard',
    PropertyGridCard,
    (onTap) => _GridCell(
      child: PropertyGridCard(
        property: _property,
        onTap: onTap,
        favoriteButton: const PropertyFavoriteButton(property: _property),
      ),
    ),
    _gridSlot,
  ),
];

/// One cell of the Home two-column grid.
class _GridCell extends StatelessWidget {
  const _GridCell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.screenHorizontalPadding.w,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: child),
          SizedBox(width: AppSizes.gridHorizontalGap.w),
          const Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
  }
}

Widget _withFavorites(FakeFavoritesRepository repository, Widget child) =>
    BlocProvider(
      create: (_) => favoritesCubitFor(repository)..load(),
      child: FavoritesFailureListener(child: child),
    );

Finder get _heartIcon => find.descendant(
  of: find.byType(FavoriteButton),
  matching: find.byType(AppSvgIcon),
);

void main() {
  for (final testCase in _cases) {
    group(testCase.name, () {
      testWidgetsInLayouts('centers the heart on the Figma heart slot', (
        tester,
        locale,
        size,
        textScale,
      ) async {
        await pumpLocalizedWidget(
          tester,
          _withFavorites(
            FakeFavoritesRepository(),
            testCase.cardBuilder(() {}),
          ),
          locale: locale,
          size: size,
          textScale: textScale,
        );

        expectNoLayoutErrors(tester);
        final card = tester.getRect(find.byType(testCase.card));
        final heart = tester.getRect(_heartIcon);
        final slot = testCase.slot();
        final rtl = directionOf(locale) == TextDirection.rtl;
        expect(heart.width, closeTo(slot.size, 0.01));
        expect(
          rtl ? heart.left - card.left : card.right - heart.right,
          closeTo(slot.end, 0.01),
        );
        expect(card.bottom - heart.bottom, closeTo(slot.bottom, 0.01));
        expect(
          tester.getSize(find.byType(FavoriteButton)),
          const Size.square(AppSizes.minTapTarget),
        );
        expect(
          card.contains(tester.getCenter(find.byType(FavoriteButton))),
          isTrue,
        );
      });

      testWidgetsInLayouts('the price never runs under the heart', (
        tester,
        locale,
        size,
        textScale,
      ) async {
        await pumpLocalizedWidget(
          tester,
          _withFavorites(
            FakeFavoritesRepository(),
            testCase.cardBuilder(() {}),
          ),
          locale: locale,
          size: size,
          textScale: textScale,
        );

        final price = tester.getRect(
          find.descendant(
            of: find.byType(testCase.card),
            matching: find.text(Formatters.price(_property.price)),
          ),
        );
        final heart = tester.getRect(_heartIcon);
        expect(price.overlaps(heart), isFalse);
      });

      testWidgets('tapping the heart toggles it without opening the card', (
        tester,
      ) async {
        final repository = FakeFavoritesRepository();
        var cardTaps = 0;
        await pumpLocalizedWidget(
          tester,
          _withFavorites(repository, testCase.cardBuilder(() => cardTaps++)),
        );

        await tester.tap(find.byType(FavoriteButton));
        await tester.pumpAndSettle();
        expect(
          tester.widget<AppSvgIcon>(_heartIcon).assetPath,
          ImagePath.heartBold,
        );
        expect(repository.saved.map((p) => p.id), [_property.id]);
        expect(cardTaps, 0);

        await tester.tap(find.byType(FavoriteButton));
        await tester.pumpAndSettle();
        expect(
          tester.widget<AppSvgIcon>(_heartIcon).assetPath,
          ImagePath.heart,
        );
        expect(repository.saved, isEmpty);

        await tester.tap(find.text(_property.title));
        expect(cardTaps, 1);
      });
    });
  }

  testWidgets('shows a saved favorite as filled', (tester) async {
    await pumpLocalizedWidget(
      tester,
      _withFavorites(
        FakeFavoritesRepository(saved: const [_property]),
        _cases.last.cardBuilder(() {}),
      ),
    );

    expect(
      tester.widget<AppSvgIcon>(_heartIcon).assetPath,
      ImagePath.heartBold,
    );
  });

  for (final locale in AppLocalization.supportedLocales) {
    testWidgets(
      'a failed save reverts the heart and says why (${locale.languageCode})',
      (tester) async {
        final repository = FakeFavoritesRepository()
          ..saveFailure = const CacheFailure();
        await pumpLocalizedWidget(
          tester,
          _withFavorites(repository, _cases.last.cardBuilder(() {})),
          locale: locale,
        );

        await tester.tap(find.byType(FavoriteButton));
        await tester.pumpAndSettle();

        expect(
          tester.widget<AppSvgIcon>(_heartIcon).assetPath,
          ImagePath.heart,
        );
        expect(
          find.text(translate(locale, 'favorites.save_failed')),
          findsOneWidget,
        );
      },
    );
  }

  testWidgets('the limit message appears each time it is hit', (tester) async {
    final repository = FakeFavoritesRepository(
      saved: [
        for (var id = 1; id <= 100; id++)
          PropertyEntity(
            id: 1000 + id,
            title: '$id',
            price: 1,
            rating: 1,
            category: 'beauty',
          ),
      ],
    );
    await pumpLocalizedWidget(
      tester,
      _withFavorites(repository, _cases.last.cardBuilder(() {})),
    );
    final message = find.text(
      translate(AppLocalization.english, 'favorites.limit_reached'),
    );

    await tester.tap(find.byType(FavoriteButton));
    await tester.pumpAndSettle();
    expect(message, findsOneWidget);

    ScaffoldMessenger.of(
      tester.element(find.byType(FavoriteButton)),
    ).hideCurrentSnackBar();
    await tester.pumpAndSettle();
    expect(message, findsNothing);

    await tester.tap(find.byType(FavoriteButton));
    await tester.pumpAndSettle();
    expect(message, findsOneWidget);
  });
}
