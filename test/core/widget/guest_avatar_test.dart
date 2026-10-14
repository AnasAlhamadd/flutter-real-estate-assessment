import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/widget/guest_avatar.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_widget.dart';
import '../../helpers/svg_finders.dart';

void main() {
  group('GuestAvatar', () {
    for (final (size, icon) in [(44.0, 24.0), (140.0, 140 * 24 / 44)]) {
      testWidgets('is a $size circle with a proportional profile icon', (
        tester,
      ) async {
        await pumpLocalizedWidget(
          tester,
          Center(child: GuestAvatar(size: size)),
        );

        final circle = find.byType(Container);
        expect(tester.getSize(circle), Size.square(size));
        final decoration =
            tester.widget<Container>(circle).decoration! as BoxDecoration;
        expect(decoration.shape, BoxShape.circle);
        expect(decoration.color, ColorsApp.greyscale400);
        expect(
          tester.getSize(svgAsset(ImagePath.profileLight)).width,
          closeTo(icon, 0.01),
        );
      });
    }

    testWidgets('is hidden from screen readers', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpLocalizedWidget(
        tester,
        const Center(child: GuestAvatar(size: 140)),
      );

      expect(
        find.descendant(
          of: find.byType(GuestAvatar),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
      expect(tester.getSemantics(find.byType(GuestAvatar)).label, isEmpty);
      semantics.dispose();
    });
  });
}
