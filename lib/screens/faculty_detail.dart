import 'package:flutter/material.dart';
import '../models/faculty.dart';

class FacultyDetail extends StatelessWidget {
  final Faculty faculty;

  const FacultyDetail({super.key, required this.faculty});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(faculty.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Department: ${faculty.department}"),
            const SizedBox(height: 8),
            Text("Cabin: ${faculty.cabin}"),
            const SizedBox(height: 16),
            Text("Status: ${faculty.status}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Last Updated: ${faculty.lastUpdated}"),
          ],
        ),
      ),
    );
  }
}
