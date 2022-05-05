import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  void answerQuestion() {
    print("We response!");
  }

  @override
  Widget build(BuildContext context) {
    Person p = Person(name: "Juan");

    var questions = [
      "What is your favorite colot ?",
      "What is your favorite animal ?"
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Hi Dude"),
        ),
        body: SafeArea(
          child: Column(children: [
            Text('The question!'),
            RaisedButton(
              onPressed: answerQuestion,
              child: Text("Answer 1"),
            ),
            RaisedButton(
              onPressed: () {
                print("We response answer 2!");
              },
              child: Text("Answer 2"),
            ),
            RaisedButton(
              onPressed: null,
              child: Text("Answer 3"),
            ),
          ]),
        ),
      ),
    );
  }
}

class Person {
  String name;
  int age;

  Person({required this.name, this.age = 30});
}
