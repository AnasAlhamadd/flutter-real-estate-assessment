import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/widget/empty_view.dart';
import 'package:flutter_real_estate_assessment/core/widget/error_view.dart';
import 'package:flutter_real_estate_assessment/core/widget/loading_view.dart';

enum _SectionStatus { loading, failure, empty }

/// Loading, error, or empty state for one section of a scrolling screen.
///
/// Reserves at least [minHeight] (normally the height of the content it
/// replaces) so the page doesn't jump, and grows when large text needs more.
class SectionStatusView extends StatelessWidget {
  const SectionStatusView.loading({required this.minHeight, super.key})
    : _status = _SectionStatus.loading,
      failure = null,
      onRetry = null;

  const SectionStatusView.failure({
    required Failure this.failure,
    required VoidCallback this.onRetry,
    required this.minHeight,
    super.key,
  }) : _status = _SectionStatus.failure;

  const SectionStatusView.empty({required this.minHeight, super.key})
    : _status = _SectionStatus.empty,
      failure = null,
      onRetry = null;

  final _SectionStatus _status;
  final Failure? failure;
  final VoidCallback? onRetry;

  /// Logical pixels, already scaled by the caller.
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: switch (_status) {
        _SectionStatus.loading => const LoadingView(),
        _SectionStatus.failure => ErrorView(
          failure: failure!,
          onRetry: onRetry!,
        ),
        _SectionStatus.empty => const EmptyView(),
      },
    );
  }
}
