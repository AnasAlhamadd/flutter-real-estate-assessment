import 'package:url_launcher/url_launcher.dart';

abstract interface class PhoneDialer {
  /// Opens the phone app with [phoneNumber]. `false` when no app can.
  Future<bool> dial(String phoneNumber);
}

class UrlLauncherPhoneDialer implements PhoneDialer {
  const UrlLauncherPhoneDialer();

  @override
  Future<bool> dial(String phoneNumber) async {
    try {
      return await launchUrl(Uri(scheme: 'tel', path: phoneNumber));
    } on Object {
      return false;
    }
  }
}
