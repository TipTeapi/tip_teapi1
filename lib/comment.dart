import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class MyTextInput extends StatefulWidget {
  // This widget is the root of your application
  @override
  MyTextInputState createState() => new MyTextInputState();
}

class MyTextInputState extends State<MyTextInput> {
  final TextEditingController _controller = new TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  String url = 'http://api.teapai.in/api_putComment.php';
  Future<String> createPost() async {
    var response = await http.post(
      Uri.encodeFull(' http://api.teapai.in/api_putComment.php'),
      body: {
        "userId": "2",
        "assetId": "15",
        "type": "video",
        "comment": " nice video",
        "api_key":
            "6adca579a9111ab5af265be8ed52742797f5ae6e67eebcfc793449d63618e7e5"
      },
    );

    return response.body;
  }

  @override
  void initState() {
    //createPost();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Comments'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          new TextField(
              keyboardType: TextInputType.text,
              controller: _controller,
              decoration: new InputDecoration(hintText: 'Type your Comment')),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await createPost();
        },
        tooltip: 'Send',
        child: Icon(Icons.arrow_right),
      ),
    );
  }

  Widget getBody() {
    return ListView.builder(itemBuilder: (context, index) {
      return getCard();
    });
  }

  Widget getCard() {
    return Card(
      child: ListTile(
        title: Row(
          children: <Widget>[
            Container(
              width: 60,
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}
