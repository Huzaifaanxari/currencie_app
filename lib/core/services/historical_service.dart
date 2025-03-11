import 'dart:convert';
import 'package:http/http.dart' as http;

class HistoricalService {
  final String _baseUrl = 'https://api.exchangerate.host/';

  /// **Fetch historical exchange rates for the last 7 days**
  Future<List<double>> fetchHistoricalRates(String baseCurrency, String targetCurrency) async {
    List<double> historicalRates = [];
    final DateTime today = DateTime.now();

    for (int i = 1; i <= 7; i++) {
      final DateTime date = today.subtract(Duration(days: i));
      final String formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final Uri url = Uri.parse('$_baseUrl$formattedDate?base=$baseCurrency&symbols=$targetCurrency');

      try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print(data);
          final rate = data['rates']?[targetCurrency];
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
