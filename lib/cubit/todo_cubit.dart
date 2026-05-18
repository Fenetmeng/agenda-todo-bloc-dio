import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/todo_model.dart';
import '../services/todo_api_service.dart';
import 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  final TodoApiService apiService;

  TodoCubit(this.apiService) : super(TodoInitial());

  List<Todo> todos = [];

  Future<void> getTodos() async {
    emit(TodoLoading());

    try {
    await apiService.fetchTodos();

    todos = [];

emit(TodoLoaded(todos));
    } catch (e) {
      emit(TodoError('Failed to fetch todos'));
    }
  }

  Future<void> addTodo(String title, String category) async {
    try {
      await apiService.createTodo(title, category);

      final newTodo = Todo(
        id: todos.length + 1,
        title: title,
        completed: false,
        category: category,
      );

      todos.insert(0, newTodo);
      emit(TodoLoaded(List.from(todos)));
    } catch (e) {
      emit(TodoError('Failed to add todo'));
    }
  }

  Future<void> updateTodo(
    int id,
    String title,
    bool completed,
    String category,
  ) async {
    try {
      await apiService.updateTodo(id, title, completed, category);

      todos = todos.map((todo) {
        if (todo.id == id) {
          return Todo(
            id: id,
            title: title,
            completed: completed,
            category: category,
          );
        }
        return todo;
      }).toList();

      emit(TodoLoaded(List.from(todos)));
    } catch (e) {
      emit(TodoError('Failed to update todo'));
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      await apiService.deleteTodo(id);

      todos.removeWhere((todo) => todo.id == id);
      emit(TodoLoaded(List.from(todos)));
    } catch (e) {
      emit(TodoError('Failed to delete todo'));
    }
  }
}