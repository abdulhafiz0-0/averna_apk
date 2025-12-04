import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme.dart';
import '../models/payment.dart';
import '../providers/providers.dart';
import '../widgets/app_drawer.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  int? _studentFilter;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final studentsAsync = ref.watch(studentsProvider);
    final selectedStudentId = _studentFilter;
    final paymentsAsync = ref.watch(paymentsProvider(selectedStudentId));
    final currencyFormatter = NumberFormat.simpleCurrency();

    return userAsync.when(
      data: (user) {
        if (studentsAsync.isLoading || paymentsAsync.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (studentsAsync.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Payments')),
            body: Center(
              child: Text('Failed to load students: ${studentsAsync.error}'),
            ),
          );
        }

        if (paymentsAsync.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Payments')),
            body: Center(
              child: Text('Failed to load payments: ${paymentsAsync.error}'),
            ),
          );
        }

        final students = studentsAsync.value ?? [];
        final payments = paymentsAsync.value ?? <Payment>[];
        final dateFormatter = DateFormat.yMMMMd();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Payments'),
          ),
          drawer: user != null ? AppDrawer(user: user) : null,
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(paymentsProvider(selectedStudentId));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DropdownButtonFormField<int?>(
                      value: _studentFilter,
                      decoration: const InputDecoration(
                        labelText: 'Filter by student',
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('All students'),
                        ),
                        ...students.map(
                          (student) => DropdownMenuItem<int?>(
                            value: student.id,
                            child: Text(student.fullName),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _studentFilter = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (payments.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          selectedStudentId == null
                              ? 'No payments recorded yet.'
                              : 'No payments recorded for the selected student.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  )
                else
                  ...payments.map(
                    (payment) {
                      String? studentName;
                      for (final student in students) {
                        if (student.id == payment.studentId) {
                          studentName = student.fullName;
                          break;
                        }
                      }
                      final parsedDate = DateTime.tryParse(payment.date);
                      final dateLabel = parsedDate == null
                          ? payment.date
                          : dateFormatter.format(parsedDate);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.successGreen.withOpacity(0.2),
                            child: const Icon(
                              Icons.attach_money,
                              color: AppTheme.successGreen,
                            ),
                          ),
                          title: Text(currencyFormatter.format(payment.amount)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(dateLabel),
                              if (studentName != null)
                                Text('Student: $studentName'),
                              if (payment.description != null && payment.description!.isNotEmpty)
                                Text('Note: ${payment.description}'),
                            ],
                          ),
                          trailing: payment.paymentMethod == null
                              ? null
                              : Chip(
                                  label: Text(payment.paymentMethod!),
                                ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment creation is not implemented yet.'),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add payment'),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Text('Failed to load user: $error'),
        ),
      ),
    );
  }
}
