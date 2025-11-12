import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class ArchivedStudentsPage extends StatefulWidget {
  const ArchivedStudentsPage({super.key});

  @override
  State<ArchivedStudentsPage> createState() => _ArchivedStudentsPageState();
}

class _ArchivedStudentsPageState extends State<ArchivedStudentsPage> {
  // TODO: Replace with actual data from database
  final List<Map<String, dynamic>> _archivedStudents = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archived Students'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(isAdmin: true),
      body: _archivedStudents.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.archive_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No archived students',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Archived students will appear here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _archivedStudents.length,
              itemBuilder: (context, index) {
                final student = _archivedStudents[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Text(student['name'][0]),
                    ),
                    title: Text(student['name']),
                    subtitle: Text('Archived on: ${student['archivedDate']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.unarchive, color: Colors.green),
                          onPressed: () {
                            // TODO: Implement restore functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Restore ${student['name']} - To be implemented'),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // TODO: Implement permanent delete functionality
                            _showDeleteDialog(student['name']);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showDeleteDialog(String studentName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permanently Delete'),
          content: Text('Are you sure you want to permanently delete $studentName?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implement permanent delete
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Delete functionality - To be implemented')),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}