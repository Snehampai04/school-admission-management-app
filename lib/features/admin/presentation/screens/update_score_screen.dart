
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UpdateScoreScreen extends StatefulWidget {
  final String studentId;

  const UpdateScoreScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<UpdateScoreScreen> createState() => _UpdateScoreScreenState();
}

class _UpdateScoreScreenState extends State<UpdateScoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scoreController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  Future<void> _saveResult() async {
    if (!_formKey.currentState!.validate()) return;

    final score = int.parse(_scoreController.text.trim());

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('admissions')
          .doc(widget.studentId)
          .update({
        'examScore': score,
        'resultStatus': score >= 35 ? 'passed' : 'failed',
        'resultPublished': true,
        'resultPublishedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exam result published successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to publish result: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Exam Score'),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('admissions')
            .doc(widget.studentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Unable to load student details.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Student application not found.'));
          }

          final data = snapshot.data!.data()!;

          final existingScore = data['examScore'];
          if (_scoreController.text.isEmpty && existingScore != null) {
            _scoreController.text = existingScore.toString();
          }

          final studentName = data['studentName'] ?? 'Unknown Student';
          final applicationStatus = data['status'] ?? 'pending';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.school,
                        size: 42,
                        color: Colors.teal,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        studentName.toString(),
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Class: ${data['classApplying'] ?? '--'}',
                      ),
                      Text(
                        'Application Status: '
                        '${applicationStatus.toString().toUpperCase()}',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Enter Examination Result',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Enter the student examination marks out of 100. '
                'The passing mark is set to 35.',
              ),

              const SizedBox(height: 20),

              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _scoreController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Exam Score',
                    hintText: 'Enter marks (0–100)',
                    prefixIcon: Icon(Icons.score),
                    suffixText: '/ 100',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the exam score.';
                    }

                    final score = int.tryParse(value.trim());

                    if (score == null) {
                      return 'Please enter a valid whole number.';
                    }

                    if (score < 0 || score > 100) {
                      return 'Score must be between 0 and 100.';
                    }

                    return null;
                  },
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveResult,
                  icon: _isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.publish),
                  label: Text(
                    _isSaving ? 'Publishing...' : 'Publish Result',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
