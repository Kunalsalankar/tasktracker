import 'package:supabase_flutter/supabase_flutter.dart';
import '../dashboard/task_model.dart';

class TaskService {
  final SupabaseClient _client = Supabase.instance.client;

  // Fetch tasks for the current authenticated user
  Future<List<Task>> fetchTasks(String userEmail) async {
    final user = _client.auth.currentUser;
    final userId = user?.id;

    if (userId == null) {
      throw Exception('User is not authenticated');
    }

    final response = await _client
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((json) => Task.fromJson(json))
        .toList();
  }

  // Add a new task for the current authenticated user
  Future<Task> addTask(String title, String userEmail) async {
    final user = _client.auth.currentUser;
    final userId = user?.id;

    if (userId == null) {
      throw Exception('User is not authenticated');
    }

    final response = await _client.from('tasks').insert({
      'title': title,
      'user_id': userId,
      'is_completed': false,
    }).select();

    return Task.fromJson(response.first);
  }

  // Update a task
  Future<void> updateTask(Task task) async {
    await _client
        .from('tasks')
        .update({
      'title': task.title,
      'is_completed': task.isCompleted,
    })
        .eq('id', task.id);
  }

  // Delete a task
  Future<void> deleteTask(String id) async {
    await _client.from('tasks').delete().eq('id', id);
  }
}