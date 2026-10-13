import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/data/datasource/property_extras_mock_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/domain/entities/property_extras_entity.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_agent.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_widget.dart';

final AgentEntity _agent = PropertyExtrasMockDataSource.sample.agent;

Future<void> _pump(
  WidgetTester tester, {
  AgentEntity? agent,
  VoidCallback? onChat,
  VoidCallback? onCall,
  Locale locale = AppLocalization.english,
  Size size = const Size(430, 932),
  double textScale = 1,
}) => pumpLocalizedWidget(
  tester,
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: DetailsAgent(
      agent: agent ?? _agent,
      onChat: onChat ?? () {},
      onCall: onCall ?? () {},
    ),
  ),
  locale: locale,
  size: size,
  textScale: textScale,
);

Finder _icon(String path) => find.byWidgetPredicate(
  (widget) => widget is AppSvgIcon && widget.assetPath == path,
);

void main() {
  testWidgets('shows the title, mock photo, name and role', (tester) async {
    await _pump(tester);

    expect(find.text('Agent'), findsOneWidget);
    expect(find.text('Natasya Wilodra'), findsOneWidget);
    expect(find.text('Owner'), findsOneWidget);
    expect(
      tester.widget<Image>(find.byType(Image)).image,
      const AssetImage(ImagePath.agentAvatar),
    );
  });

  testWidgets('chat and call report their taps', (tester) async {
    var chats = 0;
    var calls = 0;
    await _pump(tester, onChat: () => chats++, onCall: () => calls++);

    final chat = find.bySemanticsLabel('Chat with Natasya Wilodra');
    final call = find.bySemanticsLabel('Call Natasya Wilodra');
    expectVisibleAndTappable(tester, chat);
    expectVisibleAndTappable(tester, call);
    await tester.tap(chat);
    await tester.tap(call);

    expect((chats, calls), (1, 1));
  });

  testWidgets('call icon sits on the content edge, 20 after chat', (
    tester,
  ) async {
    await _pump(tester);

    final chat = tester.getRect(_icon(ImagePath.chat));
    final call = tester.getRect(_icon(ImagePath.call));
    expect(call.right, closeTo(430 - 24, 0.5));
    expect(
      call.left - chat.right,
      closeTo(AppSizes.detailsAgentActionGap, 0.5),
    );
    expect(call.size, const Size.square(AppSizes.detailsAgentActionIconSize));
  });

  testWidgets('Arabic mirrors the row and translates the labels', (
    tester,
  ) async {
    await _pump(tester, locale: AppLocalization.arabic);

    expect(find.text('الوكيل'), findsOneWidget);
    expect(find.text('المالك'), findsOneWidget);
    expect(find.bySemanticsLabel('مراسلة Natasya Wilodra'), findsOneWidget);
    final call = tester.getRect(_icon(ImagePath.call));
    final photo = tester.getRect(find.byType(Image));
    expect(call.left, closeTo(24, 0.5));
    expect(photo.right, closeTo(430 - 24, 0.5));
  });

  testWidgetsInLayouts('a long name is ellipsized, actions stay tappable', (
    tester,
    locale,
    size,
    textScale,
  ) async {
    await _pump(
      tester,
      agent: const AgentEntity(
        name: 'An Agent With An Extremely Long Name That Never Ends',
        role: AgentRole.owner,
        phone: '+15550100',
      ),
      locale: locale,
      size: size,
      textScale: textScale,
    );

    expectNoLayoutErrors(tester);
    expectDirectionFor(tester, locale);
    for (final icon in [ImagePath.chat, ImagePath.call]) {
      final rect = tester.getRect(_icon(icon));
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(size.width));
    }
  });
}
