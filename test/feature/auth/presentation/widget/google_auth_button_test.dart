import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_real_estate_assessment/feature/auth/presentation/widget/google_auth_button.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_widget.dart';
import '../../../../helpers/translations.dart';

void main() {
  testWidgetsInLayouts('shows the Google logo and the translated label', (
    tester,
    locale,
    size,
    textScale,
  ) async {
    await pumpLocalizedWidget(
      tester,
      GoogleAuthButton(onPressed: () {}),
      locale: locale,
      size: size,
      textScale: textScale,
    );

    expectNoLayoutErrors(tester);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is AppSvgIcon && widget.assetPath == ImagePath.google,
      ),
      findsOneWidget,
    );
    expect(find.text(translate(locale, 'auth.google_button')), findsOneWidget);
  });

  testWidgets('calls onPressed when tapped', (tester) async {
    var taps = 0;
    await pumpLocalizedWidget(
      tester,
      GoogleAuthButton(onPressed: () => taps++),
    );

    await tester.tap(find.byType(GoogleAuthButton));
    expect(taps, 1);
  });
}
