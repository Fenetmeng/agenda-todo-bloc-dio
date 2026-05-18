import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../cubit/todo_cubit.dart';
import '../cubit/todo_state.dart';
import '../models/todo_model.dart';

enum TodoFilter { all, pending, completed }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController taskController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  String searchText = '';
  TodoFilter selectedFilter = TodoFilter.all;

  bool isDarkMode = false;

  Set<int> selectedTodoIds = {};

  String selectedCategory = 'Personal';

  final List<String> categories = [
    'School',
    'Personal',
    'Work',
  ];

  Color get sageGreen => const Color(0xFF7A947B);

  Color get darkSage => const Color(0xFF355E3B);

  Color get backgroundColor =>
      isDarkMode ? const Color(0xFF1F2A24) : const Color(0xFFFFFBF1);

  Color get cardColor =>
      isDarkMode ? const Color(0xFF2D3A32) : const Color(0xFFFFFDF7);

  Color get headerColor =>
      isDarkMode ? const Color(0xFF314538) : const Color(0xFFE3ECDD);

  Color get textColor =>
      isDarkMode ? const Color(0xFFF7F3E9) : Colors.black87;

  Color get subtitleColor =>
      isDarkMode ? const Color(0xFFDDE8D5) : darkSage.withOpacity(0.75);

  @override
  void initState() {
    super.initState();
    context.read<TodoCubit>().getTodos();
  }

  void showSnackMessage(String message, {bool isDelete = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isDelete ? Icons.delete_outline : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: isDelete ? Colors.redAccent : sageGreen,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void showTodoDialog({Todo? todo}) {
    if (todo != null) {
      taskController.text = todo.title;
      selectedCategory = todo.category;
    } else {
      taskController.clear();
      selectedCategory = 'Personal';
    }

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            todo == null ? 'Add New Task' : 'Edit Task',
            style: TextStyle(
              color: isDarkMode ? Colors.white : darkSage,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: taskController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Task title',
                      labelStyle: TextStyle(color: subtitleColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: sageGreen,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    dropdownColor: cardColor,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: TextStyle(color: subtitleColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(
                          category,
                          style: TextStyle(color: textColor),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                taskController.clear();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: sageGreen),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: sageGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final title = taskController.text.trim();

                if (title.isNotEmpty) {
                  if (todo == null) {
                    context.read<TodoCubit>().addTodo(
                          title,
                          selectedCategory,
                        );

                    showSnackMessage(
                      'Task added successfully',
                    );
                  } else {
                    context.read<TodoCubit>().updateTodo(
                          todo.id,
                          title,
                          todo.completed,
                          selectedCategory,
                        );

                    showSnackMessage(
                      'Task updated successfully',
                    );
                  }

                  Navigator.pop(context);
                  taskController.clear();
                }
              },
              child: Text(
                todo == null ? 'Add' : 'Update',
              ),
            ),
          ],
        );
      },
    );
  }

  List<Todo> getFilteredTodos(List<Todo> todos) {
    List<Todo> filtered = todos;

    if (selectedFilter == TodoFilter.pending) {
      filtered = filtered
          .where((todo) => !todo.completed)
          .toList();
    } else if (selectedFilter == TodoFilter.completed) {
      filtered = filtered
          .where((todo) => todo.completed)
          .toList();
    }

    if (searchText.isNotEmpty) {
      filtered = filtered.where((todo) {
        return todo.title.toLowerCase().contains(
              searchText.toLowerCase(),
            );
      }).toList();
    }

    return filtered;
  }

  Widget filterButton(String text, TodoFilter filter) {
    final bool isSelected = selectedFilter == filter;

    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected ? sageGreen : cardColor,
          foregroundColor:
              isSelected ? Colors.white : sageGreen,
          elevation: isSelected ? 3 : 0,
          padding: const EdgeInsets.symmetric(
            vertical: 18,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: sageGreen.withOpacity(0.35),
            ),
          ),
        ),
        onPressed: () {
          setState(() {
            selectedFilter = filter;
          });
        },
        child: Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Color getCategoryColor(String category) {
    if (category == 'School') {
      return Colors.blueAccent;
    } else if (category == 'Work') {
      return Colors.orangeAccent;
    } else {
      return sageGreen;
    }
  }

  void selectAll(List<Todo> todos) {
    setState(() {
      selectedTodoIds =
          todos.map((todo) => todo.id).toSet();
    });

    showSnackMessage('All tasks selected');
  }

  void clearSelection() {
    setState(() {
      selectedTodoIds.clear();
    });
  }

  void deleteSelectedTodos() {
    if (selectedTodoIds.isEmpty) {
      showSnackMessage('No tasks selected');
      return;
    }

    for (final id in selectedTodoIds.toList()) {
      context.read<TodoCubit>().deleteTodo(id);
    }

    setState(() {
      selectedTodoIds.clear();
    });

    showSnackMessage(
      'Selected tasks deleted successfully',
      isDelete: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      floatingActionButton: FloatingActionButton(
        backgroundColor: sageGreen,
        foregroundColor: Colors.white,
        elevation: 8,
        onPressed: () {
          showTodoDialog();
        },
        child: const Icon(Icons.add, size: 32),
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 30,
            ),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 24,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        color: isDarkMode
                            ? Colors.white
                            : darkSage,
                      ),
                      onPressed: () {
                        setState(() {
                          isDarkMode = !isDarkMode;
                        });
                      },
                    ),
                  ),
                ),

                Text(
                  'Agenda',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? Colors.white
                        : darkSage,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Let's get it done !!",
                  style: GoogleFonts.poppins(
                    color: subtitleColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              24,
              28,
              24,
              12,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: searchController,
                    style: TextStyle(color: textColor),
                    onChanged: (value) {
                      setState(() {
                        searchText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      hintStyle:
                          TextStyle(color: subtitleColor),
                      prefixIcon: Icon(
                        Icons.search,
                        color: sageGreen,
                      ),
                      filled: true,
                      fillColor: cardColor,
                      contentPadding:
                          const EdgeInsets.symmetric(
                        vertical: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      filterButton(
                        'All',
                        TodoFilter.all,
                      ),

                      const SizedBox(width: 10),

                      filterButton(
                        'Pending',
                        TodoFilter.pending,
                      ),

                      const SizedBox(width: 10),

                      filterButton(
                        'Completed',
                        TodoFilter.completed,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 8,
            ),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    final state =
                        context.read<TodoCubit>().state;

                    if (state is TodoLoaded) {
                      selectAll(
                        getFilteredTodos(state.todos),
                      );
                    }
                  },
                  icon: const Icon(Icons.done_all),
                  label: const Text('Select All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sageGreen,
                    foregroundColor: Colors.white,
                  ),
                ),

                const SizedBox(width: 12),

                ElevatedButton.icon(
                  onPressed: deleteSelectedTodos,
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('Delete Selected'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                ),

                const SizedBox(width: 12),

                TextButton(
                  onPressed: clearSelection,
                  child: Text(
                    'Clear Selection',
                    style: TextStyle(color: sageGreen),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: BlocBuilder<TodoCubit, TodoState>(
              builder: (context, state) {
                if (state is TodoLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: sageGreen,
                    ),
                  );
                }

                if (state is TodoError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: TextStyle(color: textColor),
                    ),
                  );
                }

                if (state is TodoLoaded) {
                  final filteredTodos =
                      getFilteredTodos(state.todos);

                  if (filteredTodos.isEmpty) {
                    return Center(
                      child: Text(
                        'No tasks found',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      24,
                      0,
                      24,
                      90,
                    ),
                    itemCount: filteredTodos.length,
                    itemBuilder: (context, index) {
                      final todo = filteredTodos[index];

                      final bool isSelected =
                          selectedTodoIds.contains(
                        todo.id,
                      );

                      return Container(
                        margin:
                            const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? sageGreen.withOpacity(0.18)
                              : cardColor,
                          borderRadius:
                              BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? sageGreen
                                : sageGreen.withOpacity(
                                    0.15,
                                  ),
                          ),
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          onLongPress: () {
                            setState(() {
                              if (isSelected) {
                                selectedTodoIds
                                    .remove(todo.id);
                              } else {
                                selectedTodoIds
                                    .add(todo.id);
                              }
                            });
                          },
                          leading: Checkbox(
                            value: todo.completed,
                            activeColor: sageGreen,
                            onChanged: (value) {
                              context
                                  .read<TodoCubit>()
                                  .updateTodo(
                                    todo.id,
                                    todo.title,
                                    value ?? false,
                                    todo.category,
                                  );

                              showSnackMessage(
                                'Task updated successfully',
                              );
                            },
                          ),
                          title: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                todo.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  decoration:
                                      todo.completed
                                          ? TextDecoration
                                              .lineThrough
                                          : null,
                                  color: todo.completed
                                      ? subtitleColor
                                      : textColor,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: getCategoryColor(
                                    todo.category,
                                  ).withOpacity(0.15),
                                  borderRadius:
                                      BorderRadius.circular(
                                    20,
                                  ),
                                ),
                                child: Text(
                                  todo.category,
                                  style: TextStyle(
                                    color:
                                        getCategoryColor(
                                      todo.category,
                                    ),
                                    fontSize: 12,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: isSelected,
                                activeColor: sageGreen,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedTodoIds
                                          .add(todo.id);
                                    } else {
                                      selectedTodoIds
                                          .remove(todo.id);
                                    }
                                  });
                                },
                              ),

                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: sageGreen,
                                ),
                                onPressed: () {
                                  showTodoDialog(
                                    todo: todo,
                                  );
                                },
                              ),

                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  context
                                      .read<TodoCubit>()
                                      .deleteTodo(
                                        todo.id,
                                      );

                                  showSnackMessage(
                                    'Task deleted successfully',
                                    isDelete: true,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}