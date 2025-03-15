import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ConversionHistoryScreen extends StatefulWidget {
  const ConversionHistoryScreen({super.key});

  @override
  State<ConversionHistoryScreen> createState() => _ConversionHistoryScreenState();
}

class _ConversionHistoryScreenState extends State<ConversionHistoryScreen> {
  List<Map<String, dynamic>> conversionHistory = [];

  Future<void> fetchConversionHistory() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("conversions")
          .orderBy("timestamp", descending: true)
          .get();

      setState(() {
        conversionHistory = snapshot.docs.map((doc) {
          return {
            "id": doc.id,
            "fromCurrency": doc["fromCurrency"],
            "toCurrency": doc["toCurrency"],
            "amount": doc["amount"],
            "convertedAmount": doc["convertedAmount"],
            "timestamp": (doc["timestamp"] as Timestamp).toDate(),
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching history: $e");
    }
  }

  void deleteConversion(String docId) async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("conversions")
          .doc(docId)
          .delete();

      setState(() {
        conversionHistory.removeWhere((entry) => entry["id"] == docId);
      });

      print("Conversion deleted successfully!");
    } catch (e) {
      print("Error deleting conversion: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchConversionHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Conversion History")),
      body: conversionHistory.isEmpty
          ? const Center(child: Text("No conversion history found."))
          : ListView.builder(
              itemCount: conversionHistory.length,
              itemBuilder: (context, index) {
                final entry = conversionHistory[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.history, color: Colors.blue),
                    title: Text(
                      "${entry["amount"]} ${entry["fromCurrency"]} → ${entry["convertedAmount"]} ${entry["toCurrency"]}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Date: ${DateFormat.yMMMd().add_jm().format(entry["timestamp"])}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        bool confirmDelete = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Delete Conversion"),
                            content: const Text("Are you sure you want to delete this conversion?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Delete", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirmDelete == true) {
                          deleteConversion(entry["id"]);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
