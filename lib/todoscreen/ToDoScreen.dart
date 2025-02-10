import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../model/todo.dart';
import 'AddToScreen.dart';
import 'ToDoDetailScreen.dart';

class TodoScreen extends StatelessWidget {
  final Box<Todo> todoBox = Hive.box<Todo>('todos');

  TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Заметки')),
      body: ValueListenableBuilder(
        valueListenable: todoBox.listenable(),
        builder: (context, Box<Todo> box, _) {
          if (box.isEmpty) {
            return Center(child: Text('Нет задач'));
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final todo = box.getAt(index);
              return Card(
                margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                color: Colors.grey[100],
                child: ListTile(
                  leading: Checkbox(
                    value: todo?.isDone ?? false,
                    onChanged: (value) {
                      if (todo != null) {
                        todoBox.putAt(index, Todo(title: todo.title, isDone: value ?? false));
                      }
                    },
                  ),
                  title: Text(
                    todo?.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      decoration: (todo?.isDone ?? false) ? TextDecoration.lineThrough : null,
                      color: (todo?.isDone ?? false) ? Colors.red : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => box.deleteAt(index),
                  ),
                  onTap: () {
                    if (todo != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TodoDetailScreen(todo: todo, index: index),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddTodoScreen()),
        ),
      ),
    );
  }
}