import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // For formatting dates

class ExchangeRateDetailsScreen extends StatelessWidget {
  final String currency;
  final List<Map<String, dynamic>> historicalRates; // Stores {"date": "YYYY-MM-DD", "rate": 1.0857}

  const ExchangeRateDetailsScreen({
    super.key,
    required this.currency,
    required this.historicalRates,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$currency Exchange Rate Trends'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: historicalRates.isEmpty
            ? Center(
                child: Text(
                  'No historical data available',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last ${historicalRates.length} Days Trend',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index >= 0 && index < historicalRates.length) {
                                  String dateStr = historicalRates[index]['date'];
                                  DateTime date = DateTime.parse(dateStr);
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      DateFormat.MMMd().format(date), // Example: "Mar 7"
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                }
                                return Container();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget: (value, meta) =>
                                  Text(value.toStringAsFixed(4)), // Higher precision
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: historicalRates
                                .asMap()
                                .entries
                                .map((e) => FlSpot(
                                      e.key.toDouble(),
                                      e.value['rate'],
                                    ))
                                .toList(),
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
