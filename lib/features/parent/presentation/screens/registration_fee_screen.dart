import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/firestore_constants.dart';

class RegistrationFeeScreen extends StatefulWidget {
  final String studentId;

  const RegistrationFeeScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<RegistrationFeeScreen> createState() =>
      _RegistrationFeeScreenState();
}

class _RegistrationFeeScreenState extends State<RegistrationFeeScreen> {
  final _amountController = TextEditingController();

  String _paymentMethod = 'UPI';
  bool _isProcessing = false;

  final _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _admissionRef =>
      _firestore
          .collection('admissions')
          .doc(widget.studentId);

  DocumentReference<Map<String, dynamic>> get _paymentRef =>
      _firestore
          .collection(FirestoreConstants.paymentsCollection)
          .doc(widget.studentId);

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _payNow() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Please login to continue.');
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      _showMessage('Please enter a valid payment amount.');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      await _firestore.runTransaction((transaction) async {
        final admissionSnapshot =
            await transaction.get(_admissionRef);

        final paymentSnapshot =
            await transaction.get(_paymentRef);

        if (!admissionSnapshot.exists) {
          throw Exception('Admission application not found.');
        }

        final admissionData = admissionSnapshot.data()!;

        if (admissionData['parentId'] != user.uid) {
          throw Exception('You cannot pay for this application.');
        }

        if (paymentSnapshot.exists &&
            paymentSnapshot.data()?['status'] == 'paid') {
          throw Exception('Payment has already been completed.');
        }

        final transactionId =
            'MOCK-${DateTime.now().millisecondsSinceEpoch}';

        transaction.set(_paymentRef, {
          'admissionId': widget.studentId,
          'parentId': user.uid,
          'studentName': admissionData['studentName'] ?? '',
          FirestoreConstants.amount: amount,
          'paymentMethod': _paymentMethod,
          FirestoreConstants.status: 'paid',
          FirestoreConstants.transactionId: transactionId,
          FirestoreConstants.timestamp:
              FieldValue.serverTimestamp(),
        });

        transaction.update(_admissionRef, {
          FirestoreConstants.paymentStatus: 'paid',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      if (mounted) {
        _showMessage('Mock payment successful!');
      }
    } catch (e) {
      if (mounted) {
        _showMessage(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _skipPayment() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Please login to continue.');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(_admissionRef);

        if (!snapshot.exists) {
          throw Exception('Admission application not found.');
        }

        final data = snapshot.data()!;

        if (data['parentId'] != user.uid) {
          throw Exception('You cannot update this application.');
        }

        final existingPayment = await transaction.get(_paymentRef);

        if (existingPayment.exists &&
            existingPayment.data()?['status'] == 'paid') {
          throw Exception('Payment is already completed.');
        }

        transaction.update(_admissionRef, {
          FirestoreConstants.paymentStatus: 'skipped',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      if (mounted) {
        _showMessage(
          'Payment skipped. You can continue with exam slot booking.',
        );
      }
    } catch (e) {
      if (mounted) {
        _showMessage(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'skipped':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Fee'),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _admissionRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Application not found.'),
            );
          }

          final data = snapshot.data!.data()!;
          final user = FirebaseAuth.instance.currentUser;

          if (user == null || data['parentId'] != user.uid) {
            return const Center(
              child: Text('You do not have access to this application.'),
            );
          }

          final paymentStatus =
              data[FirestoreConstants.paymentStatus]
                      ?.toString()
                      .toLowerCase() ??
                  'pending';

          final isPaid = paymentStatus == 'paid';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 64,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              const Text(
                'Registration Fee Payment',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Student: ${data['studentName'] ?? 'Student'}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Chip(
                        label: Text(paymentStatus.toUpperCase()),
                        backgroundColor:
                            _statusColor(paymentStatus).withValues(
                          alpha: 0.15,
                        ),
                        labelStyle: TextStyle(
                          color: _statusColor(paymentStatus),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (isPaid) ...[
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 48,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Payment Completed',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Your mock registration fee payment '
                          'has been recorded successfully.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                const Text(
                  'Enter Registration Fee Amount',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    prefixText: '₹ ',
                    hintText: 'Enter amount',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 18),

                const Text(
                  'Payment Method',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _paymentMethod,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'UPI',
                      child: Text('UPI (Mock)'),
                    ),
                    DropdownMenuItem(
                      value: 'Card',
                      child: Text('Card (Mock)'),
                    ),
                    DropdownMenuItem(
                      value: 'Cash',
                      child: Text('Cash (Mock)'),
                    ),
                  ],
                  onChanged: _isProcessing
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _paymentMethod = value);
                          }
                        },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _payNow,
                    icon: const Icon(Icons.payment),
                    label: Text(
                      _isProcessing ? 'Processing...' : 'Pay Now',
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed:
                        _isProcessing ? null : _skipPayment,
                    child: const Text('Skip Payment'),
                  ),
                ),
              ],

              const SizedBox(height: 20),
              const Text(
                'This is a mock payment for demonstration only. '
                'No real money will be charged.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}