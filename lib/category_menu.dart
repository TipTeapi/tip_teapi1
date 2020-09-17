import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tip_teapi/helpers/dialog_helper.dart';
import 'package:tip_teapi/play_page.dart';

List<String> catList = [];

class Category extends StatefulWidget {
  @override
  _CategoryState createState() => _CategoryState();
}

class UserCategoryData {
  List<String> dataList;

  UserCategoryData({this.dataList});
}

class _CategoryState extends State<Category> {
  UserCategoryData data = UserCategoryData();

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
    {"cat": "DIY", "selected": false},
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black12,
        appBar: new AppBar(
          title: Center(
            child: new Text(
              'Select Your Category',
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          backgroundColor: Colors.black,
        ),
        body: Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/category1.jpg"),
                fit: BoxFit.cover),
          ),
          child: GridView.builder(
            itemCount: 12,
            itemBuilder: (BuildContext context, int index) => GestureDetector(
              onTap: () {
                setState(() {
                  category[index]['selected'] = !category[index]['selected'];
                });

                if (category[index]['selected']) {
                  catList.add(category[index]['cat']);
                } else {
                  if (catList.contains(category[index]['cat'])) {
                    catList.remove(category[index]['cat']);
                  }
                }
                data.dataList = catList;
                print(catList);
                // print(data);
              },
              child: Card(
                margin: EdgeInsets.all(15.0),
                child: getCardCategory(category[index]['cat']),
                shape: RoundedRectangleBorder(
                  side: category[index]['selected']
                      ? BorderSide(width: 3, color: Colors.greenAccent[700])
                      : BorderSide(width: 3, color: Colors.white),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                color: category[index]['selected']
                    ? Colors.grey[300]
                    : Colors.white,
              ),
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 1.0),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          child: Icon(
            FontAwesomeIcons.arrowAltCircleRight,
            size: 50.0,
            color: Colors.white,
          ),
          onPressed: () {
            if (catList.isNotEmpty == true) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => PlayPage(data: data)));
            } else {
              DialogHelper.exit(context);
            }
          },
        ),
      ),
    );
  }

  Column getCardCategory(String cat) {
    String icon = "";
    if (cat == "Funny") {
      icon = 'assets/images/funnyNw.png';
    } else if (cat == "Drama") {
      icon = 'assets/images/dramaNw.png';
    } else if (cat == "Music") {
      icon = 'assets/images/musicNw.png';
    } else if (cat == "Dance") {
      icon = 'assets/images/danceNw.png';
    } else if (cat == "Art") {
      icon = 'assets/images/artNw.png';
    } else if (cat == "Science and Education") {
      icon = 'assets/images/technologyNw.png';
    } else if (cat == "Beauty and Style") {
      icon = 'assets/images/beauty.png';
    } else if (cat == "Travel") {
      icon = 'assets/images/travel.png';
    } else if (cat == "Sports") {
      icon = 'assets/images/sports.png';
    } else if (cat == "Gamming") {
      icon = 'assets/images/gamming.png';
    } else if (cat == "Food") {
      icon = 'assets/images/food.png';
    } else {
      icon = 'assets/images/diy.png';
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Container(
            child: Stack(
              children: [
                Image.asset(
                  icon,
                  width: 80,
                  height: 80,
                ),
              ],
            ),
          ),
        ),
        // Text(cat,
        //     style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        //     textAlign: TextAlign.center),
      ],
    );
  }
}
