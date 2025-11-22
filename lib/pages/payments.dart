import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  // TODO: Replace with actual data from your database
  final List<Map<String, dynamic>> _payments = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(isAdmin: true),
      body: _payments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment_outlined, size: 100, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No payments recorded',
                    style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Payments will appear here once added',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _payments.length,
              itemBuilder: (context, index) {
                final payment = _payments[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: payment['status'] == 'Paid' 
                          ? Colors.green 
                          : Colors.orange,
                      child: Icon(
                        payment['status'] == 'Paid' 
                            ? Icons.check 
                            : Icons.pending,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(payment['studentName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${payment['course']} - ${payment['date']}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${payment['amount'].toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          payment['status'],
                          style: TextStyle(
                            color: payment['status'] == 'Paid' 
                                ? Colors.green 
                                : Colors.orange,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to Add Payment page or open a dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add payment functionality - To be implemented')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
