import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/todo.dart';

class ApiService {
  final String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Todo>> fetchTodos() async {
    final response = await http.get(Uri.parse('$baseUrl/todos'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Todo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load todos');
    }
  }

  Future<Todo> createTodo({
    required String title,
    required bool completed,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/todos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': 1, 'title': title, 'completed': completed}),
    );

    if (response.statusCode == 201) {
      return Todo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create todo');
    }
  }

  Future<Todo> updateTodo({
    required int id,
    required String title,
    required bool completed,
  }) async {
    final requestBody = jsonEncode({
      'id': id,
      'userId': 1,
      'title': title,
      'completed': completed,
    });

    debugPrint('PUT URL: $baseUrl/todos/$id');
    debugPrint('PUT BODY: $requestBody');
    final response = await http.put(
      Uri.parse('$baseUrl/todos/$id'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      return Todo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Failed to update todo. Status code: ${response.statusCode}. '
        'Response body: ${response.body}',
      );
    }
  }
}
