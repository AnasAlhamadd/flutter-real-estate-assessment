import 'package:flutter/widgets.dart';
import 'package:flutter_real_estate_assessment/feature/home/presentation/pages/home_screen.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/featured_property_card.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/property_grid_card.dart';
import 'package:flutter_test/flutter_test.dart';

/// The vertical page scroll view of the routed [HomeScreen].
Finder get homePageScrollable => find
    .descendant(
      of: find.byType(HomeScreen),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    )
    .first;

Finder gridCardTitled(String title) => find.descendant(
  of: find.byType(PropertyGridCard),
  matching: find.text(title),
);

Finder featuredCardTitled(String title) => find.descendant(
  of: find.byType(FeaturedPropertyCard),
  matching: find.text(title),
);

Future<void> scrollHomeToEnd(WidgetTester tester) async {
  final position = tester.state<ScrollableState>(homePageScrollable).position;
  // Lazily built rows can extend the scroll range after each jump.
  for (var i = 0; i < 5; i++) {
    position.jumpTo(position.maxScrollExtent);
    await tester.pumpAndSettle();
  }
}

Future<void> scrollHomeTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200, scrollable: homePageScrollable);
  await tester.pumpAndSettle();
}
