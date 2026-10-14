import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_real_estate_assessment/core/widget/guest_avatar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Figma avatar block (`1:3816`). No user is signed in (Q11), so the photo is
/// a [GuestAvatar] and "Adrian Hajdin" becomes "Guest". The edit badge is
/// hidden: there is no profile editing.
class ProfileUserInfo extends StatelessWidget {
  const ProfileUserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const GuestAvatar(size: AppSizes.profileAvatarSize),
          SizedBox(height: AppSizes.profileAvatarNameGap.h),
          CustomText(
            AppTextKeys.profileGuestName,
            style: AppTextStyles.profileName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
