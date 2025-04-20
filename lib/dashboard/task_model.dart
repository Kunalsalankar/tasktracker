class Task {
  final String id;
  final String title;
  final String userEmail;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.userEmail,
    required this.isCompleted,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    userEmail: json['user_email'],
    isCompleted: json['is_completed'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'user_email': userEmail,
    'is_completed': isCompleted,
  };

  Task copyWith({
    String? id,
    String? title,
    String? userEmail,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      userEmail: userEmail ?? this.userEmail,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
