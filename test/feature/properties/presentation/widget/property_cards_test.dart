import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_network_image.dart';
import 'package:flutter_real_estate_assessment/core/widget/rating_badge.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/featured_property_card.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/property_grid_card.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/property_list_card.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_widget.dart';

typedef _CardBuilder =
    Widget Function(
      PropertyEntity property, {
      required VoidCallback onTap,
      String? categoryName,
      Widget? favoriteButton,
    });

const _property = PropertyEntity(
  id: 1,
  title: 'Essence Mascara Lash Princess',
  price: 12219,
  rating: 4.94,
  category: 'beauty',
  brand: 'Essence',
);

final _longProperty = PropertyEntity(
  id: 2,
  title: 'Very Long Luxury Penthouse Apartment With A Sea View ' * 3,
  price: 1234567.89,
  rating: 5,
  category: 'home-decoration',
  brand: 'An Exceptionally Long Brand Name Used As Location ' * 2,
  thumbnailUrl: '',
);

final Map<String, _CardBuilder> _cards = {
  'FeaturedPropertyCard':
      (property, {required onTap, categoryName, favoriteButton}) => Center(
        child: FeaturedPropertyCard(
          property: property,
          onTap: onTap,
          categoryName: categoryName,
          favoriteButton: favoriteButton,
        ),
      ),
  'PropertyGridCard':
      (property, {required onTap, categoryName, favoriteButton}) => _GridCell(
        child: PropertyGridCard(
          property: property,
          onTap: onTap,
          categoryName: categoryName,
          favoriteButton: favoriteButton,
        ),
      ),
  'PropertyListCard':
      (property, {required onTap, categoryName, favoriteButton}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: PropertyListCard(
            property: property,
            onTap: onTap,
            categoryName: categoryName,
            favoriteButton: favoriteButton,
          ),
        ),
      ),
};

/// One cell of the Home two-column grid (20 side padding, 16 gap).
class _GridCell extends StatelessWidget {
  const _GridCell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width - 20 * 2 - 16) / 2;
    return Center(
      child: SizedBox(width: width, child: child),
    );
  }
}

void main() {
  for (final MapEntry(key: name, value: build) in _cards.entries) {
    group(name, () {
      testWidgetsInLayouts('shows title, location, price and rating', (
        tester,
        locale,
        size,
        textScale,
      ) async {
        await pumpLocalizedWidget(
          tester,
          build(_property, onTap: () {}),
          locale: locale,
          size: size,
          textScale: textScale,
        );

        expectNoLayoutErrors(tester);
        expectDirectionFor(tester, locale);
        expect(find.text(_property.title), findsOneWidget);
        expect(find.text('Essence'), findsOneWidget);
        expect(find.text(r'$12219'), findsOneWidget);
        expect(find.text('4.9'), findsOneWidget);
      });

      testWidgetsInLayouts('places the rating badge at the image end', (
        tester,
        locale,
        size,
        textScale,
      ) async {
        await pumpLocalizedWidget(
          tester,
          build(_property, onTap: () {}),
          locale: locale,
          size: size,
          textScale: textScale,
        );

        final badge = tester.getRect(find.byType(RatingBadge));
        final image = tester.getRect(find.byType(AppNetworkImage));
        expect(image.contains(badge.center), isTrue);
        expect(badge.center.dy, lessThan(image.center.dy));
        if (directionOf(locale) == TextDirection.ltr) {
          expect(badge.center.dx, greaterThan(image.center.dx));
        } else {
          expect(badge.center.dx, lessThan(image.center.dx));
        }
      });

      testWidgetsInLayouts('ellipsizes long text without overflow', (
        tester,
        locale,
        size,
        textScale,
      ) async {
        await pumpLocalizedWidget(
          tester,
          build(_longProperty, onTap: () {}),
          locale: locale,
          size: size,
          textScale: textScale,
        );

        expectNoLayoutErrors(tester);
        final title = tester.widget<Text>(find.text(_longProperty.title));
        expect(title.overflow, TextOverflow.ellipsis);
        expect(title.maxLines, isNotNull);
        final location = tester.widget<Text>(
          find.text(_longProperty.brand!.trim()),
        );
        expect(location.overflow, TextOverflow.ellipsis);
        expect(location.maxLines, 1);
        expect(find.text(r'$1234567.89'), findsOneWidget);
      });

      testWidgets('shows the image placeholder for a missing image URL', (
        tester,
      ) async {
        await pumpLocalizedWidget(tester, build(_longProperty, onTap: () {}));

        expectNoLayoutErrors(tester);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is ColoredBox && widget.color == ColorsApp.greyscale400,
          ),
          findsOneWidget,
        );
      });

      testWidgets('calls onTap when tapped', (tester) async {
        var taps = 0;
        await pumpLocalizedWidget(
          tester,
          build(_property, onTap: () => taps++),
        );

        await tester.tap(find.text(_property.title));
        expect(taps, 1);
      });

      testWidgets('falls back to the category name, then the slug', (
        tester,
      ) async {
        const noBrand = PropertyEntity(
          id: 3,
          title: 'Plain item',
          price: 9.99,
          rating: 3,
          category: 'home-decoration',
          brand: '  ',
        );
        await pumpLocalizedWidget(
          tester,
          build(noBrand, onTap: () {}, categoryName: 'Home Decoration'),
        );
        expect(find.text('Home Decoration'), findsOneWidget);
        expect(find.text(r'$9.99'), findsOneWidget);

        await pumpLocalizedWidget(tester, build(noBrand, onTap: () {}));
        expect(find.text('home-decoration'), findsOneWidget);
      });

      testWidgets('shows the favorite button only when provided', (
        tester,
      ) async {
        const heartKey = Key('favorite');
        await pumpLocalizedWidget(tester, build(_property, onTap: () {}));
        expect(find.byKey(heartKey), findsNothing);

        await pumpLocalizedWidget(
          tester,
          build(
            _property,
            onTap: () {},
            favoriteButton: const SizedBox.square(key: heartKey, dimension: 24),
          ),
        );
        expect(find.byKey(heartKey), findsOneWidget);
      });
    });
  }

  testWidgets('Arabic UI keeps English API data and Western digits', (
    tester,
  ) async {
    await pumpLocalizedWidget(
      tester,
      _cards['PropertyListCard']!(_property, onTap: () {}),
      locale: AppLocalization.arabic,
    );

    expect(find.text(_property.title), findsOneWidget);
    expect(find.text(r'$12219'), findsOneWidget);
    expect(find.text('4.9'), findsOneWidget);
  });
}
