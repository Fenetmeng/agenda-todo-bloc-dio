import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/todo_cubit.dart';
import 'screens/home_screen.dart';
import 'services/todo_api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TodoCubit(TodoApiService()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Todo Manager',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}