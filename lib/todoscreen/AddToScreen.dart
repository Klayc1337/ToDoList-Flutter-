import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../model/todo.dart';

class AddTodoScreen extends StatefulWidget {
  AddTodoScreen({super.key});

  @override
  _AddTodoScreenState createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final TextEditingController controller = TextEditingController();
  final Box<Todo> todoBox = Hive.box<Todo>('todos');

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100), () {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Добавить задачу')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(labelText: 'Введите задачу'),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  todoBox.add(Todo(title: controller.text));
                  Navigator.pop(context);
                }
              },
              child: Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}