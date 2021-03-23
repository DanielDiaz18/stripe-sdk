import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'stripe_error.dart';

const String kDefaultApiVersion = '2020-03-02';
const String liveApiBase = 'https://api.stripe.com';
const String liveLoggingBase = 'https://q.stripe.com';
const String loggingEndPoint = 'https://m.stripe.com/4';
String get liveApiPath => '$liveApiBase/v1';

const String charset = 'UTF-8';
const String customers = 'customers';
const String tokens = 'tokens';
const String sources = 'sources';

Dio createApiHandler({String key, String apiVersion, String stripeAccount}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: liveApiPath,
      headers: {
        'Accept-Charset': charset,
        'Accept': 'application/json',
        'User-Agent': 'StripeSDK/v2',
        'X-Stripe-Client-User-Agent': {
          'os.name': defaultTargetPlatform.toString(),
          'lang': 'Dart',
        },
        'Stripe-Account': stripeAccount,
        'Stripe-Version': apiVersion ?? kDefaultApiVersion,
      }..removeWhere((key, value) => value == null),
      contentType: 'application/x-www-form-urlencoded',
    ),
  );
  return dio
    ..interceptors.addAll(
      [
        StripeErrorInterceptor(),
        if (key != null) StripeApiInterceptor(key),
      ],
    );
}

class StripeApiInterceptor extends Interceptor {
  final String key;

  StripeApiInterceptor(this.key);

  @override
  Future onRequest(RequestOptions options) {
    if (key != null) {
      return super.onRequest(
        options..headers.addAll({'Authorization': 'Bearer $key'}),
      );
    }
    return super.onRequest(options);
  }
}

class StripeErrorInterceptor extends Interceptor {
  @override
  Future onError(DioError err) async {
    if (err.type == DioErrorType.RESPONSE) {
      return StripeApiException(
        StripeApiError.fromJson(
          err.response?.headers?.value('Request-Id'),
          err.response?.data['error'] as Map<String, dynamic>,
        ),
      );
    }
    return err;
  }
}
