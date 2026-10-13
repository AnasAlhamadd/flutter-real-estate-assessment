import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/scroll_to_top_button.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_widget.dart';
import '../../helpers/translations.dart';

void main() {
  late ScrollController controller;

  setUp(() => controller = ScrollController());
  tearDown(() => controller.dispose());

  Future<void> pumpList(
    WidgetTester tester, {
    Locale locale = AppLocalization.english,
  }) => pumpLocalizedWidget(
    tester,
    Stack(
      children: [
        ListView.builder(
          controller: controller,
          itemCount: 100,
          itemExtent: 100,
          itemBuilder: (_, index) => Text('Row $index'),
        ),
        PositionedDirectional(
          end: 16,
          bottom: 16,
          child: ScrollToTopButton(controller: controller),
        ),
      ],
    ),
    locale: locale,
  );

  Finder label(Locale locale) =>
      find.bySemanticsLabel(translate(locale, AppTextKeys.commonBackToTop));

  bool isShown(WidgetTester tester) =>
      tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale == 1;

  testWidgets('is hidden and not focusable at the top', (tester) async {
    await pumpList(tester);

    expect(isShown(tester), isFalse);
    expect(label(AppLocalization.english), findsNothing);
  });

  testWidgets('stays hidden within the first screen', (tester) async {
    await pumpList(tester);

    controller.jumpTo(AppSizes.designSize.height - 1);
    await tester.pumpAndSettle();

    expect(isShown(tester), isFalse);
  });

  for (final locale in AppLocalization.supportedLocales) {
    testWidgets('appears past one screen and scrolls back to the top '
        '(${locale.languageCode})', (tester) async {
      await pumpList(tester, locale: locale);

      controller.jumpTo(AppSizes.designSize.height + 1);
      await tester.pumpAndSettle();
      expect(isShown(tester), isTrue);
      expect(label(locale), findsOneWidget);

      await tester.tap(find.byType(ScrollToTopButton));
      await tester.pumpAndSettle();

      expect(controller.offset, 0);
      expect(isShown(tester), isFalse);
    });
  }

  testWidgets('jumps without animating when animations are off', (
    tester,
  ) async {
    await pumpList(tester);
    controller.jumpTo(3000);
    await tester.pumpAndSettle();
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pump();

    await tester.tap(find.byType(ScrollToTopButton));
    await tester.pump();

    expect(controller.offset, 0);
  });
}
