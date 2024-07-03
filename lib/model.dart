class Crypto {
  String name;
  String symbol;
  double priceUsd;
  double changePercent24Hr;

  Crypto({
    required this.name,
    required this.symbol,
    required this.priceUsd,
    required this.changePercent24Hr,
  });

  factory Crypto.fromJson(Map<String, dynamic> json) {
    return Crypto(
      name: json['name'],
      symbol: json['symbol'],
      priceUsd: double.parse(json['price_usd']),
      changePercent24Hr: double.parse(json['percent_change_24h']),
    );
  }
}
