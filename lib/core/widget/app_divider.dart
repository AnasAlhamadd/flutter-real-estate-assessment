import 'package:flutter/widgets.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';

/// Figma "Theme=Light Divider" (`1:4307`): a 1 px Primary 10% line.
class AppDivider extends StatelessWidget {
  const AppDivider({super.key});

  static const double thickness = 1;

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: thickness,
      width: double.infinity,
      child: ColoredBox(color: ColorsApp.primary10),
    );
  }
}
