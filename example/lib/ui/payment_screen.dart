import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk_example/network/network_service.dart';

import '../locator.dart';

class PaymentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payments'),
      ),
      body: ListView(children: <Widget>[
        Card(
          child: ListTile(
            title: Text('Automatic confirmation (3DS2)'),
            onTap: () => createAutomaticPaymentIntent(context),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Manual confirmation (3DS2)'),
            onTap: () => createAutomaticPaymentIntent(context),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Checkout (WIP)'),
            onTap: () {},
          ),
        ),
      ]),
    );
  }

  void createAutomaticPaymentIntent(BuildContext context) async {
    final networkService = locator.get<NetworkService>();
    final response = await networkService.createPaymentIntent(amount: 10000);
    if (response.status == 'succeeded') {
      // TODO: success
      debugPrint('Success before authentication.');
      return;
    }
    final result = await Stripe.instance.confirmPayment(response.clientSecret,
        paymentMethodId: 'pm_card_threeDSecure2Required');
    if (result['status'] == 'succeeded') {
      // TODO: success
      debugPrint('Success after authentication.');
      return;
    } else {
      debugPrint('Error');
    }
  }

  void createManualPaymentIntent(BuildContext context) async {
    final networkService = locator.get<NetworkService>();
    final response = await networkService.createPaymentIntent(
      amount: 10000,
      paymentMethod: 'pm_card_threeDSecure2Required',
      returnUrl: Stripe.instance.getReturnUrlForSca(webReturnPath: '/'),
    );
    if (response.isSucceded) {
      // TODO: success
      debugPrint('Success before authentication.');
      return;
    }
    final result =
        await Stripe.instance.authenticatePayment(response.clientSecret);
    if (result['status'] == 'requires_confirmation') {
      // TODO: make call to server to confirm
      debugPrint('Success after authentication.');
      return;
    } else {
      debugPrint('Error');
    }
  }
}
