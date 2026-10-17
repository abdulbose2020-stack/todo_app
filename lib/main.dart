import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'models/todo.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<List<Todo>> _todosFuture;
  @override
  void initState() {
    super.initState();
    _todosFuture = ApiService().fetchTodos();
  }
  final TextEditingController _titleController = TextEditingController();

  final List<Todo> _createdTodos = [];
    final Map<int, Todo> _updatedTodos = {};

  Future<void> _addTodo() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final todo = await ApiService().createTodo(
      title: title,
      completed: false,
    );
    setState(() {
      _createdTodos.add(todo);
      _titleController.clear();
    });
  }

  Future<void> _editTodo(Todo todo) async {
  String newTitle = todo.title;

  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Edit Todo'),
      content: TextFormField(
        initialValue: todo.title,
        autofocus: true,
        onChanged: (value) {
          newTitle = value;
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext, newTitle.trim());
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );

  if (result == null || result.isEmpty) return;

  try {
    final updatedTodo = await ApiService().updateTodo(
      id: todo.id,
      title: result,
      completed: todo.completed,
    );

    if (!mounted) return;

    setState(() {
      _updatedTodos[todo.id] = updatedTodo;
    });
  } catch (error) {
  debugPrint('UPDATE TODO ERROR: $error');

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Failed to update todo: $error'),
      duration: const Duration(seconds: 10),
    ),
  );
}
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Enter new todo',
              ),
            ),
          ),

          ElevatedButton(
            onPressed: _addTodo,
            child: const Text('Add Todo'),
          ),
          Expanded(
            child: FutureBuilder(
              future: _todosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
            
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
            
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No todos found.'),
                  );
                }
            
                final allTodos = [
                  ..._createdTodos.reversed,
                  ...snapshot.data!,
                ];

                final todos = allTodos.map((todo) {
                  return _updatedTodos[todo.id] ?? todo;
                }).toList();
            
                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
            
                    return ListTile(
                      title: Text(todo.title),
                      leading: Text('${todo.id}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _editTodo(todo),
                            icon: const Icon(Icons.edit),
                          ),
                          Icon(
                            todo.completed
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: todo.completed ? Colors.green : Colors.grey,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 