import 'package:http/http.dart' as http;
import 'dart:convert';

class SubscriptionHandler {
  final String accessToken;

  SubscriptionHandler(this.accessToken);

  Future<http.Response> createSubscription(
      String idempotencyKey,
      String locationId,
      String planVariationId,
      String customerId,
      String cardId,
      String startDate,
      List<Map<String, dynamic>> phases,
      String timezone,
      Map<String, dynamic> source) {
    var url = Uri.parse('https://connect.squareup.com/v2/subscriptions');
    var headers = {
      'Square-Version': '2023-09-25',
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    var body = jsonEncode({
      "idempotency_key": idempotencyKey,
      "location_id": locationId,
      "plan_variation_id": planVariationId,
      "customer_id": customerId,
      "card_id": cardId,
      "start_date": startDate,
      "phases": phases,
      "timezone": timezone,
      "source": source
    });

    return http.post(url, headers: headers, body: body);
  }
}
