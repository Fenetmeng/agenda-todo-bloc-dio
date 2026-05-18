import 'package:dio/dio.dart';
import '../models/todo_model.dart';

class TodoApiService {
  final Dio dio = Dio();

  final String baseUrl = 'https://jsonplaceholder.typicode.com/todos';

  Future<List<Todo>> fetchTodos() async {
    try {
      final response = await dio.get(baseUrl);

      List data = response.data;

      return data.map((json) => Todo.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load todos');
    }
  }

  Future<void> createTodo(String title, String category) async {
    try {
      await dio.post(
        baseUrl,
        data: {
          'title': title,
          'completed': false,
          'category': category,
        },
      );
    } catch (e) {
      throw Exception('Failed to create todo');
    }
  }

  Future<void> updateTodo(
    int id,
    String title,
    bool completed,
    String category,
  ) async {
    try {
      await dio.put(
        '$baseUrl/$id',
        data: {
          'title': title,
          'completed': completed,
          'category': category,
        },
      );
    } catch (e) {
      throw Exception('Failed to update todo');
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      await dio.delete('$baseUrl/$id');
    } catch (e) {
      throw Exception('Failed to delete todo');
    }
  }
}