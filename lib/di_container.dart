import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:recyminer_miner/data/repository/auth_repo.dart';
import 'package:recyminer_miner/data/repository/language_repo.dart';
import 'package:recyminer_miner/data/repository/location_order_repo.dart';
import 'package:recyminer_miner/data/repository/order_repo.dart';
import 'package:recyminer_miner/data/repository/profile_repo.dart';
import 'package:recyminer_miner/data/repository/splash_repo.dart';
import 'package:recyminer_miner/data/repository/tracker_repo.dart';
import 'package:recyminer_miner/provider/auth_provider.dart';
import 'package:recyminer_miner/provider/language_provider.dart';
import 'package:recyminer_miner/provider/localization_provider.dart';
import 'package:recyminer_miner/provider/location_mining_provider.dart';
import 'package:recyminer_miner/provider/location_order_provider.dart';
import 'package:recyminer_miner/provider/order_provider.dart';
import 'package:recyminer_miner/provider/profile_provider.dart';
import 'package:recyminer_miner/provider/splash_provider.dart';
import 'package:recyminer_miner/provider/theme_provider.dart';
import 'package:recyminer_miner/provider/tracker_provider.dart';
import 'package:recyminer_miner/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/datasource/remote/dio/dio_client.dart';
import 'data/datasource/remote/dio/logging_interceptor.dart';
import 'data/repository/location_mining_repo.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton(() => DioClient(AppConstants.BASE_URL, sl(),
      loggingInterceptor: sl(), sharedPreferences: sl()));

  // Repository
  sl.registerLazySingleton(
      () => SplashRepo(sharedPreferences: sl(), dioClient: sl()));
  sl.registerLazySingleton(() => LanguageRepo());
  sl.registerLazySingleton(
      () => AuthRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => ProfileRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => OrderRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => LocationOrderRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => LocationMiningRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => TrackerRepo(dioClient: sl(), sharedPreferences: sl()));

  // Provider
  sl.registerFactory(() => ThemeProvider(sharedPreferences: sl()));
  sl.registerFactory(() => SplashProvider(splashRepo: sl()));
  sl.registerFactory(() => LocalizationProvider(sharedPreferences: sl()));
  sl.registerFactory(() => LanguageProvider(languageRepo: sl()));
  sl.registerFactory(() => AuthProvider(authRepo: sl()));
  sl.registerFactory(() => ProfileProvider(profileRepo: sl()));
  sl.registerFactory(() => OrderProvider(orderRepo: sl()));
  sl.registerFactory(() => TrackerProvider(trackerRepo: sl()));
  sl.registerFactory(() => LocationOrderProvider(locationOrderRepo: sl()));
  sl.registerFactory(() => LocationMiningProvider(locationMiningRepo: sl()));

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => LoggingInterceptor());
}
