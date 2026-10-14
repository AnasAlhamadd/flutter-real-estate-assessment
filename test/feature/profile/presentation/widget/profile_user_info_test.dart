import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/widget/guest_avatar.dart';
import 'package:flutter_real_estate_assessment/feature/profile/presentation/widget/profile_user_info.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_widget.dart';
import '../../../../helpers/translations.dart';

void main() {
  group('ProfileUserInfo', () {
    testWidgetsInLayouts('shows the guest avatar and name, centered', (
      tester,
      locale,
      size,
      textScale,
    ) async {
      await pumpLocalizedWidget(
        tester,
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: ProfileUserInfo(),
        ),
        locale: locale,
        size: size,
        textScale: textScale,
      );

      expectNoLayoutErrors(tester);
      final name = find.text(translate(locale, 'profile.guest_name'));
      expect(name, findsOneWidget);
      expect(find.byType(GuestAvatar), findsOneWidget);
      expect(
        tester.getCenter(find.byType(GuestAvatar)).dx,
        closeTo(size.width / 2, 0.01),
      );
      expect(tester.getCenter(name).dx, closeTo(size.width / 2, 0.01));
    });

    testWidgets('keeps the Figma sizes at the design size', (tester) async {
      await pumpLocalizedWidget(
        tester,
        const Align(alignment: Alignment.topCenter, child: ProfileUserInfo()),
      );

      final avatar = tester.getRect(find.byType(GuestAvatar));
      final name = tester.getRect(find.text('Guest'));
      expect(avatar.size, const Size.square(AppSizes.profileAvatarSize));
      expect(name.top - avatar.bottom, AppSizes.profileAvatarNameGap);
      // 24 × 1.2 = 28.8, snapped to whole pixels like Figma's 29.
      expect(name.height, closeTo(29, 0.5));
    });
  });
}
