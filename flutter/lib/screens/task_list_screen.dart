import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedPriority = 'All';
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().fetchTasks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Task> _getFilteredTasks(List<Task> tasks) {
    return tasks.where((task) {
      final matchesSearch = task.title
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          task.description
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All' || task.category == _selectedCategory;
      final matchesPriority =
          _selectedPriority == 'All' || task.priority == _selectedPriority;
      final matchesStatus =
          _selectedStatus == 'All' || task.status == _selectedStatus;

      return matchesSearch &&
          matchesCategory &&
          matchesPriority &&
          matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Site Task Manager'),
        actions: [
          Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: taskProvider.isLoading
                    ? null
                    : () => context.read<TaskProvider>().fetchTasks(),
              );
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (!taskProvider.isOnline) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No internet connection',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Please check your connection and try again'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<TaskProvider>().fetchTasks(),
            child: Column(
              children: [
                // Summary Cards
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'Pending',
                          count: taskProvider.tasks
                              .where((t) => t.status == 'pending')
                              .length,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SummaryCard(
                          title: 'In Progress',
                          count: taskProvider.tasks
                              .where((t) => t.status == 'in_progress')
                              .length,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Completed',
                          count: taskProvider.tasks
                              .where((t) => t.status == 'completed')
                              .length,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                // Filters
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Search
                      TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search tasks...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                      const SizedBox(height: 8),

                      // Filter Row
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration:
                                  const InputDecoration(labelText: 'Category'),
                              items: [
                                'All',
                                'scheduling',
                                'finance',
                                'technical',
                                'safety',
                                'general'
                              ]
                                  .map((category) => DropdownMenuItem(
                                      value: category, child: Text(category)))
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedCategory = value!),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedPriority,
                              decoration:
                                  const InputDecoration(labelText: 'Priority'),
                              items: ['All', 'high', 'medium', 'low']
                                  .map((priority) => DropdownMenuItem(
                                      value: priority, child: Text(priority)))
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedPriority = value!),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedStatus,
                              decoration:
                                  const InputDecoration(labelText: 'Status'),
                              items: [
                                'All',
                                'pending',
                                'in_progress',
                                'completed'
                              ]
                                  .map((status) => DropdownMenuItem(
                                      value: status, child: Text(status)))
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedStatus = value!),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Task List
                Expanded(
                  child: taskProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _getFilteredTasks(taskProvider.tasks).isEmpty
                          ? const Center(
                              child: Text(
                                  'No tasks found. Add a new task to get started.'),
                            )
                          : ListView.builder(
                              itemCount:
                                  _getFilteredTasks(taskProvider.tasks).length,
                              itemBuilder: (context, index) {
                                final task = _getFilteredTasks(
                                    taskProvider.tasks)[index];
                                return TaskCard(task: task);
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(task.title),
        subtitle: Text(task.description),
        trailing: Chip(
          label: Text(task.status),
          backgroundColor: _getStatusColor(task.status),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(task: task),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
