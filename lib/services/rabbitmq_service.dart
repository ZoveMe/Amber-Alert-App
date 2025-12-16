import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/alert.dart';

class RabbitMQService {
  // 🔁 CHANGE HOST BASED ON DEVICE
  // Android Emulator: 10.0.2.2
  // Physical phone:   YOUR_PC_IP (e.g. 192.168.1.50)
  static const String _host = '10.0.2.2';

  static const String _username = 'guest';
  static const String _password = 'guest';

  /// Publish to YOUR exchange
  static const String _exchange = 'alerts.topic';

  static Future<void> publishAlert(
      Alert alert,
      String routingKey,
      ) async {
    final url =
        'http://$_host:15672/api/exchanges/%2F/$_exchange/publish';

    final payload = {
      "properties": {},
      "routing_key": routingKey,
      "payload": jsonEncode(alert.toJson()),
      "payload_encoding": "string"
    };

    final response = await http
        .post(
      Uri.parse(url),
      headers: {
        "Authorization":
        "Basic ${base64Encode(utf8.encode('$_username:$_password'))}",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception(
        'RabbitMQ publish failed '
            '[${response.statusCode}]: ${response.body}',
      );
    }

    final result = jsonDecode(response.body);
    if (result['routed'] != true) {
      throw Exception('Message NOT routed to any queue');
    }
  }
}
