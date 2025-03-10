import 'package:flutter/material.dart';
import '../core/services/currency_service.dart';
import '../models/currency_model.dart';

class CurrencyProvider with ChangeNotifier {
  final CurrencyService _service = CurrencyService();
  CurrencyModel? _currencyModel;
  bool isLoading = false;
  bool isLoadingHistorical = false; // Separate loading state for historical data
  String _selectedCurrency = 'USD';
  
  Map<String, double> _exchangeRates = {}; 
  Map<String, List<double>> _historicalRates = {}; 

  String get selectedCurrency => _selectedCurrency;
  CurrencyModel? get currencyData => _currencyModel;
  Map<String, double> get exchangeRates => _exchangeRates;
  
  List<MapEntry<String, double>> get currencyList {
    if (_currencyModel == null) return [];
    return _currencyModel!.rates.entries.toList();
  }

  List<double> getHistoricalRates(String currency) {
    return _historicalRates[currency] ?? [];
  }

  /// **Fetch Latest Exchange Rates**
  Future<void> loadRates(String baseCurrency) async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await _service.fetchRates(baseCurrency);
      _currencyModel = CurrencyModel.fromJson(data);
      _exchangeRates = Map<String, double>.from(data['rates']); 
      _selectedCurrency = baseCurrency;
    } catch (e) {
      print('Error loading rates: $e');
      _exchangeRates = {}; // Clear old data if an error occurs
    }

    isLoading = false;
    notifyListeners();
  }

  /// **Fetch Historical Exchange Rates**
  Future<void> loadHistoricalRates(String currency) async {
    isLoadingHistorical = true;
    notifyListeners();

    try {
      final rates = await _service.fetchHistoricalRates(currency);
      _historicalRates[currency] = rates;
    } catch (e) {
      print('Error loading historical rates: $e');
      _historicalRates[currency] = [];
    }

    isLoadingHistorical = false;
    notifyListeners();
  }
}
