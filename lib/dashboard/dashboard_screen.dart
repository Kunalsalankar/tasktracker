import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';
import '../app/theme_provider.dart';
import '../app/theme.dart';
import 'task_model.dart';
import 'task_service.dart';
import 'task_tile.dart';
import '../auth/login_screen.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late TaskService taskService;
  List<Task> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadTasks(context);
    });
  }

  Future<void> loadTasks(BuildContext ctx) async {
    final auth = Provider.of<AuthService>(ctx, listen: false);
    final userEmail = auth.email;
    taskService = TaskService();

    if (userEmail != null) {
      final fetchedTasks = await taskService.fetchTasks(userEmail);
      if (mounted) {
        setState(() {
          tasks = fetchedTasks;
          isLoading = false;
        });
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> addTask(String title) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final newTask = await taskService.addTask(title, auth.email ?? '');
    setState(() => tasks.insert(0, newTask));
  }

  Future<void> deleteTask(String id) async {
    await taskService.deleteTask(id);
    setState(() => tasks.removeWhere((task) => task.id == id));
  }

  Future<void> toggleTask(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await taskService.updateTask(updatedTask);
    setState(() {
      final index = tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        tasks[index] = updatedTask;
      }
    });
  }

  Future<void> editTask(Task task, String newTitle) async {
    final updatedTask = task.copyWith(title: newTitle);
    await taskService.updateTask(updatedTask);
    setState(() {
      final index = tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        tasks[index] = updatedTask;
      }
    });
  }

  void showAddTaskDialog() {
    String newTaskTitle = '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Task'),
        content: TextField(
          onChanged: (val) => newTaskTitle = val,
          decoration: const InputDecoration(hintText: 'Enter task title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newTaskTitle.trim().isNotEmpty) {
                await addTask(newTaskTitle.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void showEditTaskDialog(Task task) {
    final controller = TextEditingController(text: task.title);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Task'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Edit task title'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedTitle = controller.text.trim();
              if (updatedTitle.isNotEmpty) {
                await editTask(task, updatedTitle);
                controller.dispose();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Row(
            children: [
              Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
              Switch(
                value: isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Optional: call logout logic from AuthService
              Provider.of<AuthService>(context, listen: false).logout();

              // Navigate to LoginScreen
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
          ? const Center(child: Text('No tasks'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskTile(
            task: task,
            onToggle: () => toggleTask(task),
            onDelete: () => deleteTask(task.id),
            onEdit: () => showEditTaskDialog(task),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
