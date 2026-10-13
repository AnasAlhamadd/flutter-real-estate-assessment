import 'dart:async';

/// Pure-Dart cancellation handle, so the domain layer can cancel a request
/// without depending on Dio's `CancelToken`.
class CancellationSignal {
  final Completer<void> _completer = Completer<void>();

  bool get isCancelled => _completer.isCompleted;

  Future<void> get whenCancelled => _completer.future;

  void cancel() {
    if (!_completer.isCompleted) _completer.complete();
  }
}
