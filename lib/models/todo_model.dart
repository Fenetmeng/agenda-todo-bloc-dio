class Todo {
  final int id;
  final String title;
  final bool completed;
  final String category;

  Todo({
    required this.id,
    required this.title,
    required this.completed,
    this.category = 'Personal',
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      completed: json['completed'],
      category: json['category'] ?? 'Personal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'category': category,
    };
  }
}