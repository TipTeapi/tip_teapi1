import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import './play_page.dart';

class PhoneSignUp extends StatefulWidget {
  @override
  _PhoneSignUpState createState() => _PhoneSignUpState();
}

class _PhoneSignUpState extends State<PhoneSignUp> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> loginUser(phone, context) async {
    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential phoneCredential) async {
          Navigator.of(context).pop();
          await _auth
              .signInWithCredential(phoneCredential)
              .then((UserCredential result) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => PlayPage()));
          }).catchError((e) {
            print("Error");
          });
        },
        verificationFailed: (FirebaseAuthException exception) {
          print(exception);
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: Text("Enter OTP Here"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: _codeController,
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Confirm"),
                      textColor: Colors.white,
                      color: Colors.blue,
                      onPressed: () async {
                        final code = _codeController.text.trim();
                        print(code);
                        var credential = PhoneAuthProvider.credential(
                            verificationId: verificationId, smsCode: code);

                        await _auth
                            .signInWithCredential(credential)
                            .then((UserCredential result) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PlayPage()));
                        }).catchError((e) {
                          print("Error");
                        });
                      },
                    )
                  ],
                );
              });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationId = verificationId;
          print(verificationId);
          print("Timout");
        });
  }

  @override
  void initState() {
    super.initState();

    // FirebaseAuth.instance.authStateChanges().listen((user) {
    //   if (user != null) {
    //     Navigator.push(
    //         context, MaterialPageRoute(builder: (context) => MyApp()));
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          backgroundColor: Colors.black12,
          body: Center(
            child: Container(
              padding: EdgeInsets.all(32.0),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                            borderSide: BorderSide(color: Colors.grey[200])),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                            borderSide: BorderSide(color: Colors.grey[300])),
                        filled: true,
                        fillColor: Colors.grey[100],
                        hintText: "Mobile Number",
                      ),
                      controller: _phoneController,
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      width: double.infinity,
                      child: FlatButton(
                        child: Icon(
                          FontAwesomeIcons.locationArrow,
                          color: Colors.black,
                          size: 35.0,
                        ),
                        textColor: Colors.black,
                        padding: EdgeInsets.all(16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        onPressed: () {
                          final phone = _phoneController.text.trim();
                          //print(phone);
                          loginUser(phone, context);
                        },
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
