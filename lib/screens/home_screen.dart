import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String amount = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CurrencyProvider>(context, listen: false).loadRates('USD');
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
    });
  }

  void _onDelete() {
    setState(() {
      if (amount.isNotEmpty) {
        amount = amount.substring(0, amount.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Currency Converter'),
        actions: [
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
            // Currency display with flag and currency
            Row(
              children: [
                const CircleAvatar(
                  backgroundImage: AssetImage(
                      'assets/flags/us.png'), // Add flag image in assets
                  radius: 20,
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'USD',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'United States Dollar',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      amount = '';
                    });
                  },
                )
              ],
            ),
            const SizedBox(height: 20),

            // Amount display
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                amount.isEmpty ? '0.00 \$' : '$amount \$',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
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

            // Convert button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Add conversion logic
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.yellow[700],
                ),
                child: const Text(
                  'Convert',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
