import 'package:supabase_flutter/supabase_flutter.dart';
import '../dashboard/task_model.dart';

class TaskService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Task>> fetchTasks(String userEmail) async {
    final List<dynamic> data = await _client
        .from('tasks')
        .select()
        .eq('user_email', userEmail)
        .order('created_at', ascending: false);

    return data.map((json) => Task.fromJson(json)).toList();
  }

  Future<Task> addTask(String title, String userEmail) async {
    final List<dynamic> data = await _client.from('tasks').insert({
      'title': title,
      'user_email': userEmail,
    }).select(); // Need select() to return inserted rows

    return Task.fromJson(data.first);
  }

  Future<void> updateTask(Task task) async {
    await _client
        .from('tasks')
        .update({'title': task.title, 'is_completed': task.isCompleted})
        .eq('id', task.id);
  }

  Future<void> deleteTask(String id) async {
    await _client.from('tasks').delete().eq('id', id);
  }
}
