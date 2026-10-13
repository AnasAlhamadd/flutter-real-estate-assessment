import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/widget/appear_animation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    bool animate = true,
    Duration delay = Duration.zero,
  }) => tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: AppearAnimation(
        animate: animate,
        delay: delay,
        child: const SizedBox.square(dimension: 100),
      ),
    ),
  );

  double opacity(WidgetTester tester) =>
      tester.widget<FadeTransition>(find.byType(FadeTransition)).opacity.value;

  double scale(WidgetTester tester) =>
      tester.widget<ScaleTransition>(find.byType(ScaleTransition)).scale.value;

  Offset slide(WidgetTester tester) => tester
      .widget<SlideTransition>(find.byType(SlideTransition))
      .position
      .value;

  testWidgets('starts hidden, lower and smaller, then comes to rest', (
    tester,
  ) async {
    await pump(tester);

    expect(opacity(tester), 0);
    expect(slide(tester), const Offset(0, AppearAnimation.slideFraction));
    expect(scale(tester), AppearAnimation.startScale);

    await tester.pump(AppearAnimation.duration ~/ 2);
    expect(opacity(tester), allOf(greaterThan(0), lessThan(1)));

    await tester.pumpAndSettle();
    expect(opacity(tester), 1);
    expect(slide(tester), Offset.zero);
    expect(scale(tester), 1);
  });

  testWidgets('waits for the delay before moving', (tester) async {
    const delay = Duration(milliseconds: 140);
    await pump(tester, delay: delay);

    await tester.pump(delay - const Duration(milliseconds: 1));
    expect(opacity(tester), 0);

    await tester.pump(
      AppearAnimation.duration + const Duration(milliseconds: 1),
    );
    expect(opacity(tester), 1);
  });

  testWidgets('is at rest at once when animate is false', (tester) async {
    await pump(tester, animate: false);

    expect(opacity(tester), 1);
    expect(scale(tester), 1);
  });

  testWidgets('is at rest at once when the system disables animations', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: AppearAnimation(child: SizedBox.square(dimension: 100)),
        ),
      ),
    );

    expect(opacity(tester), 1);
  });
}
