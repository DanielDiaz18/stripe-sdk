import 'package:flutter/foundation.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:dio/dio.dart';

class NetworkService {
  final Dio _client;

  NetworkService(this._client);

  /// Get a stripe ephemeral key
  Future<EphemeralKey> getEphemeralKey(String apiVersion) async {
    final result = await _client.get<Map<String, dynamic>>(
      '/ephemeralKey',
      queryParameters: {'apiVersion': apiVersion},
    );
    return EphemeralKey.fromJson(result.data);
  }

  Future<IntentResponse> createSetupIntent(
      {String paymentMethod, String returnUrl}) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/setupIntent',
      data: {
        'paymentMethod': paymentMethod,
        'returnUrl': returnUrl,
      }..removeWhere((key, value) => value == null),
    );
    return IntentResponse.fromJson(response.data);
  }

  Future<IntentResponse> createPaymentIntent({
    @required int amount,
    String paymentMethod,
    String returnUrl,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/paymentIntent',
      data: {
        'amount': amount,
        'paymentMethod': paymentMethod,
        'returnUrl': returnUrl
      }..removeWhere((key, value) => value == null),
    );
    return IntentResponse.fromJson(response.data);
  }
}
