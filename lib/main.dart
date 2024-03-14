import 'package:flutter/material.dart';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => TodoListScreen(),
        '/add': (context) => AddEditTodoScreen(),
      },
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<TodoItem> _todoItems = [];

  void _addTodoItem(String task) {
    setState(() {
      _todoItems.add(TodoItem(task));
    });
    _showSnackBar('Task added successfully!');
  }

  void _editTodoItem(int index, String newTask) {
    setState(() {
      _todoItems[index].task = newTask;
    });
    _showSnackBar('Task updated successfully!');
  }

  void _removeTodoItem(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this task?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _todoItems.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _toggleTodoItemCompletion(int index) {
    setState(() {
      _todoItems[index].isCompleted = !_todoItems[index].isCompleted;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Todo List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
      ),
      body: _todoItems.isEmpty
          ? Center(
              child: Text(
                'No tasks yet',
                style: TextStyle(fontSize: 18.0),
              ),
            )
          : ListView.builder(
              itemCount: _todoItems.length,
              itemBuilder: (BuildContext context, int index) {
                final todoItem = _todoItems[index];
                return Card(
                  elevation: 4.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  color: todoItem.isCompleted ? Colors.grey.withOpacity(0.7) : Colors.white,
                  child: ListTile(
                    title: Text(
                      todoItem.task,
                      style: TextStyle(
                        fontSize: 18.0,
                        decoration: todoItem.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () async {
                            final editedTask = await Navigator.pushNamed(
                              context,
                              '/add',
                              arguments: todoItem.task,
                            );
                            if (editedTask != null && editedTask is String) {
                              _editTodoItem(index, editedTask);
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _removeTodoItem(index),
                        ),
                        Checkbox(
                          value: todoItem.isCompleted,
                          onChanged: (value) => _toggleTodoItemCompletion(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.pushNamed(context, '/add');
          if (newTask != null && newTask is String) {
            _addTodoItem(newTask);
          }
        },
        tooltip: 'Add task',
        child: Icon(Icons.add),
      ),
    );
  }
}

class TodoItem {
  String task;
  bool isCompleted;

  TodoItem(this.task, {this.isCompleted = false});
}

class AddEditTodoScreen extends StatelessWidget {
  final String? initialTask;

  const AddEditTodoScreen({Key? key, this.initialTask}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController(text: initialTask ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          initialTask != null ? 'Edit Todo' : 'Add Todo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter task',
                border: OutlineInputBorder(),
              ),
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _controller.text);
              },
              child: Text(
                'Save',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
