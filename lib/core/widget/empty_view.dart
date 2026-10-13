import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Empty state. Figma has no empty frame, so it is built from tokens.
class EmptyView extends StatelessWidget {
  const EmptyView({this.messageKey = 'common.empty', super.key});

  final String messageKey;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.screenHorizontalPadding.w),
        child: Text(
          context.tr(messageKey),
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyRegular14,
        ),
      ),
    );
  }
}
