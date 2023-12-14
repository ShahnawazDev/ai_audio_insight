// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:my_app/services/square_checkout_handler.dart';
import 'package:my_app/pages/square_subscription_handler.dart';
import 'package:uuid/uuid.dart';

import 'package:webview_flutter/webview_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final int planIndex;

  const PaymentScreen({super.key, required this.planIndex});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isLoading = true;
  var checkoutUrl = '';

  final String squareAccessToken =
      'SQUARE_ACCESS_TOKEN'; // Replace with your actual Square access token
  final String locationId = ''; // Replace with your actual Square access token
  final String subscriptionPlanId = '';

// Replace with your subscription plan ID
  late final SquareCheckoutHandler squareCheckoutHandler;
// final GlobalKey<WebViewState> webViewKey = GlobalKey<WebViewState>();

  void subscribePlan(int planIndex) {
    final SquareSubscriptionHandler subscriptionHandler =
        SquareSubscriptionHandler(
      squareAccessToken,
    );

    String idemponencyKey = const Uuid().v4();
    final requestBody = subscriptionHandler.createSubscriptionRequestBody(
      cardId: 'card1',
      customerId: 'customer1',
      idempotencyKey: idemponencyKey,
      locationId: locationId,
      orderTemplateId: 'order1',
      planVariationId: '1',
      startDate: 'datetime1',
    );

    final subscriptionId =
        subscriptionHandler.createSubscription(requestBody: requestBody);

    setState(() {});
  }

  @override
  void initState() {
    squareCheckoutHandler = SquareCheckoutHandler(squareAccessToken);
    createCheckout();

    super.initState();
  }

  Future<void> createCheckout() async {
    var planName = 'Basic';
    var priceMoneyAmount = 1;
    var subscriptionPlanId = '';
    if (widget.planIndex == 0) {
      planName = 'Basic';
      priceMoneyAmount = 1;
      subscriptionPlanId = '';
    } else if (widget.planIndex == 1) {
      planName = 'Silver';
      priceMoneyAmount = 5;
      subscriptionPlanId = '';
    } else if (widget.planIndex == 2) {
      planName = 'Gold';
      priceMoneyAmount = 10;
      subscriptionPlanId = '';
    }
    try {
      // var idemponencyKey = DateTime.now().toString();

      // var idemponencyKey = '5bc3967b-b8d4-4a90-9e69-7ac022ef03f1';
      String idemponencyKey = const Uuid().v4();
      final response = await squareCheckoutHandler.createCheckoutLink(
        idempotencyKey: idemponencyKey,
        name: planName,
        priceMoneyAmount:
            priceMoneyAmount * 100, // Replace with the subscription plan price
        currency: 'USD',
        locationId: locationId, // Replace with your location ID
        subscriptionPlanId: subscriptionPlanId,
      );

      checkoutUrl = response['payment_link']['url'];

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      // Handle the error
      print('Error creating checkout link: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Square Checkout')),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : WebView(
              // key: webViewKey,
              initialUrl: checkoutUrl,
              javascriptMode: JavascriptMode.unrestricted,
              // onPageFinished: (String url) {
              //   setState(() {
              //     isLoading = false;
              //   });
              // },
            ),
    );
  }
}
