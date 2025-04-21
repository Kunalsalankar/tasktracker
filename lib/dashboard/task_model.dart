class Task {
  final String id;
  final String title;
  final String userId;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.userId,
    required this.isCompleted,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    userId: json['user_id'],
    isCompleted: json['is_completed'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'user_id': userId,
    'is_completed': isCompleted,
  };

  Task copyWith({
    String? id,
    String? title,
    String? userId,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      userId: userId ?? this.userId,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}