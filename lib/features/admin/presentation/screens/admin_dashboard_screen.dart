import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _updateApplicationStatus(
    BuildContext context,
    DocumentSnapshot<Map<String, dynamic>> doc,
    String newStatus,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          newStatus == 'approved'
              ? 'Approve Application?'
              : 'Reject Application?',
        ),
        content: Text(
          'Are you sure you want to ${newStatus.toUpperCase()} '
          'this application?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(newStatus == 'approved' ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await doc.reference.update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Application ${newStatus.toUpperCase()} successfully.'),
          backgroundColor: newStatus == 'approved' ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to update application: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


Future<void> _assignCourse(
  BuildContext context,
  DocumentSnapshot<Map<String, dynamic>> doc,
) async {
  final data = doc.data() ?? {};

  final initialCourse =
      data['assignedCourse']?.toString() ??
      data['classApplying']?.toString() ??
      '';

  String enteredCourse = initialCourse;

  final course = await showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Assign Course'),
        content: TextFormField(
          initialValue: initialCourse,
          autofocus: true,
          onChanged: (value) {
            enteredCourse = value;
          },
          decoration: const InputDecoration(
            labelText: 'Course / Class',
            hintText: 'Example: Grade 5',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = enteredCourse.trim();

              if (value.isNotEmpty) {
                Navigator.of(dialogContext).pop(value);
              }
            },
            child: const Text('Save Course'),
          ),
        ],
      );
    },
  );

  if (course == null || !context.mounted) return;

  try {
    await doc.reference.update({
      'assignedCourse': course,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Course "$course" assigned successfully.'),
      ),
    );
  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Unable to assign course: $e'),
      ),
    );
  }
}


  Future<void> _completeAdmission(
    BuildContext context,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final data = doc.data()!;
    final course = data['assignedCourse']?.toString().trim() ?? '';

    if (course.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please assign a course first.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Complete Admission?'),
        content: Text(
          'Complete the admission for ${data['studentName']} '
          'in $course?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Complete Admission'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await doc.reference.update({
        'status': 'completed',
        'admissionCompletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admission completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to complete admission: $e')),
      );
    }
  }

  void _showApplicationDetails(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final dateOfBirth = data['dateOfBirth'];

    String dob = 'N/A';
    if (dateOfBirth is Timestamp) {
      dob = dateOfBirth.toDate().toString().split(' ')[0];
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Application Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow('Student Name', data['studentName']),
              _DetailRow('Date of Birth', dob),
              _DetailRow('Gender', data['gender']),
              _DetailRow('Class Applying', data['classApplying']),
              _DetailRow('Previous School', data['previousSchool']),
              const Divider(),
              _DetailRow('Parent Name', data['parentName']),
              _DetailRow('Parent Email', data['parentEmail']),
              _DetailRow('Phone', data['phone']),
              _DetailRow('Address', data['address']),
              const Divider(),
              _DetailRow(
                'Status',
                (data['status'] ?? 'pending').toString().toUpperCase(),
              ),
              if (data['assignedCourse'] != null)
                _DetailRow('Assigned Course', data['assignedCourse']),

              if (data['resultPublished'] == true)
                _DetailRow(
                  'Exam Result',
                  '${data['resultStatus']} (${data['examScore']}/100)',
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutRequested());
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('admissions').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error loading applications:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final applications = snapshot.data?.docs ?? [];

          final pending = applications
              .where((doc) => doc.data()['status'] == 'pending')
              .length;

          final approved = applications
              .where((doc) => doc.data()['status'] == 'approved')
              .length;

          final rejected = applications
              .where((doc) => doc.data()['status'] == 'rejected')
              .length;
          final completed = applications
              .where((doc) => doc.data()['status'] == 'completed')
              .length;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Admission Overview',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _StatCard(
                    title: 'Total Applications',
                    count: applications.length,
                    icon: Icons.description,
                    color: Colors.blue,
                  ),
                  _StatCard(
                    title: 'Pending',
                    count: pending,
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                  ),
                  _StatCard(
                    title: 'Approved',
                    count: approved,
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                  _StatCard(
                    title: 'Rejected',
                    count: rejected,
                    icon: Icons.cancel,
                    color: Colors.red,
                  ),
                  _StatCard(
                    title: 'Completed',
                    count: completed,
                    icon: Icons.task_alt,
                    color: Colors.teal,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Manage Exam Slots
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push(RouteConstants.manageSlots);
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Manage Exam Slots'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // View Exam Bookings
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push(RouteConstants.adminExamBookings);
                  },
                  icon: const Icon(Icons.event_available),
                  label: const Text('View Exam Bookings'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Admission Applications',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (applications.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text('No applications received yet.'),
                  ),
                )
              else
                ...applications.map((doc) {
                  final data = doc.data();
                  final status = (data['status'] ?? 'pending').toString();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(
                              data['studentName']?.toString() ??
                                  'Unknown Student',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Class: ${data['classApplying'] ?? 'N/A'}\n'
                              'Parent: ${data['parentName'] ?? 'N/A'}',
                            ),
                            isThreeLine: true,
                            trailing: _StatusBadge(status: status),
                          ),

                          TextButton.icon(
                            onPressed: () =>
                                _showApplicationDetails(context, data),
                            icon: const Icon(Icons.visibility),
                            label: const Text('View Details'),
                          ),

                          if (status == 'approved') ...[
                            if (data['resultPublished'] != true) ...[
                              TextButton.icon(
                                onPressed: () {
                                  context.push(
                                    RouteConstants.updateScorePath(doc.id),
                                  );
                                },
                                icon: const Icon(Icons.edit_note),
                                label: const Text('Enter Exam Score'),
                              ),
                            ],

                            if (data['resultPublished'] == true &&
                                data['resultStatus'] == 'passed') ...[
                              const Divider(),

                              Text(
                                'Exam Result: PASSED',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              TextButton.icon(
                                onPressed: () => _assignCourse(context, doc),
                                icon: const Icon(Icons.school),
                                label: Text(
                                  data['assignedCourse'] == null
                                      ? 'Assign Course'
                                      : 'Update Assigned Course',
                                ),
                              ),

                              if ((data['assignedCourse']
                                      ?.toString()
                                      .isNotEmpty ??
                                  false))
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _completeAdmission(context, doc),
                                    icon: const Icon(Icons.task_alt),
                                    label: const Text('Complete Admission'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ],

                          if (status == 'pending') ...[
                            const Divider(),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _updateApplicationStatus(
                                      context,
                                      doc,
                                      'rejected',
                                    ),
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                    label: const Text('Reject'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _updateApplicationStatus(
                                      context,
                                      doc,
                                      'approved',
                                    ),
                                    icon: const Icon(Icons.check),
                                    label: const Text('Approve'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (status) {
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      case 'completed':
        color = Colors.teal;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final dynamic value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(value?.toString().isNotEmpty == true ? value.toString() : 'N/A'),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
