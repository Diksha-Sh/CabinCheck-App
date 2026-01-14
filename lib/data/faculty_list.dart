import '../models/faculty.dart';

final List<Faculty> facultyList = [
  Faculty(
    id: '1',
    name: 'Dr. Anjali Sharma',
    department: 'CSE',
    cabin: 'Block B - 2nd Floor - Cabin 214',
    status: 'Expected in Cabin',
    lastUpdated: DateTime.now(),
  ),
  Faculty(
    id: '2',
    name: 'Dr. Rajiv Mehta',
    department: 'ECE',
    cabin: 'Block C - 1st Floor - Cabin 112',
    status: 'Busy',
    lastUpdated: DateTime.now(),
  ),
  Faculty(
    id: '3',
    name: 'Prof. Sneha Kapoor',
    department: 'ME',
    cabin: 'Block A - Ground Floor - Cabin 05',
    status: 'Available',
    lastUpdated: DateTime.now(),
  ),
  Faculty(
    id: '4',
    name: 'Dr. Vikram Singh',
    department: 'CSE',
    cabin: 'Block B - 3rd Floor - Cabin 310',
    status: 'In a Meeting',
    lastUpdated: DateTime.now(),
  ),  Faculty(
    id: '5',
    name: 'Prof. Meera Nair',
    department: 'ECE',
    cabin: 'Block C - 2nd Floor - Cabin 210',
    status: 'Available',
    lastUpdated: DateTime.now(),
  ),
];
