import 'dart:io';
import 'dart:ui' as ui;

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

    expect({
      ...ImagePath.icons,
      ImagePath.splashLogo,
      ImagePath.google,
      ImagePath.detailsMap,
      ImagePath.mapPin,
    }, files);
  });

  test('assets/images holds the Auth collage and the mock Details photos', () {
    final files = Directory(
      'assets/images',
    ).listSync().whereType<File>().map((file) => file.path).toSet();

    expect(files, {
      ImagePath.authCollage,
      ImagePath.agentAvatar,
      ImagePath.mapPinPhoto,
    });
  });

  for (final (path, width, height) in [
    (ImagePath.agentAvatar, 120, 120),
    (ImagePath.mapPinPhoto, 66, 64),
  ]) {
    test('$path decodes at 2× its Figma size', () async {
      final data = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final image = (await codec.getNextFrame()).image;
      addTearDown(() {
        image.dispose();
        codec.dispose();
      });

      expect((image.width, image.height), (width, height));
    });
  }

  test('the Details map and pin keep their Figma sizes', () async {
    final map = await _parsedSize(
      await rootBundle.loadString(ImagePath.detailsMap),
    );
    final pin = await _parsedSize(
      await rootBundle.loadString(ImagePath.mapPin),
    );

    expect(map.width, closeTo(437.011, 0.001));
    expect(map.height, closeTo(926, 0.001));
    expect(pin.width, closeTo(53.1365, 0.001));
    expect(pin.height, closeTo(61.4796, 0.001));
  });

  test('the Auth collage decodes at 3× its Figma size', () async {
    final data = await rootBundle.load(ImagePath.authCollage);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final image = (await codec.getNextFrame()).image;
    addTearDown(() {
      image.dispose();
      codec.dispose();
    });

    expect(image.width, 399 * 3);
    expect(image.height, 552 * 3);
  });

  test('the Google logo keeps its Figma size', () async {
    final source = await rootBundle.loadString(ImagePath.google);

    expect(await _parsedSize(source), const Size(22, 22));
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
