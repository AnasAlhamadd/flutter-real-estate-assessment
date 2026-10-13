import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Size> _parsedSize(String source) async {
  final info = await vg.loadPicture(SvgStringLoader(source), null);
  info.picture.dispose();
  return info.size;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every exported SVG is listed and every listed SVG exists', () {
    final files = Directory(
      'assets/svg',
    ).listSync().whereType<File>().map((file) => file.path).toSet();

    expect({...ImagePath.icons, ImagePath.splashLogo}, files);
  });

  for (final path in ImagePath.icons) {
    test('$path is a bundled 24×24 SVG that parses', () async {
      final source = await rootBundle.loadString(path);
      expect(source, contains('viewBox="0 0 24 24"'));
      expect(source, isNot(contains('<mask')));

      expect(await _parsedSize(source), const Size(24, 24));
    });
  }

  test('the splash logo keeps its Figma size and gradients', () async {
    final source = await rootBundle.loadString(ImagePath.splashLogo);
    expect(source, contains('linearGradient'));

    final size = await _parsedSize(source);
    expect(size.width, closeTo(133.885, 0.001));
    expect(size.height, closeTo(112.445, 0.001));
  });
}
