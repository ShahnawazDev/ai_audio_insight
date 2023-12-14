import 'dart:convert';
import 'package:http/http.dart' as http;

class SquareCheckoutHandler {
  final String accessToken;

  SquareCheckoutHandler(this.accessToken);

  Future<Map<String, dynamic>> createCheckoutLink({
    required String idempotencyKey,
    required String name,
    required int priceMoneyAmount,
    required String currency,
    required String locationId,
    required String subscriptionPlanId,
  }) async {
    const String apiUrl =
        'https://connect.squareupsandbox.com/v2/online-checkout/payment-links';

    final Map<String, String> headers = {
      'Square-Version': '2023-10-18',
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> requestBody = {
      'idempotency_key': idempotencyKey,
      'quick_pay': {
        'name': name,
        'price_money': {
          'amount': priceMoneyAmount,
          'currency': currency,
        },
        'location_id': locationId,
      },
      'checkout_options': {
        'subscription_plan_id': subscriptionPlanId,
      },
    };

    final response = await http.post(Uri.parse(apiUrl),
        headers: headers, body: jsonEncode(requestBody));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData;
    } else {
      throw Exception(
          'Failed to create checkout link. Error code: ${response.statusCode}');
    }
  }
}
