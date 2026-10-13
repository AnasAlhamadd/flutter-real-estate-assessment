import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_real_estate_assessment/core/network/dio_client.dart';
import 'package:flutter_real_estate_assessment/core/network/network_info.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  final preferences = await SharedPreferences.getInstance();

  // External
  sl
    ..registerLazySingleton<SharedPreferences>(() => preferences)
    ..registerLazySingleton<Connectivity>(Connectivity.new)
    ..registerLazySingleton<Dio>(DioClient.createDio)
    // Core
    ..registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()))
    ..registerLazySingleton<DioClient>(() => DioClient(sl()));
}
