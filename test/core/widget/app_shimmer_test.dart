import 'package:flutter/material.dart';
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
}
