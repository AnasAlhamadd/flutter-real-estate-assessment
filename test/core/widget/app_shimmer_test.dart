import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_shimmer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_widget.dart';

Widget _shimmer({bool reduceMotion = false}) => Builder(
  builder: (context) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
    child: const Center(
      child: AppShimmer(child: SkeletonBox(width: 120, height: 16, radius: 8)),
    ),
  ),
);

void main() {
  testWidgets('sweeps continuously over its skeletons', (tester) async {
    await pumpLocalizedWidget(tester, _shimmer(), settle: false);

    expect(find.byType(ShaderMask), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isTrue);
    expect(tester.getSize(find.byType(SkeletonBox)), const Size(120, 16));
  });

  testWidgets('stays still when the platform reduces motion', (tester) async {
    await pumpLocalizedWidget(tester, _shimmer(reduceMotion: true));

    expect(find.byType(ShaderMask), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('stops when reduced motion is turned on while visible', (
    tester,
  ) async {
    final reduceMotion = ValueNotifier(false);
    addTearDown(reduceMotion.dispose);
    await pumpLocalizedWidget(
      tester,
      ValueListenableBuilder(
        valueListenable: reduceMotion,
        builder: (_, reduce, _) => _shimmer(reduceMotion: reduce),
      ),
      settle: false,
    );

    reduceMotion.value = true;
    await tester.pump();
    await tester.pump();

    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  group('SkeletonTextLine', () {
    const style = TextStyle(fontSize: 20, height: 1);

    Future<Rect> pumpLine(
      WidgetTester tester, {
      Locale locale = AppLocalization.english,
      double textScale = 1,
    }) async {
      await pumpLocalizedWidget(
        tester,
        const Align(
          alignment: AlignmentDirectional.topStart,
          child: SizedBox(
            width: 300,
            child: SkeletonTextLine(
              style: style,
              widthFactor: 0.5,
              radius: 4,
              minHeight: 40,
            ),
          ),
        ),
        locale: locale,
        textScale: textScale,
        settle: false,
      );
      return tester.getRect(find.byType(SkeletonBox));
    }

    testWidgets('one text line tall, bottom-aligned in its slot', (
      tester,
    ) async {
      final bar = await pumpLine(tester);

      expect(bar.size, const Size(150, 20));
      expect(tester.getSize(find.byType(SkeletonTextLine)).height, 40);
      expect(bar.bottom, 40);
      expect(bar.left, 0);
    });

    testWidgets('grows with the text scale', (tester) async {
      final bar = await pumpLine(tester, textScale: 1.3);

      expect(bar.height, closeTo(26, 0.01));
    });

    testWidgets('starts at the right in Arabic', (tester) async {
      final bar = await pumpLine(tester, locale: AppLocalization.arabic);

      expect(bar.right, tester.getRect(find.byType(SkeletonTextLine)).right);
    });
  });
}
