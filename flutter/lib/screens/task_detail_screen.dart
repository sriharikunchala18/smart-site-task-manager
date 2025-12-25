import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _assignedToController;
  String? _selectedStatus;
  String? _selectedPriority;
  DateTime? _dueDate;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _assignedToController = TextEditingController(text: widget.task.assignedTo ?? '');
    _selectedStatus = widget.task.status;
    _selectedPriority = widget.task.priority;
    _dueDate = widget.task.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assignedToController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
    final taskProvider = context.read<TaskProvider>();
    taskProvider.updateTask(
      id: widget.task.id,
      title: _titleController.text,
      description: _descriptionController.text,
      status: _selectedStatus,
      priority: _selectedPriority,
      assignedTo: _assignedToController.text.isNotEmpty ? _assignedToController.text : null,
      dueDate: _dueDate,
    ).then((_) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task updated successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating task: $error')),
      );
    });
  }

  void _deleteTask() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final taskProvider = context.read<TaskProvider>();
              taskProvider.deleteTask(widget.task.id).then((_) {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task deleted successfully')),
                );
              }).catchError((error) {
                Navigator.of(context).pop(); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting task: $error')),
                );
              });
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing ? _saveChanges : _toggleEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteTask,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField(
              controller: _titleController,
              label: 'Title',
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              maxLines: 3,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _assignedToController,
              label: 'Assigned To',
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Status',
              value: _selectedStatus,
              items: ['pending', 'in_progress', 'completed'],
              onChanged: _isEditing ? (value) => setState(() => _selectedStatus = value) : null,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Priority',
              value: _selectedPriority,
              items: ['low', 'medium', 'high'],
              onChanged: _isEditing ? (value) => setState(() => _selectedPriority = value) : null,
            ),
            const SizedBox(height: 16),
            _buildDateField(),
            const SizedBox(height: 32),
            _buildInfoSection('Category', widget.task.category),
            _buildInfoSection('Created', widget.task.createdAt.toString()),
            _buildInfoSection('Updated', widget.task.updatedAt.toString()),
            if (widget.task.extractedEntities.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildListSection('Extracted Entities', widget.task.extractedEntities),
            ],
            if (widget.task.suggestedActions.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildListSection('Suggested Actions', widget.task.suggestedActions),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      enabled: enabled,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?)? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      value: value,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateField() {
    return Row(
      children: [
        Expanded(
          child: Text(
            _dueDate == null
                ? 'No due date'
                : 'Due Date: ${_dueDate!.toLocal().toString().split(' ')[0]}',
          ),
        ),
        if (_isEditing)
          TextButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _dueDate ?? DateTime.now(),
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
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  Widget _buildListSection(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ...items.map((item) => Text('• $item')),
      ],
    );
  }
}
