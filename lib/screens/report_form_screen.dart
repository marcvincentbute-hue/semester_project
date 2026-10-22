
import 'package:flutter/material.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

enum ReportUiState { idle, loading, success, empty, error }

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _category = 'Facility Issue';
  ReportUiState _uiState = ReportUiState.idle;
  bool _simulateFailure = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _uiState = ReportUiState.loading);

    await Future<void>.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    setState(() {
      _uiState = _simulateFailure
          ? ReportUiState.error
          : ReportUiState.success;
    });
  }

  void _showEmptyState() {
    setState(() => _uiState = ReportUiState.empty);
  }

 void _resetForm() {
  _titleController.clear();
  _descriptionController.clear();

  setState(() {
    _uiState = ReportUiState.idle;
    _simulateFailure = false;
    _category = 'Facility Issue';
  });

  _formKey.currentState?.reset();
}

  Widget _stateMessage() {
    switch (_uiState) {
      case ReportUiState.loading:
        return const Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Submitting report...'),
          ],
        );

      case ReportUiState.success:
        return const Text(
          'Success! Your report was processed (simulation only).',
          style: TextStyle(color: Colors.green),
        );

      case ReportUiState.empty:
        return const Text(
          'No reports available yet.',
          style: TextStyle(color: Colors.orange),
        );

      case ReportUiState.error:
        return const Text(
          'Submission failed (simulated). Please retry.',
          style: TextStyle(color: Colors.red),
        );

      case ReportUiState.idle:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _uiState == ReportUiState.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Report Form')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Submit a Report',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  AppTextField(
                    controller: _titleController,
                    label: 'Report Title',
                    validator: (value) {
                       if (value == null || value.trim().isEmpty) {
                        return 'Please enter a report title';
                        }
                        return null;
                        },
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Facility Issue',
                        child: Text('Facility Issue'),
                      ),
                      DropdownMenuItem(
                        value: 'Maintenance',
                        child: Text('Maintenance'),
                      ),
                      DropdownMenuItem(
                        value: 'Other',
                        child: Text('Other'),
                      ),
                    ],
                    onChanged: isLoading
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _category = value);
                            }
                          },
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a description';
                      }
                    return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Simulate submission error'),
                    value: _simulateFailure,
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _simulateFailure = value ?? false;
                            });
                          },
                  ),

                  AppButton(
                    label: isLoading ? 'Please wait...' : 'Submit Report',
                    onPressed: isLoading ? null : _submitReport,
                  ),
                  const SizedBox(height: 12),

                  OutlinedButton(
                    onPressed: isLoading ? null : _showEmptyState,
                    child: const Text('View Empty State'),
                  ),
                  TextButton(
                    onPressed: isLoading ? null : _resetForm,
                    child: const Text('Reset Form'),
                  ),
                  const SizedBox(height: 20),
                  Center(child: _stateMessage()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
