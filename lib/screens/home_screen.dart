import 'package:currencie_app/screens/conversion_history_screen.dart';
import 'package:currencie_app/screens/currency_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import 'settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String amount = '';
  String fromCurrency = 'USD'; // Default from currency
  String toCurrency = 'EUR'; // Default to currency
  double convertedAmount = 0.0; // Holds the converted amount

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CurrencyProvider>(context, listen: false)
          .loadRates(fromCurrency);
    });
  }

  void _onNumberTap(String value) {
    setState(() {
      if (value == '.' && amount.contains('.')) return;
      if (value == '0' && amount == '0') return;
      if (amount == '0' && value != '.') {
        amount = value;
      } else {
        amount += value;
      }
      _convertCurrency(); // Convert currency when amount changes
    });
  }

  void _onDelete() {
    setState(() {
      if (amount.isNotEmpty) {
        amount = amount.substring(0, amount.length - 1);
      }
      _convertCurrency(); // Recalculate conversion
    });
  }

  Future<void> _saveConversion() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save conversions.')),
      );
      return;
    }

    if (amount.isEmpty || convertedAmount == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount to save!')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("conversions")
          .add({
        "fromCurrency": fromCurrency,
        "toCurrency": toCurrency,
        "amount": double.parse(amount),
        "convertedAmount": convertedAmount,
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conversion saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving conversion: $e')),
      );
    }
  }

  void _convertCurrency() {
    final currencyProvider =
        Provider.of<CurrencyProvider>(context, listen: false);
    final double fromRate = currencyProvider.exchangeRates[fromCurrency] ?? 1.0;
    final double toRate = currencyProvider.exchangeRates[toCurrency] ?? 1.0;

    setState(() {
      double inputAmount = double.tryParse(amount) ?? 0.0;
      convertedAmount = (inputAmount / fromRate) * toRate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Currency Converter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ConversionHistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveConversion,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // FROM CURRENCY SELECTOR + INPUT AMOUNT
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final selectedCurrency = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CurrencyListScreen()),
                    );
                    if (selectedCurrency != null) {
                      setState(() {
                        fromCurrency = selectedCurrency;
                      });
                      _convertCurrency();
                    }
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(
                            'assets/flags/${fromCurrency.toLowerCase()}.png'),
                        radius: 20,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fromCurrency,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'From Currency',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  amount.isEmpty ? '0.00' : amount,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward, size: 24),
              ],
            ),

            const SizedBox(height: 20),

            // TO CURRENCY SELECTOR + CONVERTED AMOUNT
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final selectedCurrency = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CurrencyListScreen()),
                    );
                    if (selectedCurrency != null) {
                      setState(() {
                        toCurrency = selectedCurrency;
                      });
                      _convertCurrency();
                    }
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(
                            'assets/flags/${toCurrency.toLowerCase()}.png'),
                        radius: 20,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            toCurrency,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'To Currency',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  convertedAmount.toStringAsFixed(2),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Number pad
            Expanded(
              child: GridView.builder(
                itemCount: 12,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  final keys = [
                    '7',
                    '8',
                    '9',
                    '4',
                    '5',
                    '6',
                    '1',
                    '2',
                    '3',
                    '.',
                    '0',
                    '<'
                  ];
                  final value = keys[index];
                  return ElevatedButton(
                    onPressed: () {
                      if (value == '<') {
                        _onDelete();
                      } else {
                        _onNumberTap(value);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                      backgroundColor: theme.colorScheme.surfaceVariant,
                    ),
                    child: Text(
                      value,
                      style: const TextStyle(fontSize: 20),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Convert button (optional since conversion is automatic)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _convertCurrency,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.yellow[700],
                ),
                child: const Text(
                  'Convert',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
