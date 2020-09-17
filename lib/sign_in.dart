import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import './phone_auth.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = new GoogleSignIn();
  User user;
  bool checked = false;

  Future<void> handleSignIn() async {
    final GoogleSignInAccount _googleUser = await _googleSignIn.signIn();

    final GoogleSignInAuthentication googleAuth =
        await _googleUser.authentication;

    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    final UserCredential result =
        (await _firebaseAuth.signInWithCredential(credential));

    user = result.user;

    if (user != null) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black12,
        body: Builder(
          builder: (context) => Stack(
            fit: StackFit.expand,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Image.asset('assets/images/signBack.jpg',
                    fit: BoxFit.fill,
                    color: Color.fromRGBO(255, 255, 255, 0.6),
                    colorBlendMode: BlendMode.modulate),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 250.0,
                    child: Align(
                      alignment: Alignment.center,
                      child: Icon(
                        FontAwesomeIcons.user,
                        size: 90.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40.0,
                  ),
                  Container(
                    width: 250.0,
                    child: Align(
                      alignment: Alignment.center,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        color: Color(0xffffffff),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ImageIcon(
                              AssetImage('assets/images/google_logo.png'),
                            ),
                            // Icon(
                            //   FontAwesomeIcons.google,
                            //   color: Color(0xffCE107C),
                            // ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              'Sign In with Google',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {
                          if (checked != false) {
                            handleSignIn();
                          } else {
                            Fluttertoast.showToast(
                              msg: "Accept Terms & Conditions",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.grey[300],
                              textColor: Colors.black,
                              fontSize: 16.0,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    width: 250.0,
                    child: Align(
                      alignment: Alignment.center,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        color: Color(0xffffffff),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              FontAwesomeIcons.mobile,
                              color: Colors.black,
                              size: 25.0,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              'Sign In With Phone Number',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13.0,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {
                          if (checked != false) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => PhoneSignUp()),
                            );
                          } else {
                            Fluttertoast.showToast(
                              msg: "Accept Terms & Conditions",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.grey[300],
                              textColor: Colors.black,
                              fontSize: 16.0,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   height: 15.0,
                  // ),
                  Container(
                    width: 250.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          //activeColor: Colors.white,
                          checkColor: Colors.white,
                          value: checked,
                          onChanged: (bool value) {
                            setState(() {
                              checked = value;
                            });
                          },
                        ),
                        Text(
                          "I Agree",
                          style: TextStyle(color: Colors.white, fontSize: 18.0),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 250.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        FlatButton(
                          onPressed: () {
                            // Navigator.of(context).push(MaterialPageRoute(
                            //     builder: (context) => MyCon()));
                          },
                          child: Text(
                            'Terms & Conditions',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
