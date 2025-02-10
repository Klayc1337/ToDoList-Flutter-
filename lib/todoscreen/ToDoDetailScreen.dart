import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../model/todo.dart';

class TodoDetailScreen extends StatefulWidget {
  final Todo todo;
  final int index;

  TodoDetailScreen({required this.todo, required this.index, super.key});

  @override
  _TodoDetailScreenState createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  late TextEditingController _controller;
  late Box<Todo> todoBox;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.todo.title);
    todoBox = Hive.box<Todo>('todos');
  }

  void _saveChanges() {
    if (_controller.text.isNotEmpty) {
      todoBox.putAt(widget.index, Todo(title: _controller.text, isDone: widget.todo.isDone));
      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Детали задачи'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _isEditing
            ? TextField(
                controller: _controller,
                decoration: InputDecoration(labelText: 'Введите задачу'),
                maxLines: null,
              )
            : Text(
                widget.todo.title,
                style: TextStyle(fontSize: 18),
              ),
      ),
      floatingActionButton: _isEditing
          ? FloatingActionButton(
              onPressed: _saveChanges,
              child: Icon(Icons.save),
              tooltip: 'Сохранить',
            )
          : null,
    );
  }
}