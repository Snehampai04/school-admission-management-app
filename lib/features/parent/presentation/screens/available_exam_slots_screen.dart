import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> bookExamSlot({
  required BuildContext context,
  required String parentId,
  required QueryDocumentSnapshot<Map<String, dynamic>> admission,
  required QueryDocumentSnapshot<Map<String, dynamic>> slot,
}) async {
  final db = FirebaseFirestore.instance;
  final bookingRef = db.collection('exam_bookings').doc(admission.id);
  final slotRef = db.collection('exam_slots').doc(slot.id);

  try {
    await db.runTransaction((transaction) async {
      final bookingSnapshot = await transaction.get(bookingRef);
      final slotSnapshot = await transaction.get(slotRef);

      if (bookingSnapshot.exists) {
        throw Exception('This student already has an exam booking.');
      }

      if (!slotSnapshot.exists) {
        throw Exception('This exam slot no longer exists.');
      }

      final slotData = slotSnapshot.data()!;
      final capacity = (slotData['totalCapacity'] as num?)?.toInt() ?? 0;
      final booked = (slotData['bookedCount'] as num?)?.toInt() ?? 0;

      if (slotData['status'] != 'active') {
        throw Exception('This exam slot is no longer active.');
      }

      if (booked >= capacity) {
        throw Exception('Sorry, this exam slot is fully booked.');
      }

      transaction.update(slotRef, {
        'bookedCount': booked + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(bookingRef, {
        'parentId': parentId,
        'applicationId': admission.id,
        'studentName': admission.data()['studentName'],
        'slotId': slot.id,
        'examDate': slotData['date'],
        'startTime': slotData['startTime'],
        'endTime': slotData['endTime'],
        'venue': slotData['venue'],
        'status': 'booked',
        'bookedAt': FieldValue.serverTimestamp(),
      });
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exam slot booked successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }
}

class AvailableExamSlotsScreen extends StatelessWidget {
  const AvailableExamSlotsScreen({super.key});

  String _formatDate(dynamic value) {
    if (value is! Timestamp) return 'Date unavailable';

    final date = value.toDate();
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in again.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Exam Slot Booking')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('admissions')
            .where('parentId', isEqualTo: user.uid)
            .where('status', isEqualTo: 'approved')
            .snapshots(),
        builder: (context, admissionSnapshot) {
          if (admissionSnapshot.hasError) {
            return const Center(
              child: Text('Unable to load approved applications.'),
            );
          }

          if (admissionSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final admissions = admissionSnapshot.data?.docs ?? [];

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('exam_bookings')
                .where('parentId', isEqualTo: user.uid)
                .snapshots(),
            builder: (context, bookingSnapshot) {
              if (bookingSnapshot.hasError) {
                return Center(
                  child: Text(
                    'Unable to load bookings: ${bookingSnapshot.error}',
                  ),
                );
              }

              if (bookingSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final bookings = bookingSnapshot.data?.docs ?? [];

              final bookedApplicationIds = bookings
                  .map(
                    (booking) =>
                        booking.data()['applicationId']?.toString() ?? '',
                  )
                  .toSet();

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('exam_slots')
                    .where('status', isEqualTo: 'active')
                    .orderBy('date')
                    .snapshots(),
                builder: (context, slotSnapshot) {
                  if (slotSnapshot.hasError) {
                    return Center(
                      child: Text(
                        'Unable to load exam slots: ${slotSnapshot.error}',
                      ),
                    );
                  }

                  if (slotSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final slots = slotSnapshot.data?.docs ?? [];

                  final availableSlots = slots.where((slot) {
                    final data = slot.data();
                    final capacity =
                        (data['totalCapacity'] as num?)?.toInt() ?? 0;
                    final booked = (data['bookedCount'] as num?)?.toInt() ?? 0;

                    return capacity > booked;
                  }).toList();

                  final availableAdmissions = admissions
                      .where(
                        (admission) =>
                            !bookedApplicationIds.contains(admission.id),
                      )
                      .toList();

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Booking history
                      const Text(
                        'My Exam Bookings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (bookings.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(18),
                            child: Text(
                              'You have not booked any exam slots yet.',
                            ),
                          ),
                        )
                      else
                        ...bookings.map((booking) {
                          final data = booking.data();

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          data['studentName'] ?? 'Student',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Chip(
                                        label: Text('BOOKED'),
                                        backgroundColor: Color(0xFFDDF5E2),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  _bookingDetail(
                                    Icons.calendar_today,
                                    'Exam Date',
                                    _formatDate(data['examDate']),
                                  ),
                                  _bookingDetail(
                                    Icons.access_time,
                                    'Time',
                                    '${data['startTime'] ?? '--'} - '
                                        '${data['endTime'] ?? '--'}',
                                  ),
                                  _bookingDetail(
                                    Icons.location_on,
                                    'Venue',
                                    data['venue'] ?? '--',
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                      const SizedBox(height: 20),

                      const Text(
                        'Your Approved Applications',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (admissions.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No approved admission applications found.',
                            ),
                          ),
                        )
                      else
                        ...admissions.map((admission) {
                          final data = admission.data();
                          final isBooked = bookedApplicationIds.contains(
                            admission.id,
                          );

                          return Card(
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.school),
                              ),
                              title: Text(data['studentName'] ?? 'Student'),
                              subtitle: Text(
                                'Class: ${data['classApplying'] ?? '--'}',
                              ),
                              trailing: Chip(
                                label: Text(isBooked ? 'Booked' : 'Approved'),
                                backgroundColor: isBooked
                                    ? Colors.green.shade100
                                    : Colors.blue.shade100,
                              ),
                            ),
                          );
                        }),

                      const SizedBox(height: 24),

                      const Text(
                        'Available Exam Slots',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (availableSlots.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No available exam slots at the moment.',
                            ),
                          ),
                        )
                      else
                        ...availableSlots.map((slot) {
                          final data = slot.data();

                          final capacity =
                              (data['totalCapacity'] as num?)?.toInt() ?? 0;
                          final booked =
                              (data['bookedCount'] as num?)?.toInt() ?? 0;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatDate(data['date']),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Time: ${data['startTime'] ?? '--'} - '
                                    '${data['endTime'] ?? '--'}',
                                  ),
                                  const SizedBox(height: 6),
                                  Text('Venue: ${data['venue'] ?? '--'}'),
                                  const SizedBox(height: 6),
                                  Text('Seats available: ${capacity - booked}'),
                                  const SizedBox(height: 12),

                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: availableAdmissions.isEmpty
                                          ? null
                                          : () {
                                              showDialog(
                                                context: context,
                                                builder: (dialogContext) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                      'Select Student',
                                                    ),
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: availableAdmissions.map((
                                                        admission,
                                                      ) {
                                                        final studentName =
                                                            admission
                                                                .data()['studentName'] ??
                                                            'Student';

                                                        return ListTile(
                                                          leading: const Icon(
                                                            Icons.school,
                                                          ),
                                                          title: Text(
                                                            studentName,
                                                          ),
                                                          subtitle: Text(
                                                            admission
                                                                    .data()['classApplying'] ??
                                                                '',
                                                          ),
                                                          onTap: () {
                                                            Navigator.pop(
                                                              dialogContext,
                                                            );

                                                            bookExamSlot(
                                                              context: context,
                                                              parentId:
                                                                  user.uid,
                                                              admission:
                                                                  admission,
                                                              slot: slot,
                                                            );
                                                          },
                                                        );
                                                      }).toList(),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                      child: Text(
                                        availableAdmissions.isEmpty
                                            ? 'All Students Already Booked'
                                            : 'Book for Another Student',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _bookingDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 10),
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
