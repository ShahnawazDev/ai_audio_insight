import 'dart:convert';
import 'package:http/http.dart' as http;

class SquareSubscriptionHandler {
  final String accessToken;

  SquareSubscriptionHandler(this.accessToken);

  Map<String, dynamic> createSubscriptionRequestBody({
    required String idempotencyKey,
    required String locationId,
    required String planVariationId,
    required String customerId,
    required String cardId,
    required String startDate,
    required String orderTemplateId,
  }) {
    return {
      'idempotency_key': idempotencyKey,
      'location_id': locationId,
      'plan_variation_id': planVariationId,
      'customer_id': customerId,
      'card_id': cardId,
      'start_date': startDate,
      'phases': [
        {
          'ordinal': 0,
          'order_template_id': orderTemplateId,
        },
      ],
      'timezone': 'America/Los_Angeles',
      'source': {
        'name': 'My Application',
      },
    };
  }

  Future<String> createSubscription({
    required Map<String, dynamic> requestBody,
  }) async {
    const String apiUrl = 'https://connect.squareup.com/v2/subscriptions';

    final Map<String, String> headers = {
      'Square-Version': '2023-10-18',
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    final response = await http.post(Uri.parse(apiUrl),
        headers: headers, body: jsonEncode(requestBody));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final subscriptionId = responseData['subscription']['id'];
      return subscriptionId;
    } else {
      throw Exception(
          'Failed to create subscription. Error code: ${response.statusCode}');
    }
  }

  Future<bool> isSubscriptionActive(String subscriptionId) async {
    final String apiUrl =
        'https://connect.squareup.com/v2/subscriptions/$subscriptionId';

    final Map<String, String> headers = {
      'Square-Version': '2023-10-18',
      'Authorization': 'Bearer $accessToken',
    };

    final response = await http.get(Uri.parse(apiUrl), headers: headers);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final subscriptionStatus = responseData['subscription']['status'];
      return subscriptionStatus == 'ACTIVE';
    } else {
      throw Exception(
          'Failed to fetch subscription status. Error code: ${response.statusCode}');
    }
  }
}
