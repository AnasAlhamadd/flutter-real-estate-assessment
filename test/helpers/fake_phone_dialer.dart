import 'package:flutter_real_estate_assessment/core/services/phone_dialer.dart';

/// Records every number instead of opening the dialer; [result] is what
/// [dial] reports.
class FakePhoneDialer implements PhoneDialer {
  FakePhoneDialer({this.result = true});

  bool result;
  final List<String> dialed = [];

  @override
  Future<bool> dial(String phoneNumber) async {
    dialed.add(phoneNumber);
    return result;
  }
}
