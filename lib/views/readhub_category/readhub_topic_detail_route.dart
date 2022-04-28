import 'package:flutter/material.dart';

/// 预留readhub topic 详情跳转为新的页面
///
class Todo {
  final String title;
  final String description;

  const Todo(this.title, this.description);
}

class ReadhubTopicDetailRoute extends StatelessWidget {
  // In the constructor, require a Todo.
  const ReadhubTopicDetailRoute({Key? key, required this.todo}) : super(key: key);

  // Declare a field that holds the Todo.
  final Todo todo;

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Scaffold(
      appBar: AppBar(
        title: Text(todo.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(todo.description),
      ),
    );
  }
}
