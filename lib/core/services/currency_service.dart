import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  final String _apiKey = 'ff17dddd36b865ea663fde6ee95cc469'; // Ensure this is correct
  final String _baseUrl = 'https://api.exchangerate-api.com/v4/latest';
  final String _historicalBaseUrl = 'https://api.frankfurter.app/'; // ✅ FIXED

  /// **Fetch latest exchange rates**
  Future<Map<String, dynamic>> fetchRates(String baseCurrency) async {
    final Uri url = Uri.parse('$_baseUrl/$baseCurrency');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('⚠️ Failed to load latest exchange rates: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('⚠️ Error fetching latest rates: $e');
    }
  }

  /// **Fetch historical exchange rates for the past 7 days**
  Future<List<double>> fetchHistoricalRates(String currency) async {
    List<double> historicalRates = [];
    final DateTime today = DateTime.now();

    for (int i = 1; i <= 7; i++) {
      final DateTime date = today.subtract(Duration(days: i));
      final String formattedDate =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      // ✅ FIX: Use EUR as base currency (since Frankfurter.app requires it)
      final Uri url = Uri.parse('$_historicalBaseUrl$formattedDate?from=EUR&to=$currency,USD');

      try {
        final response = await http.get(url);
        final String responseBody = response.body;
        final data = json.decode(responseBody);

        print('📢 Response for $formattedDate: $responseBody'); // ✅ Debugging log

        if (response.statusCode == 200 && data != null && data['rates'] != null) {
          final rates = data['rates'];
          if (rates['USD'] != null && rates[currency] != null) {
            // Convert USD → EUR → Target Currency
            double eurToUsd = rates['USD'];
            double eurToTarget = rates[currency];

            double usdToTarget = eurToTarget / eurToUsd;
            historicalRates.add(usdToTarget);

            print('✅ [$formattedDate] $currency Rate (via EUR): $usdToTarget');
          } else {
            print('⚠️ No rate data available for $currency on $formattedDate.');
          }
        } else {
          print('⚠️ Invalid API response: ${data?['error'] ?? "No data"}');
        }
      } catch (e) {
        print('⚠️ Exception occurred while fetching data for $formattedDate: $e');
      }
    }

    return historicalRates;
  }
}
