import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every exported icon is listed and every listed icon exists', () {
    final files = Directory(
      'assets/svg',
    ).listSync().whereType<File>().map((file) => file.path).toSet();

    expect(ImagePath.all.toSet(), files);
  });

  for (final path in ImagePath.all) {
    test('$path is a bundled 24×24 SVG that parses', () async {
      final source = await rootBundle.loadString(path);
      expect(source, contains('viewBox="0 0 24 24"'));
      expect(source, isNot(contains('<mask')));

      final info = await vg.loadPicture(SvgStringLoader(source), null);
      expect(info.size, const Size(24, 24));
      info.picture.dispose();
    });
  }
}
