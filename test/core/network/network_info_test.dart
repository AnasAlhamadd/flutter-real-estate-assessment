import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_real_estate_assessment/core/network/network_info.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeConnectivity implements Connectivity {
  _FakeConnectivity(this.current);

  List<ConnectivityResult> current;
  final StreamController<List<ConnectivityResult>> controller =
      StreamController();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => current;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      controller.stream;
}

void main() {
  test('is connected when any interface is up', () async {
    final info = NetworkInfoImpl(
      _FakeConnectivity([ConnectivityResult.none, ConnectivityResult.wifi]),
    );

    expect(await info.isConnected, isTrue);
  });

  test('is disconnected when only "none" is reported', () async {
    final info = NetworkInfoImpl(_FakeConnectivity([ConnectivityResult.none]));

    expect(await info.isConnected, isFalse);
  });

  test('is disconnected when no interface is reported', () async {
    final info = NetworkInfoImpl(_FakeConnectivity([]));

    expect(await info.isConnected, isFalse);
  });

  test('status stream emits only real changes', () async {
    final connectivity = _FakeConnectivity([ConnectivityResult.wifi]);
    final info = NetworkInfoImpl(connectivity);

    final emitted = expectLater(
      info.onStatusChange,
      emitsInOrder([true, false, true]),
    );
    connectivity.controller
      ..add([ConnectivityResult.wifi])
      ..add([ConnectivityResult.mobile])
      ..add([ConnectivityResult.none])
      ..add([ConnectivityResult.none])
      ..add([ConnectivityResult.ethernet]);
    await emitted;
    await connectivity.controller.close();
  });
}
