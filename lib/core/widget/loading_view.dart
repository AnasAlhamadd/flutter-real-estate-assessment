import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';

/// Loading state. Figma has no loading frame, so it uses the primary color.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: context.tr('common.loading'),
        child: const CircularProgressIndicator(color: ColorsApp.primary),
      ),
    );
  }
}
