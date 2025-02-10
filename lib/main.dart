import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'main.g.dart';

@HiveType(typeId: 0)
class Todo {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isDone;

  Todo({required this.title, this.isDone = false});
}

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TodoAdapter());
  await Hive.openBox<Todo>('todos');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Заметки',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TodoScreen(),
    );
  }
}

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
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddTodoScreen()),
        ),
      ),
    );
  }
}

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
