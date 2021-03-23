import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'network/network_service.dart';

final locator = GetIt.instance;

void initializeLocator() {
  locator.registerLazySingleton(() =>
      Dio(BaseOptions(baseUrl: 'http://192.168.0.36:8081/stripe'))
        ..interceptors.add(LogInterceptor()));
  locator.registerLazySingleton(() => NetworkService(locator.get()));
}
