import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_back_button.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_bottom_nav_bar.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_button.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_divider.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_network_image.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_search_field.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_real_estate_assessment/core/widget/category_chip.dart';
import 'package:flutter_real_estate_assessment/core/widget/circle_icon_button.dart';
import 'package:flutter_real_estate_assessment/core/widget/empty_view.dart';
import 'package:flutter_real_estate_assessment/core/widget/error_view.dart';
import 'package:flutter_real_estate_assessment/core/widget/loading_view.dart';
import 'package:flutter_real_estate_assessment/core/widget/rating_badge.dart';
import 'package:flutter_real_estate_assessment/core/widget/section_header.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/layout_expectations.dart';
import '../../helpers/pump_widget.dart';
import '../../helpers/translations.dart';

const _longText =
    'An extremely long label that cannot possibly fit on one line of a phone';

String _assetOf(SvgPicture picture) =>
    (picture.bytesLoader as SvgAssetLoader).assetName;

Finder _svg(String asset) => find.byWidgetPredicate(
  (widget) => widget is SvgPicture && _assetOf(widget) == asset,
);

Finder get _placeholder => find.byWidgetPredicate(
  (widget) => widget is ColoredBox && widget.color == ColorsApp.greyscale400,
);

void main() {
  group('AppSearchField', () {
    testWidgetsInLayouts('shows the translated hint and both icons', (
      tester,
      locale,
      size,
      textScale,
    ) async {
      await pumpLocalizedWidget(
        tester,
        Padding(
          padding: const EdgeInsets.all(20),
          child: AppSearchField(onFilterTap: () {}),
        ),
        locale: locale,
        size: size,
        textScale: textScale,
      );

      expectNoLayoutErrors(tester);
      expect(
        find.text(translate(locale, 'common.search_hint')),
        findsOneWidget,
      );
      expect(_svg(ImagePath.search), findsOneWidget);
      expect(_svg(ImagePath.filter), findsOneWidget);

      final search = tester.getCenter(_svg(ImagePath.search));
      final filter = tester.getCenter(_svg(ImagePath.filter));
      if (directionOf(locale) == TextDirection.ltr) {
        expect(search.dx, lessThan(filter.dx));
      } else {
        expect(search.dx, greaterThan(filter.dx));
      }
    });

    testWidgets('reports typed text and filter taps', (tester) async {
      final typed = <String>[];
      var filterTaps = 0;
      await pumpLocalizedWidget(
        tester,
        AppSearchField(onChanged: typed.add, onFilterTap: () => filterTaps++),
      );

      await tester.enterText(find.byType(TextField), 'villa');
      await tester.tap(_svg(ImagePath.filter));

      expect(typed, ['villa']);
      expect(filterTaps, 1);
    });

    testWidgets('hides the filter button without a callback', (tester) async {
      await pumpLocalizedWidget(tester, const AppSearchField());

      expect(_svg(ImagePath.filter), findsNothing);
    });

    testWidgets('read-only field forwards taps without editing', (
      tester,
    ) async {
      var taps = 0;
      await pumpLocalizedWidget(
        tester,
        AppSearchField(readOnly: true, onTap: () => taps++),
      );

      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'ignored');

      expect(taps, greaterThanOrEqualTo(1));
      expect(tester.widget<TextField>(find.byType(TextField)).readOnly, isTrue);
    });
  });

  group('SectionHeader', () {
    testWidgetsInLayouts('shows "See All" and ellipsizes a long title', (
      tester,
      locale,
      size,
      textScale,
    ) async {
      var taps = 0;
      await pumpLocalizedWidget(
        tester,
        Padding(
          padding: const EdgeInsets.all(20),
          child: SectionHeader(title: _longText, onSeeAll: () => taps++),
        ),
        locale: locale,
        size: size,
        textScale: textScale,
      );

      expectNoLayoutErrors(tester);
      expectDirectionFor(tester, locale);
      await tester.tap(find.text(translate(locale, 'common.see_all')));
      expect(taps, 1);
    });

    testWidgets('hides "See All" without a callback', (tester) async {
      await pumpLocalizedWidget(tester, const SectionHeader(title: 'Featured'));

      expect(find.text('See All'), findsNothing);
    });

    for (final locale in AppLocalization.supportedLocales) {
      testWidgets(
        'puts the leading widget before the title (${locale.languageCode})',
        (tester) async {
          await pumpLocalizedWidget(
            tester,
            const SectionHeader(
              title: 'Reviews',
              leading: SizedBox.square(key: Key('leading'), dimension: 24),
            ),
            locale: locale,
          );

          final leading = tester.getRect(find.byKey(const Key('leading')));
          final title = tester.getRect(find.text('Reviews'));
          if (directionOf(locale) == TextDirection.ltr) {
            expect(leading.right, lessThanOrEqualTo(title.left));
          } else {
            expect(leading.left, greaterThanOrEqualTo(title.right));
          }
        },
      );
    }
  });

  group('CategoryChip', () {
    testWidgets('uses the primary fill only when selected and reports taps', (
      tester,
    ) async {
      var taps = 0;
      await pumpLocalizedWidget(
        tester,
        Row(
          children: [
            CategoryChip(label: 'All', selected: true, onTap: () => taps++),
            CategoryChip(label: 'Beauty', selected: false, onTap: () {}),
          ],
        ),
      );

      Color fillOf(String label) => tester
          .widget<Material>(
            find
                .ancestor(of: find.text(label), matching: find.byType(Material))
                .first,
          )
          .color!;
      expect(fillOf('All'), ColorsApp.primary);
      expect(fillOf('Beauty'), ColorsApp.primary4);

      await tester.tap(find.text('All'));
      expect(taps, 1);
    });
  });

  group('AppButton', () {
    testWidgetsInLayouts('ellipsizes a long label and reports taps', (
      tester,
      locale,
      size,
      textScale,
    ) async {
      var taps = 0;
      await pumpLocalizedWidget(
        tester,
        Padding(
          padding: const EdgeInsets.all(20),
          child: AppButton(label: _longText, onPressed: () => taps++),
        ),
        locale: locale,
        size: size,
        textScale: textScale,
      );

      expectNoLayoutErrors(tester);
      await tester.tap(find.byType(AppButton));
      expect(taps, 1);
    });
  });

  group('AppBackButton', () {
    testWidgets('mirrors its arrow and pops the current route', (tester) async {
      await pumpLocalizedWidget(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    const Scaffold(body: Center(child: AppBackButton())),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final arrow = tester.widget<SvgPicture>(_svg(ImagePath.arrowLeft));
      expect(arrow.matchTextDirection, isTrue);

      await tester.tap(find.byType(AppBackButton));
      await tester.pumpAndSettle();
      expect(find.byType(AppBackButton), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('plain: a 28 px Black/01 arrow in a 44 px target, no circle', (
      tester,
    ) async {
      var taps = 0;
      await pumpLocalizedWidget(
        tester,
        Center(child: AppBackButton.plain(onPressed: () => taps++)),
      );

      final arrow = tester.widget<AppSvgIcon>(find.byType(AppSvgIcon));
      expect(arrow.assetPath, ImagePath.arrowLeft);
      expect(arrow.size, AppSizes.detailsTopBarIconSize);
      expect(arrow.color, ColorsApp.black01);
      expect(arrow.matchTextDirection, isTrue);
      expect(find.byType(CircleIconButton), findsNothing);
      expect(
        tester.getSize(find.byType(AppBackButton)),
        const Size.square(AppSizes.minTapTarget),
      );
      expect(
        find.bySemanticsLabel(
          MaterialLocalizations.of(
            tester.element(find.byType(AppBackButton)),
          ).backButtonTooltip,
        ),
        findsOneWidget,
      );

      await tester.tap(find.byType(AppBackButton));
      expect(taps, 1);
    });
  });

  group('AppDivider', () {
    testWidgets('is a full-width 1 px Primary 10% line', (tester) async {
      await pumpLocalizedWidget(
        tester,
        const Padding(padding: EdgeInsets.all(20), child: AppDivider()),
      );

      expect(
        tester.getSize(find.byType(AppDivider)),
        Size(AppSizes.designSize.width - 40, AppDivider.thickness),
      );
      expect(
        tester
            .widget<ColoredBox>(
              find.descendant(
                of: find.byType(AppDivider),
                matching: find.byType(ColoredBox),
              ),
            )
            .color,
        ColorsApp.primary10,
      );
    });
  });

  group('RatingBadge', () {
    testWidgets('shows the rating with one decimal for every size', (
      tester,
    ) async {
      await pumpLocalizedWidget(
        tester,
        const Column(
          children: [
            RatingBadge(rating: 4.94, size: RatingBadgeSize.large),
            RatingBadge(rating: 5, size: RatingBadgeSize.medium),
            RatingBadge(rating: 0, size: RatingBadgeSize.small),
          ],
        ),
      );

      expect(find.text('4.9'), findsOneWidget);
      expect(find.text('5.0'), findsOneWidget);
      expect(find.text('0.0'), findsOneWidget);
      expect(_svg(ImagePath.star), findsNWidgets(3));
    });
  });

  group('State views', () {
    testWidgetsInLayouts('ErrorView shows the failure message and retries', (
      tester,
      locale,
      size,
      textScale,
    ) async {
      var retries = 0;
      await pumpLocalizedWidget(
        tester,
        ErrorView(failure: const NetworkFailure(), onRetry: () => retries++),
        locale: locale,
        size: size,
        textScale: textScale,
      );

      expectNoLayoutErrors(tester);
      expect(
        find.text(translate(locale, 'errors.no_internet')),
        findsOneWidget,
      );
      await tester.tap(find.text(translate(locale, 'common.retry')));
      expect(retries, 1);
    });

    testWidgetsInLayouts('EmptyView shows the translated message', (
      tester,
      locale,
      size,
      textScale,
    ) async {
      await pumpLocalizedWidget(
        tester,
        const EmptyView(),
        locale: locale,
        size: size,
        textScale: textScale,
      );

      expectNoLayoutErrors(tester);
      expect(find.text(translate(locale, 'common.empty')), findsOneWidget);
    });

    testWidgets('LoadingView shows a labelled progress indicator', (
      tester,
    ) async {
      await pumpLocalizedWidget(tester, const LoadingView(), settle: false);

      expectNoLayoutErrors(tester);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          translate(AppLocalization.english, 'common.loading'),
        ),
        findsOneWidget,
      );
    });
  });

  group('AppNetworkImage', () {
    for (final url in [null, '', '   ']) {
      testWidgets(
        'shows the placeholder for ${url == null ? 'null' : '"$url"'}',
        (tester) async {
          await pumpLocalizedWidget(
            tester,
            SizedBox.square(dimension: 100, child: AppNetworkImage(url: url)),
          );

          expectNoLayoutErrors(tester);
          expect(_placeholder, findsOneWidget);
        },
      );
    }

    testWidgets('keeps the placeholder and throws nothing for a bad URL', (
      tester,
    ) async {
      await pumpLocalizedWidget(
        tester,
        const SizedBox.square(
          dimension: 100,
          child: AppNetworkImage(url: 'https://invalid.example/missing.png'),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expectNoLayoutErrors(tester);
      expect(_placeholder, findsOneWidget);
    });
  });

  group('AppBottomNavBar', () {
    const items = [
      AppBottomNavItem(
        label: 'Home',
        activeIcon: ImagePath.homeBold,
        inactiveIcon: ImagePath.homeLight,
      ),
      AppBottomNavItem(
        label: 'Explore',
        activeIcon: ImagePath.searchBold,
        inactiveIcon: ImagePath.search,
      ),
      AppBottomNavItem(
        label: 'Profile',
        activeIcon: ImagePath.profileBold,
        inactiveIcon: ImagePath.profileLight,
      ),
    ];

    testWidgetsInLayouts('uses bold icons for the active tab only', (
      tester,
      locale,
      size,
      textScale,
    ) async {
      final taps = <int>[];
      await pumpLocalizedWidget(
        tester,
        Align(
          alignment: Alignment.bottomCenter,
          child: AppBottomNavBar(
            items: items,
            currentIndex: 1,
            onTap: taps.add,
          ),
        ),
        locale: locale,
        size: size,
        textScale: textScale,
      );

      expectNoLayoutErrors(tester);
      expect(_svg(ImagePath.homeLight), findsOneWidget);
      expect(_svg(ImagePath.searchBold), findsOneWidget);
      expect(_svg(ImagePath.profileLight), findsOneWidget);
      expect(_svg(ImagePath.homeBold), findsNothing);

      final home = tester.getCenter(find.text('Home'));
      final profile = tester.getCenter(find.text('Profile'));
      if (directionOf(locale) == TextDirection.ltr) {
        expect(home.dx, lessThan(profile.dx));
      } else {
        expect(home.dx, greaterThan(profile.dx));
      }

      await tester.tap(find.text('Profile'));
      expect(taps, [2]);
    });
  });
}
