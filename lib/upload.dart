import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';

class Upload extends StatefulWidget {
  @override
  UploadState createState() => new UploadState();
}

class UploadState extends State<Upload> {
  final picker = ImagePicker();
  String userCat;
  var _currentItemSelected = 'Choose A Category';
  User firebaseUser;
  var msgShow;
  uploadVideo(String filename, String url) async {
    const api_key =
        '6adca579a9111ab5af265be8ed52742797f5ae6e67eebcfc793449d63618e7e5';

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['api_key'] = '$api_key';
    request.fields['category'] = '$_currentItemSelected';
    request.fields['userId'] = firebaseUser.displayName;
    request.fields['place'] = 'Jorhat';
    request.files
        .add(await http.MultipartFile.fromPath('assetVideo', filename));
    var res = await request.send();
    final streamRes = await res.stream.bytesToString();
    final apiResponse = jsonDecode(streamRes);
    return apiResponse['message'];
  }

  var _categories = [
    'Choose A Category',
    'Funny',
    'Drama',
    'Music',
    'Dance',
    'Art',
    'Science and Education',
    'Food',
    'Travel',
    'Beauty',
    'Sports',
    'Craft',
    'Game'
  ];

  Future<void> showSelectDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Choose One!",
              style: TextStyle(
                color: Colors.amber[100],
              ),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.purpleAccent,
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  GestureDetector(
                    child: Icon(FontAwesomeIcons.video,
                        size: 35.0, color: Colors.amber[50]),
                    onTap: () async {
                      const url = 'http://api.teapai.in/api_putVideo.php';
                      var file = await picker.getVideo(
                          source: ImageSource.camera,
                          maxDuration: const Duration(
                            seconds: 30,
                          ));
                      if (file != null) {
                        msgShow = await uploadVideo(file.path, url);
                      }

                      if (msgShow != null) {
                        Fluttertoast.showToast(
                          msg: msgShow,
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.deepPurple[400],
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                  ),
                  GestureDetector(
                    child: Icon(FontAwesomeIcons.photoVideo,
                        size: 35.0, color: Colors.amber[50]),
                    onTap: () async {
                      File file;
                      const url = 'http://api.teapai.in/api_putVideo.php';
                      FilePickerResult result = await FilePicker.platform
                          .pickFiles(type: FileType.custom, allowedExtensions: [
                        'mp4',
                        'avi',
                        'mov',
                        'flv',
                        'wmv',
                      ]);
                      if (result != null) {
                        file = File(result.files.single.path);
                        msgShow = await uploadVideo(file.path, url);
                      }

                      //print(file.path);
                      if (msgShow != null) {
                        Fluttertoast.showToast(
                          msg: msgShow,
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.deepPurple,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      firebaseUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          height: 350,
          width: 350,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.purpleAccent, Colors.deepPurple[100]])),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'UPLOAD YOUR VIDEO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.0,
                ),
              ),
              SizedBox(height: 100),
              FlatButton(
                onPressed: () async {
                  if (_currentItemSelected != 'Choose A Category') {
                    showSelectDialog(context);
                  } else {
                    Fluttertoast.showToast(
                      msg: "Select A Category!!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      fontSize: 16.0,
                    );
                  }
                },
                child: Text(
                  'Click Here',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                ),
              ),
              DropdownButton<String>(
                dropdownColor: Colors.white,
                items: _categories.map(
                  (String dropDownStringitem) {
                    return DropdownMenuItem<String>(
                      value: dropDownStringitem,
                      child: Text(
                        dropDownStringitem,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    );
                  },
                ).toList(),
                onChanged: (String newValueSelected) {
                  setState(
                    () {
                      this._currentItemSelected = newValueSelected;
                    },
                  );
                },
                value: _currentItemSelected,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.exclamationCircle,
                    color: Colors.lime[400],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 5.0),
                  ),
                  Text(
                    'Only mp4,avi,mov,flv,wmv Formats Allowed',
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
