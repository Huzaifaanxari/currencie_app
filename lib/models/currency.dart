class Currency {
  final String code;
  final double rate;

  Currency({
    required this.code,
    required this.rate,
  });

  factory Currency.fromJson(String code, dynamic rate) {
    return Currency(
      code: code,
      rate: rate.toDouble(),
    );
  }
}
