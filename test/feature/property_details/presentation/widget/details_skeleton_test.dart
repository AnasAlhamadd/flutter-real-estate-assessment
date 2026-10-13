import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_shimmer.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_skeleton.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_widget.dart';
import '../../../../helpers/translations.dart';

void main() {
  testWidgetsInLayouts('hero and text shapes, announced as loading', (
    tester,
    locale,
    size,
    textScale,
  ) async {
    await pumpLocalizedWidget(
      tester,
      const DetailsSkeleton(),
      locale: locale,
      size: size,
      textScale: textScale,
      settle: false,
    );

    expectNoLayoutErrors(tester);
    expect(find.byType(AppShimmer), findsOneWidget);
    expect(
      find.bySemanticsLabel(translate(locale, 'common.loading')),
      findsOneWidget,
    );
    if (size == AppSizes.designSize && locale == AppLocalization.english) {
      expect(
        tester.getSize(find.byType(SkeletonBox).first).height,
        AppSizes.detailsHeroHeight,
      );
    }
  });
}
