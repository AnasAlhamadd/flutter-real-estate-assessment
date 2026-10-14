import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/feature/profile/presentation/widget/profile_menu_row.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_widget.dart';
import '../../../../helpers/svg_finders.dart';
import '../../../../helpers/translations.dart';

Widget _row({String? value, VoidCallback? onTap}) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: Column(
    children: [
      ProfileMenuRow(
        icon: ImagePath.language,
        labelKey: AppTextKeys.languageTitle,
        value: value,
        onTap: onTap ?? () {},
      ),
    ],
  ),
);

void main() {
  group('ProfileMenuRow', () {
    testWidgetsInLayouts('icon at the start, chevron at the end', (
      tester,
      locale,
      size,
      textScale,
    ) async {
      await pumpLocalizedWidget(
        tester,
        _row(value: 'English'),
        locale: locale,
        size: size,
        textScale: textScale,
      );

      expectNoLayoutErrors(tester);
      expect(find.text(translate(locale, 'language.title')), findsOneWidget);
      expect(find.text('English'), findsOneWidget);

      final icon = tester.getRect(svgAsset(ImagePath.language));
      final chevron = tester.getRect(svgAsset(ImagePath.arrowRight));
      if (directionOf(locale) == TextDirection.ltr) {
        expect(icon.left, 20);
        expect(chevron.right, size.width - 20);
      } else {
        expect(icon.right, size.width - 20);
        expect(chevron.left, 20);
      }
      expect(
        tester
            .widget<SvgPicture>(svgAsset(ImagePath.arrowRight))
            .matchTextDirection,
        isTrue,
      );
    });

    testWidgets('keeps the Figma sizes at the design size', (tester) async {
      await pumpLocalizedWidget(tester, _row());

      expect(
        tester.getSize(svgAsset(ImagePath.language)),
        const Size.square(28),
      );
      expect(
        tester.getSize(svgAsset(ImagePath.arrowRight)),
        const Size.square(20),
      );
      final icon = tester.getRect(svgAsset(ImagePath.language));
      final label = tester.getRect(find.text('Language'));
      expect(label.left - icon.right, AppSizes.profileMenuIconGap);
    });

    testWidgets('the tap target is 44 high around the 28 px row', (
      tester,
    ) async {
      await pumpLocalizedWidget(tester, _row());

      final row = tester.getRect(find.byType(InkWell));
      final icon = tester.getRect(svgAsset(ImagePath.language));
      expect(row.height, AppSizes.minTapTarget);
      expect(icon.top - row.top, ProfileMenuRow.overhang);
      expect(ProfileMenuRow.overhang, 8);
    });

    testWidgets('hides the value when none is given', (tester) async {
      await pumpLocalizedWidget(tester, _row());

      expect(find.text('English'), findsNothing);
    });

    testWidgets('reports taps', (tester) async {
      var taps = 0;
      await pumpLocalizedWidget(tester, _row(onTap: () => taps++));

      await tester.tap(find.byType(ProfileMenuRow));

      expect(taps, 1);
    });

    testWidgets('is one button announcing the label and the value', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpLocalizedWidget(tester, _row(value: 'English'));

      final node = tester.getSemantics(find.byType(InkWell));
      expect(node, isSemantics(isButton: true, hasTapAction: true));
      expect(node.label, contains('Language'));
      expect(node.label, contains('English'));
      semantics.dispose();
    });

    testWidgets('long labels ellipsize instead of overflowing', (tester) async {
      await pumpLocalizedWidget(
        tester,
        _row(value: 'العربية'),
        locale: const Locale('ar'),
        size: const Size(280, 400),
        textScale: 2,
      );

      expectNoLayoutErrors(tester);
    });
  });
}
