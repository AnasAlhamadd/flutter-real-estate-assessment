import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fails on any framework error raised while laying out, including
/// RenderFlex overflow.
void expectNoLayoutErrors(WidgetTester tester) {
  expect(tester.takeException(), isNull);
}

void expectDirectionFor(WidgetTester tester, Locale locale) {
  final context = tester.element(find.byType(Scaffold).last);
  expect(
    Directionality.of(context),
    locale == AppLocalization.arabic ? TextDirection.rtl : TextDirection.ltr,
  );
}

/// The widget is inside the area not covered by system UI and can receive taps.
void expectVisibleAndTappable(WidgetTester tester, Finder finder) {
  expect(finder, findsOneWidget);
  expect(finder.hitTestable(), findsOneWidget);

  final view = tester.view;
  final logicalSize = view.physicalSize / view.devicePixelRatio;
  final padding = view.padding;
  final safeArea = Rect.fromLTRB(
    padding.left / view.devicePixelRatio,
    padding.top / view.devicePixelRatio,
    logicalSize.width - padding.right / view.devicePixelRatio,
    logicalSize.height - padding.bottom / view.devicePixelRatio,
  );
  final rect = tester.getRect(finder);
  expect(
    safeArea.contains(rect.topLeft) &&
        safeArea.contains(rect.bottomRight.translate(-0.01, -0.01)),
    isTrue,
    reason: '$rect is outside the safe area $safeArea',
  );
}
