import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  // Sample payment data
  final List<Map<String, dynamic>> _payments = [
    {
      'studentName': 'John Doe',
      'course': 'Mathematics',
      'date': '2025-11-01',
      'amount': 120.0,
      'status': 'Paid',
    },
    {
      'studentName': 'Jane Smith',
      'course': 'Science',
      'date': '2025-11-03',
      'amount': 100.0,
      'status': 'Unpaid',
    },
    {
      'studentName': 'Ali Khan',
      'course': 'History',
      'date': '2025-11-05',
      'amount': 150.0,
      'status': 'Pending', // Could mean partially paid
    },
    {
      'studentName': 'Mary Johnson',
      'course': 'English',
      'date': '2025-11-06',
      'amount': 80.0,
      'status': 'Paid',
    },
    {
      'studentName': 'Ahmed Ali',
      'course': 'Physics',
      'date': '2025-11-07',
      'amount': 90.0,
      'status': 'Unpaid',
    },
  ];

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
                Color statusColor;
                IconData statusIcon;

                switch (payment['status']) {
                  case 'Paid':
                    statusColor = Colors.green;
                    statusIcon = Icons.check;
                    break;
                  case 'Pending':
                    statusColor = Colors.orange;
                    statusIcon = Icons.pending;
                    break;
                  case 'Unpaid':
                  default:
                    statusColor = Colors.red;
                    statusIcon = Icons.close;
                    break;
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor,
                      child: Icon(statusIcon, color: Colors.white),
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
                          style: TextStyle(color: statusColor, fontSize: 12),
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

