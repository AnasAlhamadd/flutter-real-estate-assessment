import 'package:device_preview/device_preview.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_real_estate_assessment/app.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/feature/splash/presentation/pages/splash_screen.dart';
import 'package:flutter_real_estate_assessment/injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Future.wait([di.init(), SplashScreen.precacheLogo()]);
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (_) => AppLocalization.wrap(const App()),
    ),
  );
}
