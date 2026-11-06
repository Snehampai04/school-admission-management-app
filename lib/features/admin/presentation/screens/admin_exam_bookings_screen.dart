
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminExamBookingsScreen extends StatefulWidget {
  const AdminExamBookingsScreen({super.key});

  @override
  State<AdminExamBookingsScreen> createState() =>
      _AdminExamBookingsScreenState();
}

class _AdminExamBookingsScreenState
    extends State<AdminExamBookingsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedStatus = 'All';
  DateTime? _selectedDate;
  bool _ascending = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String formatDate(dynamic value) {
    if (value is! Timestamp) return 'Date unavailable';

    final date = value.toDate();
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> filterBookings(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> bookings,
  ) {
    final search = _searchController.text.trim().toLowerCase();

    final filtered = bookings.where((booking) {
      final data = booking.data();

      final name = (data['studentName'] ?? '').toString().toLowerCase();
      final bookingId = booking.id.toLowerCase();
      final status = (data['status'] ?? 'booked').toString().toLowerCase();

      final matchesSearch =
          name.contains(search) || bookingId.contains(search);

      final matchesStatus = _selectedStatus == 'All' ||
          status == _selectedStatus.toLowerCase();

      bool matchesDate = true;

      if (_selectedDate != null) {
        final examDate = data['examDate'];

        if (examDate is Timestamp) {
          final date = examDate.toDate();

          matchesDate = date.year == _selectedDate!.year &&
              date.month == _selectedDate!.month &&
              date.day == _selectedDate!.day;
        } else {
          matchesDate = false;
        }
      }

      return matchesSearch && matchesStatus && matchesDate;
    }).toList();

    filtered.sort((a, b) {
      final dateA = a.data()['examDate'];
      final dateB = b.data()['examDate'];

      final aDate =
          dateA is Timestamp ? dateA.toDate() : DateTime(2100);
      final bDate =
          dateB is Timestamp ? dateB.toDate() : DateTime(2100);

      return _ascending
          ? aDate.compareTo(bDate)
          : bDate.compareTo(aDate);
    });

    return filtered;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Bookings'),
        actions: [
          IconButton(
            tooltip: 'Clear filters',
            icon: const Icon(Icons.filter_alt_off),
            onPressed: () {
              setState(() {
                _searchController.clear();
                _selectedStatus = 'All';
                _selectedDate = null;
                _ascending = true;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('exam_bookings')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allBookings = snapshot.data?.docs ?? [];
          final bookings = filterBookings(allBookings);

          final bookedCount = allBookings
              .where((b) => b.data()['status'] == 'booked')
              .length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_available,
                        size: 40,
                        color: Colors.teal,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Exam Bookings'),
                          Text(
                            '${allBookings.length}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$bookedCount confirmed bookings',
                            style: const TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Search
              const Text(
                'Search Bookings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search student name or booking ID',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 16),

              // Filters
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: ['All', 'Booked', 'Cancelled']
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value ?? 'All';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_month),
                      label: Text(
                        _selectedDate == null
                            ? 'Select Date'
                            : '${_selectedDate!.day}/'
                                '${_selectedDate!.month}/'
                                '${_selectedDate!.year}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Sort
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _ascending = !_ascending;
                    });
                  },
                  icon: Icon(
                    _ascending
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                  ),
                  label: Text(
                    _ascending ? 'Earliest First' : 'Latest First',
                  ),
                ),
              ),

              const Divider(height: 24),

              Text(
                'Showing ${bookings.length} of ${allBookings.length} bookings',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 12),

              if (allBookings.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text('No exam bookings yet.'),
                  ),
                )
              else if (bookings.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text('No bookings match your filters.'),
                  ),
                )
              else
                ...bookings.map((booking) {
                  final data = booking.data();

                  final studentName =
                      data['studentName'] ?? 'Unknown Student';
                  final examDate = formatDate(data['examDate']);
                  final startTime = data['startTime'] ?? '';
                  final endTime = data['endTime'] ?? '';
                  final venue = data['venue'] ?? 'Not specified';
                  final status = data['status'] ?? 'booked';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                child: Icon(Icons.school),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  studentName.toString(),
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Chip(
                                label: Text(status.toString().toUpperCase()),
                                backgroundColor: Colors.green.shade100,
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _detail(
                            Icons.calendar_today,
                            'Exam Date',
                            examDate,
                          ),
                          _detail(
                            Icons.access_time,
                            'Time',
                            '$startTime - $endTime',
                          ),
                          _detail(
                            Icons.location_on,
                            'Venue',
                            venue.toString(),
                          ),
                          _detail(
                            Icons.receipt_long,
                            'Application ID',
                            data['applicationId'] ?? '',
                          ),
                          _detail(
                            Icons.confirmation_number,
                            'Booking ID',
                            booking.id,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  Widget _detail(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 10),
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value.toString())),
        ],
      ),
    );
  }
}
