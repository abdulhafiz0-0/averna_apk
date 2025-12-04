// lib/screens/payment_screens.dart
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
  String _selectedRole = 'Admin'; // default per mock
   // placeholder if you add course filtering

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final studentsAsync = ref.watch(studentsProvider);
    final selectedStudentId = _studentFilter;
    final paymentsAsync = ref.watch(paymentsProvider(selectedStudentId));
    final currencyFormatter = NumberFormat.simpleCurrency();
    final dateFormatter = DateFormat.yMMMd();

    return userAsync.when(
      data: (user) {
        // Loading states handled below
        if (studentsAsync.isLoading || paymentsAsync.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (studentsAsync.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Payments')),
            body: Center(child: Text('Failed to load students: ${studentsAsync.error}')),
          );
        }

        if (paymentsAsync.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Payments')),
            body: Center(child: Text('Failed to load payments: ${paymentsAsync.error}')),
          );
        }

        final students = studentsAsync.value ?? [];
        final payments = paymentsAsync.value ?? <Payment>[];

        // Helper: find student full name by id
String studentNameFor(dynamic id) {
  if (id == null) return 'Unknown';
  if (students.isEmpty) return 'Student';

  // firstWhere must return a Student, so return students.first when not found
  final s = students.firstWhere(
    (st) => st.id == id,
    orElse: () => students.first,
  );

  // If the model uses fullName or name, try both safely:
  try {
    final name = (s as dynamic).fullName ?? (s as dynamic).name;
    return name?.toString() ?? 'Student';
  } catch (_) {
    return 'Student';
  }
}


        // Determine payment status robustly (many models are different).
        String paymentStatus(dynamic p) {
          try {
            // prefer explicit status
            final status = (p as dynamic).status;
            if (status != null) return status.toString();
          } catch (_) {}
          try {
            // possible boolean flag
            final isPaid = (p as dynamic).isPaid;
            if (isPaid != null) return (isPaid == true) ? 'Paid' : 'Unpaid';
          } catch (_) {}
          // fallback: consider payments with a non-null paymentMethod as paid (best-effort)
          try {
            final pm = (p as dynamic).paymentMethod;
            if (pm != null && pm.toString().isNotEmpty) return 'Paid';
          } catch (_) {}
          return 'Unpaid';
        }

        // Split into upcoming (not-paid) and history (paid)
        final upcoming = <Payment>[];
        final history = <Payment>[];
        for (final p in payments) {
          final status = paymentStatus(p);
          if (status.toLowerCase() == 'paid') {
            history.add(p);
          } else {
            upcoming.add(p);
          }
        }

        // UI
        return Scaffold(
          appBar: AppBar(title: const Text('Payments')),
          drawer: user != null ? AppDrawer(user: user) : null,
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(paymentsProvider(selectedStudentId));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header card with role tabs
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + small subtitle
                        const Text('Payments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(
                          _selectedRole == 'Teacher'
                              ? 'Teacher • ${_selectedRole == 'Teacher' ? 'World History' : ''}'
                              : '${_selectedRole} • World History',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 12),

                        // Role tabs (Teacher / Student / Admin)
                        Row(
                          children: [
                            _roleChip('Teacher'),
                            const SizedBox(width: 8),
                            _roleChip('Student'),
                            const SizedBox(width: 8),
                            _roleChip('Admin'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Filters header
                const Text('Filters', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),

                // Filters area (two outlined boxes per mock)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          // open student selector
                          final sel = await showDialog<int?>(
                            context: context,
                            builder: (_) => _StudentSelectDialog(students: students, selected: _studentFilter),
                          );
                          if (sel != null) {
                            setState(() => _studentFilter = sel);
                            // reload payments for selected student
                            ref.invalidate(paymentsProvider(sel));
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          _studentFilter == null ? 'Student: All' : 'Student: ${studentNameFor(_studentFilter)}',
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Course filter placeholder
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Course filter not implemented')));
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: const Text('Course: World History', style: TextStyle(color: Colors.black87)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Upcoming payments section
                const Text('Upcoming Payments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),

                if (upcoming.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(child: Text(selectedStudentId == null ? 'No upcoming payments.' : 'No upcoming payments for selected student.')),
                    ),
                  )
                else
                  ...upcoming.map((payment) {
                    final studentName = studentNameFor(payment.studentId);
                    final parsedDate = DateTime.tryParse(payment.date);
                    final dateLabel = parsedDate == null ? payment.date : dateFormatter.format(parsedDate);
                    final amt = currencyFormatter.format(payment.amount);
                    final status = paymentStatus(payment);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Row(
                          children: [
                            // avatar placeholder
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                              child: const Icon(Icons.person, color: Colors.grey),
                            ),
                            const SizedBox(width: 12),

                            // left column: name + meta
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Text('Due: $dateLabel', style: TextStyle(color: Colors.grey[600])),

                                ],
                              ),
                            ),

                            // right column: amount + badge
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(amt, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('Unpaid', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                const SizedBox(height: 18),

                // Payment history section
                const Text('Payment History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),

                if (history.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(child: Text(selectedStudentId == null ? 'No payment history.' : 'No payment history for selected student.')),
                    ),
                  )
                else
                  ...history.map((payment) {
                    final studentName = studentNameFor(payment.studentId);
                    final parsedDate = DateTime.tryParse(payment.date);
                    final dateLabel = parsedDate == null ? payment.date : dateFormatter.format(parsedDate);
                    final amt = currencyFormatter.format(payment.amount);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                              child: const Icon(Icons.person, color: Colors.grey),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Text('Paid on: $dateLabel', style: TextStyle(color: Colors.grey[600]))
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(amt, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.successGreen,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('Paid', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                const SizedBox(height: 40),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment creation is not implemented yet.')),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add payment'),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text('Failed to load user: $error'))),
    );
  }

  Widget _roleChip(String role) {
    final selected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.blue : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.blue : Colors.grey.shade300),
        ),
        child: Text(role, style: TextStyle(color: selected ? Colors.white : Colors.black87)),
      ),
    );
  }
}

/// Simple dialog that returns selected student id or null.
class _StudentSelectDialog extends StatelessWidget {
  final List<dynamic> students;
  final int? selected;

  const _StudentSelectDialog({Key? key, required this.students, this.selected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select student'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: students.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final s = students[index];
            final id = (s as dynamic).id as int?;
            final name = (s as dynamic).fullName as String?;
            return ListTile(
              title: Text(name ?? 'Student'),
              selected: selected == id,
              onTap: () => Navigator.of(context).pop(id),
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
      ],
    );
  }
}
