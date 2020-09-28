import 'package:flutter/material.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tip_teapi/helpers/dialog_helper.dart';
import './play_pageNw.dart';
import 'package:fluttertoast/fluttertoast.dart';

List<String> catList = [];

class Category extends StatefulWidget {
  @override
  _CategoryState createState() => _CategoryState();
}

class UserSelCategoryData {
  List<String> dataList;

  UserSelCategoryData({this.dataList});
}

class _CategoryState extends State<Category> {
  UserSelCategoryData data = UserSelCategoryData();

  List<Map> category = [
    {"cat": "Funny", "selected": false},
    {"cat": "Drama", "selected": false},
    {"cat": "Music", "selected": false},
    {"cat": "Dance", "selected": false},
    {"cat": "Art", "selected": false},
    {"cat": "Science and Education", "selected": false},
    {"cat": "Beauty and Style", "selected": false},
    {"cat": "Travel", "selected": false},
    {"cat": "Sports", "selected": false},
    {"cat": "Gamming", "selected": false},
    {"cat": "Food", "selected": false},
    {"cat": "Craft", "selected": false},
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        //backgroundColor: Colors.black12,
        body: SafeArea(
          child: Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.purple[50], Colors.deepPurple[100]],
              ),
            ),
            child: Wrap(
              children: [
                Container(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50.0, left: 35.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello,',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          'Select Category',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: GridView.builder(
                    itemCount: 12,
                    controller: new ScrollController(keepScrollOffset: false),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext context, int index) =>
                        GestureDetector(
                      onTap: () {
                        setState(() {
                          category[index]['selected'] =
                              !category[index]['selected'];
                        });

                        if (category[index]['selected']) {
                          catList.add(category[index]['cat']);
                          Fluttertoast.showToast(
                            msg: category[index]['cat'],
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            backgroundColor: Colors.deepPurple[300],
                            textColor: Colors.purple[50],
                            fontSize: 16.0,
                          );
                        } else {
                          if (catList.contains(category[index]['cat'])) {
                            catList.remove(category[index]['cat']);
                          }
                        }
                        data.dataList = catList;
                        print(catList);
                        // print(data);
                      },
                      child: Container(
                        //margin: EdgeInsets.all(15.0),
                        child: getCardCategory(category[index]['cat'],
                            category[index]['selected']),
                      ),
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.transparent,
          child: Image.asset('assets/Category/send-btn@3x.png'),
          onPressed: () {
            if (catList.isNotEmpty == true) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => PlayPage(
                            data: data,
                          )));
            } else {
              DialogHelper.exit(context);
            }
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Column getCardCategory(String cat, bool selected) {
    String icon = "";

    if (cat == "Funny") {
      if (selected == false) {
        icon = 'assets/Category/icon-funny-normal@3x.png';
      } else {
        icon = 'assets/Category/icon-funny-hover@3x.png';
      }
    } else if (cat == "Drama") {
      if (selected == false) {
        icon = 'assets/Category/icon-drama-normal@3x.png';
      } else {
        icon = 'assets/Category/icon-drama-hover@3x.png';
      }
    } else if (cat == "Music") {
      if (selected == false) {
        icon = 'assets/Category/icon-music-normal@3x.png';
      } else {
        icon = 'assets/Category/icon-music-hover@3x.png';
      }
    } else if (cat == "Dance") {
      if (selected == false) {
        icon = 'assets/Category/icon-dance-normal@3x.png';
      } else {
        icon = 'assets/Category/icon-dance-hover@3x.png';
      }
    } else if (cat == "Art") {
      if (selected == false) {
        icon = 'assets/Category/icon-art-normal@3x.png';
      } else {
        icon = 'assets/Category/icon-art-hover@3x.png';
      }
    } else if (cat == "Science and Education") {
      if (selected == false) {
        icon = 'assets/Category/icon-science-tech-normal@3x.png';
      } else {
        icon = 'assets/Category/icon-science-tech-hover@3x.png';
      }
    } else if (cat == "Beauty and Style") {
      if (selected == false) {
        icon = 'assets/Category/icon-beauty-normal@3x.png';
      } else {
        icon = 'assets/Category/icon-beauty-hover@3x.png';
      }
    } else if (cat == "Travel") {
      if (selected == false) {
        icon = 'assets/Category/icon-travel-normal@3x.png';
      } else {
        icon = 'assets/Category/icon-travel-hover@3x.png';
      }
    } else if (cat == "Sports") {
      if (selected == false) {
        icon = 'assets/Category/icon-sports-normal@3x.png';
      } else {
        icon = 'assets/Category/icon-sports-hover@3x.png';
      }
    } else if (cat == "Gamming") {
      if (selected == false) {
        icon = 'assets/Category/icon-game-normal@3x.png';
      } else {
        icon = 'assets/Category/icon-game-hover@3x.png';
      }
    } else if (cat == "Food") {
      if (selected == false) {
        icon = 'assets/Category/icon-dining-normal@3x.png';
      } else {
        icon = 'assets/Category/icon-dining-hover@3x.png';
      }
    } else {
      if (selected == false) {
        icon = 'assets/Category/icon-craft-normal@3x.png';
      } else {
        icon = 'assets/Category/icon-craft-hover@3x.png';
      }
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Container(
            child: Wrap(
              direction: Axis.horizontal,
              //spacing: 30.0,
              children: [
                Image.asset(
                  icon,
                  width: 130,
                  height: 130,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
