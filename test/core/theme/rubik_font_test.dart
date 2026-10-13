import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_test/flutter_test.dart';

const _fontAsset = 'assets/fonts/rubik/Rubik-VariableFont_wght.ttf';

double _width(String text, FontWeight weight) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 20,
        fontWeight: weight,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  final width = painter.width;
  painter.dispose();
  return width;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final loader = FontLoader(AppTextStyles.fontFamily)
      ..addFont(rootBundle.load(_fontAsset));
    await loader.load();
  });

  test('FontWeight drives the variable wght axis for Latin text', () {
    expect(
      _width('Merialla Villa', FontWeight.w700),
      greaterThan(_width('Merialla Villa', FontWeight.w400)),
    );
  });

  test('FontWeight drives the variable wght axis for Arabic text', () {
    expect(
      _width('الرئيسية استكشاف', FontWeight.w700),
      greaterThan(_width('الرئيسية استكشاف', FontWeight.w400)),
    );
  });

  test('Arabic letters are shaped (joined forms are narrower)', () {
    const joined = 'استكشاف';
    final isolated = joined.split('').join('\u200C');

    expect(
      _width(joined, FontWeight.w400),
      lessThan(_width(isolated, FontWeight.w400)),
    );
  });
}
