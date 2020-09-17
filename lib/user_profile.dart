import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
        backgroundColor: Colors.black12,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // CircleAvatar(
              //   backgroundImage: NetworkImage(user.photoURL),
              //   radius: 20.0,
              // ),
              // Text(
              //   user.displayName,
              //   style: TextStyle(color: Colors.white, fontSize: 18.0),
              // ),
              RaisedButton(
                child: Text(
                  "Sign Out",
                  style: TextStyle(
                    fontSize: 10.0,
                  ),
                ),
                onPressed: signOut,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> signOut() async {
    SharedPreferences userR = await SharedPreferences.getInstance();
    userR.remove("user_id");
    await _firebaseAuth.signOut().then((onValue) {
      _googleSignIn.signOut();
      Navigator.pop(context);
    });
  }
}
