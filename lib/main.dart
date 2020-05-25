import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Startup Name Generator',
        theme: ThemeData(
          primaryColor: Colors.deepPurple,
        ),
        home: Todo());
  }
}

class TodoState extends State<Todo> {
  final List<TodoDetail> todoList = new List<TodoDetail>();
  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // loadData();
  }

  Future<void> loadData() async {
    var dataURL = 'https://jsonplaceholder.typicode.com/todos';
    var response = await http.get(dataURL);
    //Iterable response = convert.jsonDecode(response.body);
    List<TodoDetail> todos;
    todos = (convert.jsonDecode(response.body) as List)
        .map((i) => TodoDetail.fromJson(i))
        .toList();

    setState(() {
      todoList.addAll(todos);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Todo List'),
        ),
        body: Container(
            margin: const EdgeInsets.all(16),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _buildForm(),
                  Expanded(child: _buildTodoList())
                ])));
  }

  Widget _buildForm() {
    final _formKey = GlobalKey<FormState>();

    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: myController,
              decoration: const InputDecoration(hintText: 'Insert a todo...'),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please, enter a valid todo!';
                }
                return null;
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RaisedButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        TodoDetail newTodo = new TodoDetail();
                        newTodo.id =
                            todoList.length > 0 ? todoList.last.id + 1 : 1;
                        newTodo.title = myController.text;
                        newTodo.userId = 1;
                        newTodo.completed = false;

                        setState(() {
                          todoList.add(newTodo);
                        });
                      }
                    },
                    child: Text('Add')),
                RaisedButton(
                    onPressed: () {
                      // loadData(); To retrieve from WS
                      setState(() {
                        todoList.clear();
                      });
                    },
                    child: Text('Clear'))
              ],
            ),
          ],
        ));
  }

  Widget _buildTodoList() {
    return ListView.separated(
        itemCount: todoList.length,
        itemBuilder: (context, i) {
          return _buildRow(todoList[i]);
        },
        separatorBuilder: (BuildContext context, int index) => const Divider());
  }

  Widget _buildRow(TodoDetail todo) {
    return ListTile(
      leading: todo.completed
          ? IconButton(
              icon: Icon(Icons.close),
              color: Colors.red,
              onPressed: () {
                setState(() {
                  todo.completed = false;
                });
              },
            )
          : IconButton(
              icon: Icon(Icons.done),
              color: Colors.green,
              onPressed: () {
                setState(() {
                  todo.completed = true;
                });
              },
            ),
      title: Text(todo.title,
          style: todo.completed
              ? TextStyle(
                  decoration: TextDecoration.lineThrough, color: Colors.grey)
              : null),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        color: Colors.grey[300],
        onPressed: () {
          setState(() {
            todoList.remove(todo);
          });
        },
      ),
    );
  }
}

class Todo extends StatefulWidget {
  @override
  TodoState createState() => TodoState();
}

class TodoDetail {
  int id;
  int userId;
  String title;
  bool completed;

  static TodoDetail fromJson(json) {
    TodoDetail todo = new TodoDetail();
    todo.title = json['title'];
    todo.id = json['id'];
    todo.userId = json['userId'];
    todo.completed = json['completed'];
    return todo;
  }
}
