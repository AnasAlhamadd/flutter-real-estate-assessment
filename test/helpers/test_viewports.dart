import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

class TestViewport {
  const TestViewport(this.name, this.size, this.padding);

  final String name;
  final Size size;

  /// Simulated system UI (status bar, notch, home indicator) in logical px.
  final FakeViewPadding padding;

  @override
  String toString() => '$name ${size.width.toInt()}x${size.height.toInt()}';
}

const List<TestViewport> testViewports = [
  TestViewport('compact phone', Size(320, 568), FakeViewPadding(top: 20)),
  TestViewport(
    'standard phone',
    Size(375, 812),
    FakeViewPadding(top: 44, bottom: 34),
  ),
  TestViewport(
    'large phone',
    Size(430, 932),
    FakeViewPadding(top: 47, bottom: 34),
  ),
  TestViewport(
    'tablet portrait',
    Size(768, 1024),
    FakeViewPadding(top: 24, bottom: 20),
  ),
];
