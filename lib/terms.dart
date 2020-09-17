import 'package:flutter/material.dart';

void main() {
  runApp(new MaterialApp(
    home: new MyCon(),
  ));
}

class MyCon extends StatefulWidget {
  @override
  MyConState createState() => new MyConState();
}

class MyConState extends State<MyCon> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          title: new Text('Terms and Conditions'),
          backgroundColor: Colors.black,
        ),
        body: Center(
            child: Container(
          color: Colors.grey[300],
          padding: new EdgeInsets.all(32.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(
                'This is for the safety of users and viewers. Details of users such as photos and personal information shall be'
                ' secured and not accessible to anyone else . While uploading content one should not instinct violence against any creature, minor '
                ' or any living beings. Such videos will not be promoted.  Section 67A provides punishment for publishing or transmitting obsence '
                ' digital content containing sexual explicit acts. As per 67A of I.T. Act punishment on first conviction is imprisonment of a term which may extend'
                ' upto 10 lakhs.  ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        )));
  }
}
