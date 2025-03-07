import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import 'exchange_rate_details_screen.dart';

class CurrencyListScreen extends StatefulWidget {
  const CurrencyListScreen({super.key});

  @override
  State<CurrencyListScreen> createState() => _CurrencyListScreenState();
}

class _CurrencyListScreenState extends State<CurrencyListScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final theme = Theme.of(context);

    final filteredCurrencies = currencyProvider.currencyList.where((currency) {
      return currency.key.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Currency'),
      ),
      body: currencyProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search currency...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredCurrencies.length,
                    itemBuilder: (context, index) {
                      final currency = filteredCurrencies[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(
                            'assets/flags/${currency.key.toLowerCase()}.png',
                          ),
                          backgroundColor: theme.colorScheme.primaryContainer,
                        ),
                        title: Text('${currency.key}'),
                        subtitle:
                            Text('${currency.value.toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.show_chart),
                          onPressed: () {
                            final historicalRates =
                                currencyProvider.getHistoricalRates(
                                    currency.key);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ExchangeRateDetailsScreen(
                                  currency: currency.key,
                                  historicalRates: historicalRates,
                                ),
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          Navigator.pop(context, currency.key);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
