import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk_example/ui/intent_complete_screen.dart';

import 'locator.dart';
import 'network/network_service.dart';
import 'setup_intent_with_sca.dart';
import 'ui/edit_customer_screen.dart';
import 'ui/payment_screen.dart';

const _stripePublishableKey =
    'pk_test_51IRiRdHgBDtOi3Nc2YoPyz24wC8MjigaI6LFAkD3Bf6pDDW8BJrhP0fXNbdvG5iyiVbQ3PE1uIzzWnqKEA4D2zrR00A6R26Nxh';
const _returnUrl = 'stripesdk://demo.stripesdk.ezet.io';
const _returnUrlWeb = 'http://demo.stripesdk.ezet.io';

String getScaReturnUrl() {
  return kIsWeb ? _returnUrlWeb : _returnUrl;
}

void main() async {
  initializeLocator();
  Stripe.init(_stripePublishableKey, returnUrlForSca: getScaReturnUrl());
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CustomerSession.init(
        (version) => locator.get<NetworkService>().getEphemeralKey(version));
    return MaterialApp(
        title: 'Stripe SDK Demo',
        // home: HomeScreen(),

        onUnknownRoute: (settings) {
          final uri = Uri.parse(settings.name);
          if (uri.queryParameters.containsKey('setup_intent') ||
              uri.queryParameters.containsKey('payment_intent')) {
            return MaterialPageRoute(
                builder: (context) => IntentCompleteScreen());
          }
          return MaterialPageRoute(builder: (context) => HomeScreen());
        },
        routes: {
          '/': (context) => HomeScreen(),
          '/3ds/complete': (context) => IntentCompleteScreen(),
          '/payments': (context) => PaymentScreen()
        },
        initialRoute: '/',
        theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity));
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stripe SDK Demo'),
      ),
      body: ListView(children: <Widget>[
        Card(
          child: ListTile(
            title: Text('Customer Details'),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => EditCustomerScreen())),
          ),
        ),
        Card(
          child: ListTile(title: Text('Payment Methods Screen'), onTap: () {}),
        ),
        Card(
          child: ListTile(
            title: Text('Add Payment Method with Setup Intent'),
            onTap: () {},
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Add Payment Method without Setup Intent'),
            onTap: () {},
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Add Stripe Test Card'),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SetupIntentWithScaScreen())),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Payments'),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => PaymentScreen())),
          ),
        ),
      ]),
    );
  }
}
