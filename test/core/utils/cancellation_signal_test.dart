import 'package:flutter_real_estate_assessment/core/utils/cancellation_signal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts active and completes whenCancelled once cancelled', () async {
    final signal = CancellationSignal();
    expect(signal.isCancelled, isFalse);

    signal
      ..cancel()
      ..cancel();

    expect(signal.isCancelled, isTrue);
    await expectLater(signal.whenCancelled, completes);
  });
}
