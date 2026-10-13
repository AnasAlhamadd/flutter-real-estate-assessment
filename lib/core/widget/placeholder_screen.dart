import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Stand-in for screens that are built in Phase 5.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    required this.titleKey,
    this.messageKey = 'common.coming_soon',
    this.child,
    super.key,
  });

  final String titleKey;
  final String messageKey;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr(titleKey))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: AppSizes.screenHorizontalPadding.w,
            vertical: AppSizes.screenHorizontalPadding.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(context.tr(messageKey), textAlign: TextAlign.start),
              if (child != null) ...[
                SizedBox(height: AppSizes.screenHorizontalPadding.h),
                child!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
