import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserProfile extends StatefulWidget {
  final User user;

  UserProfile({this.user});

  @override
  _UserProfileState createState() => _UserProfileState(user: user);
}

class _UserProfileState extends State<UserProfile> {
  final User user;
  _UserProfileState({this.user});

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = new GoogleSignIn();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: Image.asset('assets/User-Profile/icon-add-profile.png'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
          ),
          actions: <Widget>[
            RaisedButton(
              onPressed: () async {
                await _firebaseAuth.signOut().then((onValue) {
                  _googleSignIn.signOut();
                  Navigator.pop(context);
                });
              },
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              elevation: 0.0,
              padding: EdgeInsets.all(0.0),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.topRight,
                    colors: [Colors.white, Colors.white],
                  ),
                ),
                child: Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: user.displayName != null
            ? _userProfileGoogle(context)
            : _userProfilePhone(context),
      ),
    );
  }

  Widget _userProfileGoogle(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Container(
            child: Container(
              width: double.infinity,
              height: 350.0,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: NetworkImage(user.photoURL),
                      radius: 40.0,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      user.displayName,
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                        // fontFamily: 'Poppins-Regular.ttf',
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                        //margin: EdgeInsets.symmetric(
                        // horizontal: 20.0, vertical: 8.0),
                        // clipBehavior: Clip.antiAlias,
                        // color: Colors.white,
                        //  elevation: 8.0,

                        child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 22.0, horizontal: 8.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Image.asset(
                                    'assets/User-Profile/icon-following.png'),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  '0',
                                  style: TextStyle(
                                    //fontFamily: 'Poppins-Regular.ttf',
                                    color: Colors.black,
                                    fontSize: 20.0,
                                  ),
                                ),
                                Text(
                                  'Following',
                                  style: TextStyle(
                                    //fontFamily: 'Poppins-Regular.ttf',
                                    color: Colors.black,
                                    fontSize: 20.0,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Image.asset(
                                    'assets/User-Profile/icon-followers.png'),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  '0',
                                  style: TextStyle(
                                    //fontFamily: 'Poppins-Regular.ttf',
                                    color: Colors.black,
                                    fontSize: 20.0,
                                  ),
                                ),
                                Text(
                                  'Followers',
                                  style: TextStyle(
                                    //fontFamily: 'Poppins-Regular',
                                    color: Colors.black,
                                    fontSize: 20.0,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Image.asset(
                                    'assets/User-Profile/icon-like-circle.png'),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  '0',
                                  style: TextStyle(
                                    //fontFamily: 'Poppins-Regular.ttf',
                                    color: Colors.black,
                                    fontSize: 20.0,
                                  ),
                                ),
                                Text(
                                  'Likes',
                                  style: TextStyle(
                                    //fontFamily: 'Poppins-Regular.ttf',
                                    color: Colors.black,
                                    fontSize: 20.0,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RaisedButton(
                            onPressed: () {},
                            child: Text(
                              'Edit Profile',
                              style: TextStyle(
                                //fontFamily: 'Poppins-Regular.ttf',
                                fontSize: 20.0,
                              ),
                            ),
                            color: Colors.white,
                            textColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0),
                                side: BorderSide(color: Colors.grey, width: 0)),
                          ),
                        ),
                      ],
                    )),
                  ],
                ),
              ),
            ),
          ),
          Container(
              height: 20,
              decoration: BoxDecoration(),
              child: Row(children: <Widget>[
                Expanded(
                    child: Image.asset(
                        'assets/User-Profile/icon-post-hover@2x.png')),
                SizedBox(
                  height: 20.0,
                ),
                Expanded(
                    child: Image.asset(
                        'assets/User-Profile/icon-like-small-hover@2x.png')),
                SizedBox(
                  height: 20.0,
                ),
                Expanded(
                    child: Image.asset(
                        'assets/User-Profile/icon-lock-hover@2x.png')),
              ])),
        ],
      ),
    );
  }

  Widget _userProfilePhone(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Container(
            child: Container(
              width: double.infinity,
              height: 350.0,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage:
                          AssetImage('assets/Home/icon-profile-hover@3x.png'),
                      radius: 50.0,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      user.phoneNumber,
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                        //margin: EdgeInsets.symmetric(
                        // horizontal: 20.0, vertical: 8.0),
                        // clipBehavior: Clip.antiAlias,
                        // color: Colors.white,
                        //  elevation: 8.0,

                        child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 22.0, horizontal: 8.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Image.asset(
                                    'assets/User-Profile/icon-following.png'),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  '0',
                                  style: TextStyle(
                                    //fontFamily: 'Poppins-Regular.ttf',
                                    color: Colors.black,
                                    fontSize: 20.0,
                                  ),
                                ),
                                Text(
                                  'Following',
                                  style: TextStyle(
                                    //fontFamily: 'Poppins-Regular.ttf',
                                    color: Colors.black,
                                    fontSize: 20.0,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Image.asset(
                                    'assets/User-Profile/icon-followers.png'),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  '0',
                                  style: TextStyle(
                                    //fontFamily: 'Poppins-Regular.ttf',
                                    color: Colors.black,
                                    fontSize: 20.0,
                                  ),
                                ),
                                Text(
                                  'Followers',
                                  style: TextStyle(
                                    //fontFamily: 'Poppins-Regular',
                                    color: Colors.black,
                                    fontSize: 20.0,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Image.asset(
                                    'assets/User-Profile/icon-like-circle.png'),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  '0',
                                  style: TextStyle(
                                    //fontFamily: 'Poppins-Regular.ttf',
                                    color: Colors.black,
                                    fontSize: 20.0,
                                  ),
                                ),
                                Text(
                                  'Likes',
                                  style: TextStyle(
                                    //fontFamily: 'Poppins-Regular.ttf',
                                    color: Colors.black,
                                    fontSize: 20.0,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                          onPressed: () {},
                          child: Text(
                            'Edit Profile',
                            style: TextStyle(
                              //fontFamily: 'Poppins-Regular.ttf',
                              fontSize: 20.0,
                            ),
                          ),
                          color: Colors.white,
                          textColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                              side: BorderSide(color: Colors.grey, width: 0)),
                        ),
                      ],
                    )),
                  ],
                ),
              ),
            ),
          ),
          Container(
              height: 20,
              decoration: BoxDecoration(),
              child: Row(children: <Widget>[
                Expanded(
                    child: Image.asset(
                        'assets/User-Profile/icon-post-hover@2x.png')),
                SizedBox(
                  height: 20.0,
                ),
                Expanded(
                    child: Image.asset(
                        'assets/User-Profile/icon-like-small-hover@2x.png')),
                SizedBox(
                  height: 20.0,
                ),
                Expanded(
                    child: Image.asset(
                        'assets/User-Profile/icon-lock-hover@2x.png')),
              ])),
        ],
      ),
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut().then((onValue) {
      _googleSignIn.signOut();
      Navigator.pop(context);
    });
  }
}
