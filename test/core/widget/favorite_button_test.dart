import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_real_estate_assessment/core/widget/favorite_button.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_widget.dart';
import '../../helpers/translations.dart';

AppSvgIcon _icon(WidgetTester tester) =>
    tester.widget<AppSvgIcon>(find.byType(AppSvgIcon));

Future<void> _pump(
  WidgetTester tester, {
  required bool isFavorite,
  FavoriteButtonVariant variant = FavoriteButtonVariant.onSurface,
  VoidCallback? onPressed,
  Locale locale = AppLocalization.english,
}) => pumpLocalizedWidget(
  tester,
  Center(
    child: FavoriteButton(
      isFavorite: isFavorite,
      variant: variant,
      onPressed: onPressed ?? () {},
    ),
  ),
  locale: locale,
);

void main() {
  testWidgets('outline heart when not a favorite, filled when it is', (
    tester,
  ) async {
    await _pump(tester, isFavorite: false);
    expect(_icon(tester).assetPath, ImagePath.heart);
    expect(_icon(tester).color, ColorsApp.black03);

    await _pump(tester, isFavorite: true);
    expect(_icon(tester).assetPath, ImagePath.heartBold);
    expect(_icon(tester).color, ColorsApp.primary);
  });

  testWidgets('stays white over the Featured photo', (tester) async {
    for (final isFavorite in [false, true]) {
      await _pump(
        tester,
        isFavorite: isFavorite,
        variant: FavoriteButtonVariant.onImage,
      );
      expect(_icon(tester).color, ColorsApp.white);
      expect(_icon(tester).size, AppSizes.featuredHeartSize);
    }
  });

  testWidgets('has a 44 px tap target around the Figma-sized heart', (
    tester,
  ) async {
    await _pump(tester, isFavorite: false);

    expect(
      tester.getSize(find.byType(FavoriteButton)),
      const Size.square(AppSizes.minTapTarget),
    );
    expect(_icon(tester).size, AppSizes.gridHeartSize);
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  });

  testWidgets('calls onPressed when tapped', (tester) async {
    var taps = 0;
    await _pump(tester, isFavorite: false, onPressed: () => taps++);

    await tester.tap(find.byType(FavoriteButton));

    expect(taps, 1);
  });

  for (final locale in AppLocalization.supportedLocales) {
    testWidgets('is announced as a toggle button with its action '
        '(${locale.languageCode})', (tester) async {
      final semantics = tester.ensureSemantics();

      await _pump(tester, isFavorite: false, locale: locale);
      expect(
        tester.getSemantics(find.byType(FavoriteButton)),
        matchesSemantics(
          label: translate(locale, 'favorites.add'),
          isButton: true,
          hasToggledState: true,
          hasTapAction: true,
        ),
      );

      await _pump(tester, isFavorite: true, locale: locale);
      expect(
        tester.getSemantics(find.byType(FavoriteButton)),
        matchesSemantics(
          label: translate(locale, 'favorites.remove'),
          isButton: true,
          hasToggledState: true,
          isToggled: true,
          hasTapAction: true,
        ),
      );
      semantics.dispose();
    });
  }
}
