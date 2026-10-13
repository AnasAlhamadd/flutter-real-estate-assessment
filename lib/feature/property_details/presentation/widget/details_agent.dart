import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/domain/entities/property_extras_entity.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Agent (Figma `1:4308`): photo, name, role, chat and call.
class DetailsAgent extends StatelessWidget {
  const DetailsAgent({
    required this.agent,
    required this.onChat,
    required this.onCall,
    super.key,
  });

  final AgentEntity agent;
  final VoidCallback onChat;
  final VoidCallback onCall;

  static const double _tapTarget = AppSizes.minTapTarget;

  @override
  Widget build(BuildContext context) {
    final iconSize = AppSizes.detailsAgentActionIconSize.r;
    final targetInset = (_tapTarget - iconSize) / 2;
    final nameArgs = {'name': agent.name};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomText(AppTextKeys.detailsAgent, style: AppTextStyles.sectionTitle),
        SizedBox(height: AppSizes.detailsAgentTitleGap.h),
        Row(
          children: [
            const _AgentPhoto(),
            SizedBox(width: AppSizes.detailsAgentAvatarGap.w),
            Expanded(child: _AgentName(agent: agent)),
            // Figma gaps are between icons, so the tap targets eat into
            // them; the actions shift so the call icon ends on the content
            // edge like Figma.
            SizedBox(
              width: math.max(
                0,
                AppSizes.detailsAgentActionsGap.w - 2 * targetInset,
              ),
            ),
            Transform.translate(
              offset: Offset(
                Directionality.of(context) == TextDirection.ltr
                    ? targetInset
                    : -targetInset,
                0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AgentAction(
                    icon: ImagePath.chat,
                    label: context.tr(
                      AppTextKeys.detailsChatAgent,
                      namedArgs: nameArgs,
                    ),
                    onTap: onChat,
                  ),
                  SizedBox(
                    width: math.max(
                      0,
                      AppSizes.detailsAgentActionGap.w - 2 * targetInset,
                    ),
                  ),
                  _AgentAction(
                    icon: ImagePath.call,
                    label: context.tr(
                      AppTextKeys.detailsCallAgent,
                      namedArgs: nameArgs,
                    ),
                    onTap: onCall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// this mock: the Figma sample photo; the API has no agent photo.
class _AgentPhoto extends StatelessWidget {
  const _AgentPhoto();

  @override
  Widget build(BuildContext context) {
    final size = AppSizes.detailsAgentAvatarSize.r;
    return ExcludeSemantics(
      child: ClipOval(
        child: Image.asset(
          ImagePath.agentAvatar,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _AgentName extends StatelessWidget {
  const _AgentName({required this.agent});

  final AgentEntity agent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText.plain(
          agent.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.agentName,
        ),
        SizedBox(height: AppSizes.detailsAgentNameGap.h),
        CustomText(
          switch (agent.role) {
            AgentRole.owner => AppTextKeys.detailsAgentRoleOwner,
          },
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.agentRole,
        ),
      ],
    );
  }
}

/// A 28 px Primary icon in a 44 px tap target.
class _AgentAction extends StatelessWidget {
  const _AgentAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: SizedBox.square(
        dimension: DetailsAgent._tapTarget,
        child: InkResponse(
          onTap: onTap,
          radius: DetailsAgent._tapTarget / 2,
          child: Center(
            child: AppSvgIcon(
              icon,
              size: AppSizes.detailsAgentActionIconSize,
              color: ColorsApp.primary,
            ),
          ),
        ),
      ),
    );
  }
}
