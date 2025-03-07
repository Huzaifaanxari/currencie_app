class CurrencyModel {
  final String base;
  final Map<String, double> rates;

  CurrencyModel({required this.base, required this.rates});

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      base: json['base'],
      rates: Map<String, double>.from(
        json['rates'].map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
    );
  }
}
