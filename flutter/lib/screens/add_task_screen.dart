import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _assignedToController = TextEditingController();
  DateTime? _dueDate;
  bool _isLoading = false;

  String _predictedCategory = 'general';
  String _predictedPriority = 'low';
  List<String> _extractedEntities = [];
  List<String> _suggestedActions = [];

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_updateClassification);
    _descriptionController.addListener(_updateClassification);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assignedToController.dispose();
    super.dispose();
  }

  void _updateClassification() {
    final title = _titleController.text;
    final description = _descriptionController.text;
    final fullText = '$title $description'.toLowerCase();

    String category = 'general';
    if (fullText.contains('meeting') ||
        fullText.contains('schedule') ||
        fullText.contains('call')) {
      category = 'scheduling';
    } else if (fullText.contains('payment') ||
        fullText.contains('invoice') ||
        fullText.contains('bill')) {
      category = 'finance';
    } else if (fullText.contains('bug') ||
        fullText.contains('fix') ||
        fullText.contains('error')) {
      category = 'technical';
    } else if (fullText.contains('safety') ||
        fullText.contains('inspection') ||
        fullText.contains('hazard')) {
      category = 'safety';
    }

    String priority = 'low';
    if (fullText.contains('urgent') ||
        fullText.contains('asap') ||
        fullText.contains('today')) {
      priority = 'high';
    } else if (fullText.contains('soon') || fullText.contains('this week')) {
      priority = 'medium';
    }

    final entities = <String>[];
    final dateRegex = RegExp(
        r'\b\d{1,2}\/\d{1,2}\/\d{4}|\btoday\b|\btomorrow\b|\bnext week\b',
        caseSensitive: false);
    entities.addAll(dateRegex.allMatches(fullText).map((m) => m.group(0)!));

    final personRegex =
        RegExp(r'(?:with|by|assign to)\s+([A-Z][a-z]+)', caseSensitive: false);
    entities.addAll(personRegex.allMatches(fullText).map((m) => m.group(1)!));

    final actionRegex = RegExp(
        r'\b(schedule|fix|pay|inspect|update|create|send|call)\b',
        caseSensitive: false);
    entities.addAll(actionRegex.allMatches(fullText).map((m) => m.group(0)!));

    final actions = <String>[];
    switch (category) {
      case 'scheduling':
        actions.addAll([
          'Block calendar',
          'Send invite',
          'Prepare agenda',
          'Set reminder'
        ]);
        break;
      case 'finance':
        actions.addAll([
          'Check budget',
          'Get approval',
          'Generate invoice',
          'Update records'
        ]);
        break;
      case 'technical':
        actions.addAll([
          'Diagnose issue',
          'Check resources',
          'Assign technician',
          'Document fix'
        ]);
        break;
      case 'safety':
        actions.addAll([
          'Conduct inspection',
          'File report',
          'Notify supervisor',
          'Update checklist'
        ]);
        break;
    }

    setState(() {
      _predictedCategory = category;
      _predictedPriority = priority;
      _extractedEntities = entities.toSet().toList();
      _suggestedActions = actions;
    });
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'scheduling':
        return Colors.blue;
      case 'finance':
        return Colors.green;
      case 'technical':
        return Colors.orange;
      case 'safety':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await context.read<TaskProvider>().addTask(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            assignedTo: _assignedToController.text.trim().isNotEmpty
                ? _assignedToController.text.trim()
                : null,
            dueDate: _dueDate,
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task added successfully')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding task: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _assignedToController,
                decoration: const InputDecoration(
                  labelText: 'Assigned To (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _dueDate == null
                          ? 'No due date selected'
                          : 'Due Date: ${_dueDate!.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => _dueDate = picked);
                      }
                    },
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_titleController.text.isNotEmpty ||
                  _descriptionController.text.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI Classification Preview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _ClassificationChip(
                                label: 'Category',
                                value: _predictedCategory,
                                color: _getCategoryColor(_predictedCategory),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ClassificationChip(
                                label: 'Priority',
                                value: _predictedPriority,
                                color: _getPriorityColor(_predictedPriority),
                              ),
                            ),
                          ],
                        ),
                        if (_extractedEntities.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Extracted Entities:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: _extractedEntities
                                .map((entity) => Chip(
                                      label: Text(entity),
                                      backgroundColor: Colors.blue.shade100,
                                    ))
                                .toList(),
                          ),
                        ],
                        if (_suggestedActions.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Suggested Actions:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          ..._suggestedActions.map((action) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle,
                                        size: 16, color: Colors.green),
                                    const SizedBox(width: 8),
                                    Text(action),
                                  ],
                                ),
                              )),
                        ],
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Add Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassificationChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ClassificationChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
