import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  final String _apiKey = 'YOUR_API_KEY'; // Replace with your API key if needed
  final String _baseUrl = 'https://api.exchangerate-api.com/v4/latest';
  final String _historicalBaseUrl = 'https://api.exchangerate.host/';

  /// **Fetch latest currency rates**
  Future<Map<String, dynamic>> fetchRates(String baseCurrency) async {
    final response = await http.get(Uri.parse('$_baseUrl/$baseCurrency'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load latest exchange rates');
    }
  }

  /// **Fetch historical rates for the past 7 days**
  Future<List<double>> fetchHistoricalRates(String currency) async {
    List<double> historicalRates = [];
    final DateTime today = DateTime.now();

    for (int i = 1; i <= 7; i++) {
      final DateTime date = today.subtract(Duration(days: i));
      final String formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final Uri url = Uri.parse('$_historicalBaseUrl$formattedDate?base=USD&symbols=$currency');

      try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final rate = data['rates']?[currency];
          if (rate != null) {
            historicalRates.add(rate.toDouble());
          }
        } else {
          print('⚠️ Failed to load historical rate for $formattedDate');
        }
      } catch (e) {
        print('⚠️ Error fetching historical rate: $e');
      }
    }

    return historicalRates;
  }
}
