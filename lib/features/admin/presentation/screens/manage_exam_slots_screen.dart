
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/firestore_constants.dart';

class ManageExamSlotsScreen extends StatefulWidget {
  const ManageExamSlotsScreen({super.key});

  @override
  State<ManageExamSlotsScreen> createState() =>
      _ManageExamSlotsScreenState();
}

class _ManageExamSlotsScreenState extends State<ManageExamSlotsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _venueController = TextEditingController();
  final _capacityController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isSaving = false;

  final CollectionReference<Map<String, dynamic>> _slotsCollection =
      FirebaseFirestore.instance.collection(
    FirestoreConstants.examSlotsCollection,
  );

  @override
  void dispose() {
    _venueController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (_startTime ?? const TimeOfDay(hour: 9, minute: 0))
          : (_endTime ?? const TimeOfDay(hour: 10, minute: 0)),
    );

    if (time != null) {
      setState(() {
        if (isStart) {
          _startTime = time;
        } else {
          _endTime = time;
        }
      });
    }
  }

  int _minutes(TimeOfDay time) => time.hour * 60 + time.minute;

  Future<void> _createSlot() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null ||
        _startTime == null ||
        _endTime == null) {
      _showMessage('Please select the date, start time and end time.');
      return;
    }

    if (_minutes(_endTime!) <= _minutes(_startTime!)) {
      _showMessage('End time must be later than start time.');
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      _showMessage('Please log in again.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final date = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
      );

      await _slotsCollection.add({
        FirestoreConstants.date: Timestamp.fromDate(date),
        FirestoreConstants.startTime: _startTime!.format(context),
        FirestoreConstants.endTime: _endTime!.format(context),
        FirestoreConstants.venue: _venueController.text.trim(),
        FirestoreConstants.totalCapacity:
            int.parse(_capacityController.text.trim()),
        FirestoreConstants.bookedCount: 0,
        FirestoreConstants.createdBy: currentUser.uid,
        FirestoreConstants.createdAt: FieldValue.serverTimestamp(),
        FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
        'status': 'active',
      });

      if (!mounted) return;

      _venueController.clear();
      _capacityController.clear();

      setState(() {
        _selectedDate = null;
        _startTime = null;
        _endTime = null;
      });

      _showMessage('Exam slot created successfully!');
    } catch (e) {
      _showMessage('Failed to create slot: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatDate(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate();
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    }
    return 'Date unavailable';
  }

  Widget _buildSlotCard(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    final capacity = (data[FirestoreConstants.totalCapacity] as num?)
            ?.toInt() ??
        0;
    final booked = (data[FirestoreConstants.bookedCount] as num?)
            ?.toInt() ??
        0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDate(data[FirestoreConstants.date]),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Time: ${data[FirestoreConstants.startTime] ?? '--'}'
              ' - ${data[FirestoreConstants.endTime] ?? '--'}',
            ),
            Text('Venue: ${data[FirestoreConstants.venue] ?? '--'}'),
            Text('Capacity: $booked / $capacity booked'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: capacity > 0
                  ? (booked / capacity).clamp(0.0, 1.0)
                  : 0,
            ),
            const SizedBox(height: 8),
            Text(
              capacity - booked > 0
                  ? '${capacity - booked} seats available'
                  : 'Fully booked',
              style: TextStyle(
                color: capacity - booked > 0
                    ? Colors.green
                    : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Exam Slots'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create New Exam Slot',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(
                      _selectedDate == null
                          ? 'Select Exam Date'
                          : '${_selectedDate!.day}/'
                              '${_selectedDate!.month}/'
                              '${_selectedDate!.year}',
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              _pickTime(isStart: true),
                          child: Text(
                            _startTime == null
                                ? 'Start Time'
                                : _startTime!.format(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              _pickTime(isStart: false),
                          child: Text(
                            _endTime == null
                                ? 'End Time'
                                : _endTime!.format(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _venueController,
                    decoration: const InputDecoration(
                      labelText: 'Exam Venue',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the venue';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _capacityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Total Capacity',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people),
                    ),
                    validator: (value) {
                      final capacity = int.tryParse(value ?? '');

                      if (capacity == null || capacity <= 0) {
                        return 'Enter a valid capacity';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _createSlot,
                      icon: const Icon(Icons.add),
                      label: Text(
                        _isSaving ? 'Creating...' : 'Create Exam Slot',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 12),

            const Text(
              'Existing Exam Slots',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _slotsCollection
                  .orderBy(FirestoreConstants.date)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error loading slots: ${snapshot.error}');
                }

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final documents = snapshot.data?.docs ?? [];

                if (documents.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('No exam slots created yet.'),
                    ),
                  );
                }

                return Column(
                  children: documents
                      .map(_buildSlotCard)
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
