import 'package:flutter/material.dart';
import '../core/services/currency_service.dart';
import '../models/currency_model.dart';

class CurrencyProvider with ChangeNotifier {
  final CurrencyService _service = CurrencyService();
  CurrencyModel? _currencyModel;
  bool isLoading = false;

  CurrencyModel? get currencyData => _currencyModel;

  Future<void> loadRates(String baseCurrency) async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await _service.fetchRates(baseCurrency);
      _currencyModel = CurrencyModel.fromJson(data);
    } catch (e) {
      print('Error loading rates: $e');
    }

    isLoading = false;
    notifyListeners();
  }
}
