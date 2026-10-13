import 'package:flutter/widgets.dart';

/// Calls [onLoadMore] when less than one screen of content is left below the
/// viewport of the scroll view in [child], including when the content is too
/// short to scroll. Nested horizontal lists are ignored.
///
/// [onLoadMore] runs on every qualifying scroll event, so it must ignore
/// calls while a page is loading or when there are no more pages.
class LoadMoreScrollListener extends StatelessWidget {
  const LoadMoreScrollListener({
    required this.onLoadMore,
    required this.child,
    super.key,
  });

  final VoidCallback onLoadMore;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (notification) =>
          _check(notification.depth, notification.metrics),
      child: NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification) =>
            _check(notification.depth, notification.metrics),
        child: child,
      ),
    );
  }

  /// Never consumes the notification, so a `RefreshIndicator` still works.
  bool _check(int depth, ScrollMetrics metrics) {
    if (depth == 0 &&
        metrics.axis == Axis.vertical &&
        metrics.extentAfter < metrics.viewportDimension) {
      onLoadMore();
    }
    return false;
  }
}
