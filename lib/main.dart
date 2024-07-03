import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: 20.0, fontStyle: FontStyle.italic),
          bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
      home: CryptoHomePage(),
    );
  }
}

class CryptoHomePage extends StatefulWidget {
  @override
  _CryptoHomePageState createState() => _CryptoHomePageState();
}

class _CryptoHomePageState extends State<CryptoHomePage> {
  late Future<List<Crypto>> futureCrypto;

  @override
  void initState() {
    super.initState();
    futureCrypto = fetchCrypto();
  }

  Future<List<Crypto>> fetchCrypto() async {
    final response =
        await http.get(Uri.parse('https://api.coinlore.net/api/tickers/'));

    if (response.statusCode == 200) {
      List<dynamic> json = jsonDecode(response.body)['data'];
      return json.map((data) => Crypto.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load crypto data');
    }
  }

  String getIconUrl(String symbol) {
    return 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/${symbol.toLowerCase()}.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Harga Crypto - Meri Antika'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                futureCrypto = fetchCrypto();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Crypto>>(
        future: futureCrypto,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load crypto data'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                Crypto crypto = snapshot.data![index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Image.network(
                        getIconUrl(crypto.symbol),
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error);
                        },
                      ),
                    ),
                    title: Text(
                      crypto.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(crypto.symbol.toUpperCase()),
                        Text(
                          'Market Cap: \$${crypto.marketCapUsd.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${crypto.priceUsd.toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${crypto.changePercent24Hr.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: crypto.changePercent24Hr >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CryptoDetailPage(crypto: crypto),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class CryptoDetailPage extends StatelessWidget {
  final Crypto crypto;

  CryptoDetailPage({required this.crypto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${crypto.name} Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              crypto.name,
              style: Theme.of(context).textTheme.headline1,
            ),
            Text(
              crypto.symbol.toUpperCase(),
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 20),
            Text('Price: \$${crypto.priceUsd.toStringAsFixed(2)}'),
            Text('24h Change: ${crypto.changePercent24Hr.toStringAsFixed(2)}%'),
            Text('Market Cap: \$${crypto.marketCapUsd.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}

class Crypto {
  final String id;
  final String symbol;
  final String name;
  final double priceUsd;
  final double changePercent24Hr;
  final double marketCapUsd;

  Crypto({
    required this.id,
    required this.symbol,
    required this.name,
    required this.priceUsd,
    required this.changePercent24Hr,
    required this.marketCapUsd,
  });

  factory Crypto.fromJson(Map<String, dynamic> json) {
    return Crypto(
      id: json['id'],
      symbol: json['symbol'],
      name: json['name'],
      priceUsd: double.parse(json['price_usd']),
      changePercent24Hr: double.parse(json['percent_change_24h']),
      marketCapUsd: double.parse(json['market_cap_usd']),
    );
  }
}
