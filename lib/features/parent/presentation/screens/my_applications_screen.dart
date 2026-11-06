import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constants.dart';

class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('My Applications'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteConstants.createStudent),
        icon: const Icon(Icons.add),
        label: const Text('New Application'),
      ),
      body: user == null
          ? const Center(child: Text('Please login to view your applications.'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('admissions')
                  .where('parentId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Unable to load applications. Please try again.',
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final documents = snapshot.data?.docs ?? [];

                documents.sort((a, b) {
                  final aDate = a.data()['createdAt'];
                  final bDate = b.data()['createdAt'];

                  final aTime = aDate is Timestamp
                      ? aDate.millisecondsSinceEpoch
                      : 0;
                  final bTime = bDate is Timestamp
                      ? bDate.millisecondsSinceEpoch
                      : 0;

                  return bTime.compareTo(aTime);
                });

                if (documents.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  children: [
                    Text(
                      '${documents.length} application${documents.length == 1 ? '' : 's'} found',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ...documents.map((document) {
                      return _ApplicationCard(
                        documentId: document.id,
                        data: document.data(),
                        onTap: () =>
                            _showApplicationDetails(context, document.data()),
                      );
                    }),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.description_outlined,
              size: 72,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Applications Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Your submitted admission applications will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.push(RouteConstants.createStudent),
              icon: const Icon(Icons.add),
              label: const Text('Apply for Admission'),
            ),
          ],
        ),
      ),
    );
  }

  void _showApplicationDetails(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final dateOfBirth = data['dateOfBirth'];
    final dob = dateOfBirth is Timestamp
        ? _formatDate(dateOfBirth.toDate())
        : 'Not available';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(data['studentName']?.toString() ?? 'Student Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Class', data['classApplying']),
              _detailRow('Date of Birth', dob),
              _detailRow('Gender', data['gender']),
              _detailRow('Parent Name', data['parentName']),
              _detailRow('Phone', data['phone']),
              _detailRow('Email', data['email']),
              _detailRow('Previous School', data['previousSchool']),
              _detailRow('Address', data['address']),
              const SizedBox(height: 12),
              const Text(
                'Application Status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              _StatusChip(status: data['status']?.toString() ?? 'pending'),
              if (data['assignedCourse'] != null) ...[
                const SizedBox(height: 12),
                _detailRow('Assigned Course', data['assignedCourse']),
              ],
              if (data['resultPublished'] == true) ...[
                const SizedBox(height: 16),
                const Divider(),
                const Text(
                  'Examination Result',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _ResultSection(data: data),
              ],
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

  static Widget _detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString().isNotEmpty == true
                  ? value.toString()
                  : 'Not provided',
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _ApplicationCard extends StatelessWidget {
  final String documentId;
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _ApplicationCard({
    required this.documentId,
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final createdAt = data['createdAt'];
    final submittedDate = createdAt is Timestamp
        ? _formatDate(createdAt.toDate())
        : 'Recently submitted';

    final studentName = data['studentName']?.toString() ?? 'Student';
    final classApplying = data['classApplying']?.toString() ?? 'Not specified';
    final status = data['status']?.toString() ?? 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.10),
                    child: Icon(
                      Icons.school_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          studentName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          classApplying,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Submitted: $submittedDate',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(status: status),
                ],
              ),

              if (data['resultPublished'] == true) ...[
                const SizedBox(height: 16),
                const Divider(),
                _ResultSection(data: data),
              ],

              if (data['assignedCourse'] != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.school, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Assigned Course: ${data['assignedCourse']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (status == 'completed') ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Congratulations! Your admission is completed.',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push(RouteConstants.paymentPath(documentId));
                  },
                  icon: const Icon(Icons.payment),
                  label: const Text('Registration Fee'),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tap to view details',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _ResultSection extends StatelessWidget {
  final Map<String, dynamic> data;

  const _ResultSection({required this.data});

  @override
  Widget build(BuildContext context) {
    final score = data['examScore'];
    final result = data['resultStatus']?.toString().toLowerCase() ?? '';

    final passed = result == 'passed';

    final color = passed ? Colors.green : Colors.red;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assessment, color: color),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Examination Result',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                passed ? 'PASS' : 'FAIL',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Marks Obtained: ${score ?? '--'} / 100',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            passed
                ? 'Congratulations! You have passed.'
                : 'You have not reached the passing mark.',
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();

    final Color color;
    final String label;

    switch (normalized) {
      case 'approved':
        color = Colors.green;
        label = 'Approved';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Rejected';
        break;
      case 'completed':
        color = Colors.teal;
        label = 'Admission Completed';
        break;
      default:
        color = Colors.orange;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
