import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

import 'ephemeral_key_manager.dart';
import 'stripe_api_handler.dart';

class CustomerSession extends ChangeNotifier {
  static const int keyRefreshBufferInSeconds = 30;

  static CustomerSession _instance;

  final Dio _apiHandler;

  final String apiVersion;
  final EphemeralKeyManager _keyManager;

  bool get isDisposed => _isDisposed;

  bool _isDisposed = false;

  /// Create a new CustomerSession instance. Use this if you prefer to manage your own instances.
  CustomerSession._(
    EphemeralKeyProvider provider, {
    this.apiVersion = kDefaultApiVersion,
    String stripeAccount,
  })  : _keyManager = EphemeralKeyManager(provider, keyRefreshBufferInSeconds),
        _apiHandler = createApiHandler(
          apiVersion: apiVersion,
          stripeAccount: stripeAccount,
        ) {
    _apiHandler.interceptors.add(
      _CustomerAuthInterceptor(_keyManager),
    );
  }

  /// Initiate the customer session singleton instance.
  /// If [prefetchKey] is true, fetch the ephemeral key immediately.
  factory CustomerSession.init(
    EphemeralKeyProvider provider, {
    String apiVersion = kDefaultApiVersion,
    String stripeAccount,
  }) {
    return _instance ??= CustomerSession._(
      provider,
      apiVersion: apiVersion,
      stripeAccount: stripeAccount,
    );
  }

  /// End the managed singleton customer session.
  /// Call this when the current user logs out.
  @Deprecated('Use CustomerSession.instance.endSession instead.')
  static void endCustomerSession() {
    _instance.endSession();
  }

  /// End the managed singleton customer session.
  /// Call this when the current user logs out.
  void endSession() {
    notifyListeners();
    dispose();
    _isDisposed = true;
    if (this == _instance) _instance = null;
  }

  /// Get the current customer session
  static CustomerSession get instance {
    if (_instance == null) {
      throw Exception(
          'Attempted to get instance of CustomerSession before initialization. '
          'Please initialize a new session using [CustomerSession.initCustomerSession() first.]');
    }
    assert(_instance._assertNotDisposed());
    return _instance;
  }

  /// Retrieves the details for the current customer.
  /// https://stripe.com/docs/api/customers/retrieve
  Future<Map<String, dynamic>> retrieveCurrentCustomer() async {
    assert(_assertNotDisposed());
    final res =
        await _apiHandler.get<Map<String, dynamic>>('/customers/:customerId');
    return res.data;
  }

  /// List a Customer's PaymentMethods.
  /// https://stripe.com/docs/api/payment_methods/list
  Future<List<PaymentMethod>> listPaymentMethods({
    String type = 'card',
    int limit,
    String endingBefore,
    String startingAfter,
  }) async {
    assert(_assertNotDisposed());
    final params = {
      'type': type,
      'limit': limit,
      'starting_after': startingAfter,
      'ending_before': endingBefore,
    }..removeWhere((_, value) => value == null);
    final res = await _apiHandler.get<Map<String, dynamic>>(
      '/payment_methods',
      queryParameters: params,
      options: Options(extra: {"addCustomerId": true}),
    );
    return (res.data['data'] as List)
        .map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Attach a PaymentMethod.
  /// https://stripe.com/docs/api/payment_methods/attach
  Future<PaymentMethod> attachPaymentMethod(String paymentMethodId) async {
    assert(_assertNotDisposed());
    final res = await _apiHandler.post<Map<String, dynamic>>(
      '/payment_methods/$paymentMethodId/attach',
      options: Options(extra: {"addCustomerId": true}),
    );
    return PaymentMethod.fromJson(res.data);
  }

  /// Detach a PaymentMethod.
  /// https://stripe.com/docs/api/payment_methods/detach
  Future<Map<String, dynamic>> detachPaymentMethod(
      String paymentMethodId) async {
    assert(_assertNotDisposed());
    final res = await _apiHandler
        .post<Map<String, dynamic>>('/payment_methods/$paymentMethodId/detach');
    return res.data;
  }

  /// Attaches a Source object to the Customer.
  /// The source must be in a chargeable or pending state.
  /// https://stripe.com/docs/api/sources/attach
  Future<Map<String, dynamic>> attachSource(String sourceId) async {
    assert(_assertNotDisposed());
    final params = {'source': sourceId};
    final res = await _apiHandler.post<Map<String, dynamic>>(
      '/customers/:customerId/sources',
      queryParameters: params,
    );
    return res.data;
  }

  /// Detaches a Source object from a Customer.
  /// The status of a source is changed to consumed when it is detached and it can no longer be used to create a charge.
  /// https://stripe.com/docs/api/sources/detach
  Future<Map<String, dynamic>> detachSource(String sourceId) async {
    assert(_assertNotDisposed());

    final res = await _apiHandler.delete<Map<String, dynamic>>(
      '/customers/:customerId/sources/$sourceId',
    );
    return res.data;
  }

  /// Updates the specified customer by setting the values of the parameters passed.
  /// https://stripe.com/docs/api/customers/update
  Future<Map<String, dynamic>> updateCustomer(Map<String, dynamic> data) async {
    assert(_assertNotDisposed());
    final res = await _apiHandler.post<Map<String, dynamic>>(
      '/customers/:customerId',
      data: data,
    );
    return res.data;
  }

  bool _assertNotDisposed() {
    if (isDisposed) {
      throw FlutterError('A $runtimeType was used after being disposed.\n'
          'Once you have called dispose() on a $runtimeType, it can no longer be used.');
    }
    return true;
  }
}

class _CustomerAuthInterceptor extends Interceptor {
  final EphemeralKeyManager _keyManager;

  _CustomerAuthInterceptor(this._keyManager);

  @override
  Future onRequest(RequestOptions options) async {
    final key = await _keyManager.retrieveEphemeralKey();
    options.path = options.path.replaceAll(":customerId", key.customerId);
    if (options.extra["addCustomerId"] == true) {
      if (options.method == "GET") {
        options.queryParameters = {
          ...?options.queryParameters,
          "customer": key.customerId
        };
      } else {
        options.data = {
          ...?options.data,
          "customer": key.customerId,
        };
      }
    }
    return options..headers.addAll({'Authorization': 'Bearer ${key.secret}'});
  }
}
