import 'package:flutter/material.dart';
import '../core/services/currency_service.dart';
import '../models/currency_model.dart';

class CurrencyProvider with ChangeNotifier {
  final CurrencyService _service = CurrencyService();
  CurrencyModel? _currencyModel;
  bool isLoading = false;
  String _selectedCurrency = 'USD';
  Map<String, List<double>> _historicalRates = {};

  String get selectedCurrency => _selectedCurrency;
  CurrencyModel? get currencyData => _currencyModel;

  List<MapEntry<String, double>> get currencyList {
    if (_currencyModel == null) return [];
    return _currencyModel!.rates.entries.toList();
  }

  List<double> getHistoricalRates(String currency) {
    return _historicalRates[currency] ?? [];
  }

  Future<void> loadRates(String baseCurrency) async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await _service.fetchRates(baseCurrency);
      _currencyModel = CurrencyModel.fromJson(data);
      _selectedCurrency = baseCurrency;
    } catch (e) {
      print('Error loading rates: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadHistoricalRates(String currency) async {
    try {
      final rates = await _service.fetchHistoricalRates(currency);
      _historicalRates[currency] = rates;
      notifyListeners();
    } catch (e) {
      print('Error loading historical rates: $e');
    }
  }
}
