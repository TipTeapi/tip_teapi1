import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:tip_teapi/play_page.dart';
import 'package:video_player/video_player.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import './VideoInfo.dart';
//import 'dart:math';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share/share.dart';
//import './categoryNw.dart';
import './user_profileNw.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import './phone_authNw.dart';
import './upload.dart';
import './terms.dart';

List userLikes = [];
List<dynamic> comments;
User googleUser;
var _playingIndex = 0;
var vidId;
String noOfLikes;
int _currentNav = 0;

List<VideoPlayerController> controllers = [];

final TextEditingController _commentController = new TextEditingController();

class PlayPage extends StatefulWidget {
  final List<VideoInfo> list;
  bool isPlaying = false;

  PlayPage({this.list});

  @override
  _PlayPageState createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> with WidgetsBindingObserver {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = new GoogleSignIn();
  User user;
  TextStyle defaultStyle = TextStyle(color: Colors.grey, fontSize: 15.0);
  TextStyle linkStyle = TextStyle(color: Colors.blue);

  //user google sign in
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

  //mapping controllers with videos
  Future<void> createControllers() async {
    print(widget.list.length);
    controllers = widget.list
        .map((e) => VideoPlayerController.network(e.assetVideo))
        .toList();

    initVideoPlayers(this.index);

    if (googleUser != null) {
      //getting likes
      getUserLike();
    }
  }

  //fetching user's like details
  Future<void> getUserLike() async {
    //api key
    String key =
        '6adca579a9111ab5af265be8ed52742797f5ae6e67eebcfc793449d63618e7e5';

    String userId;
    //print(googleUser);
    if (googleUser.displayName == null) {
      userId = googleUser.phoneNumber;
    } else {
      userId = googleUser.displayName;
    }

    //print(userId);

    //http request to fetch video data
    String url =
        "http://api.teapai.in/api_getLike.php?api_key=$key&userId=$userId&type=video";

    try {
      final response = await http.get(url);

      var jsonLike = jsonDecode(response.body);

      if (jsonLike.runtimeType == [].runtimeType) {
        var userLikeMap = jsonLike.map((ul) => LikeInfo(
            lileId: ul['l_id'],
            userId: ul['user_id'],
            assetId: ul['asset_id'],
            assetOwner: ul['asset_owner']));

        userLikes = userLikeMap.map((e) => e.assetId).toList();
      } else {
        print(response.body);
      }
    } catch (e) {
      debugPrint('error');
    }
  }

  Future<void> _initializeVideoPlayerFuture;
  int index = 0;

  initVideoPlayers(int index) {
    _initializeVideoPlayerFuture = controllers[index].initialize();
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      googleUser = user;
    });

    createControllers();

    //adding observer
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // controllers[index]?.dispose();
    // controllers[index]?.pause();
    controllers?.forEach((controller) => controller?.pause());
    controllers?.forEach((controller) => controller?.dispose());

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      print('foreground');

      FirebaseAuth.instance.authStateChanges().listen((User user) {
        googleUser = user;
      });
    }
  }

  void onPauseVideo() {
    if (widget.isPlaying) {
      controllers[index].pause();
      widget.isPlaying = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    //print('inside build');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[850],
        body: SafeArea(
          child: ListView.builder(
            itemCount: widget.list.length,
            itemBuilder: (BuildContext context, int index) {
              initVideoPlayers(index);
              _playingIndex = index;

              void onVideoTap() {
                if (!widget.isPlaying) {
                  controllers[index].play();
                  widget.isPlaying = true;
                } else {
                  controllers[index].pause();
                  widget.isPlaying = false;
                }
              }

              return Container(
                color: Colors.grey[400],
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => onVideoTap(),
                          child: Container(
                            child: FutureBuilder(
                              future: _initializeVideoPlayerFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return Center(
                                    child: Container(
                                      width: MediaQuery.of(context)
                                              .copyWith()
                                              .size
                                              .height /
                                          2,
                                      height: MediaQuery.of(context)
                                              .copyWith()
                                              .size
                                              .height /
                                          2,
                                      // Use the VideoPlayer widget to display the video.
                                      child: VideoPlayer(controllers[index]),
                                    ),
                                  );
                                } else {
                                  // If the VideoPlayerController is still initializing, show a
                                  // loading spinner.
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 200),
                                      child: SpinKitFadingCube(
                                        color: Colors.grey[800],
                                        size: 38.0,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    _sideNavigation(),
                  ],
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.grey[300],
          shape: CircularNotchedRectangle(),
          child: Container(
            height: 60,
            child: _getBottomBar(context),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (googleUser != null) {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => Upload()));
            } else {
              _showSignInModal(context);
            }
          },
          child: Image.asset('assets/Home/icon-tipteapi@2x.png'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _sideNavigation() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
            child: Container(
          width: 50,
          height: 50,
        )),
        // Expanded(child: Container()),
        Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                backgroundColor: Colors.transparent,
                child: Image.asset('assets/Home/icon-near-by-normal.png'),
                onPressed: () async {},
                heroTag: null,
              ),
              SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                backgroundColor: Colors.transparent,
                child: userLikes.contains(vidId)
                    ? Image.asset('assets/Home/icon-like-hover.png')
                    : Image.asset('assets/Home/icon-like-normal.png'),
                onPressed: () async {
                  if (googleUser != null) {
                    await likeVideo(_playingIndex);
                    setState(
                      () {
                        userLikes.add(vidId);

                        print(
                            widget.list[_playingIndex].no_of_likes.runtimeType);

                        if (widget.list[_playingIndex].no_of_likes.isEmpty) {
                          // Haven't liked yet

                          widget.list[_playingIndex].no_of_likes = "1";
                        } else {
                          // Can be converted into INteger

                          widget.list[_playingIndex].no_of_likes = (int.parse(
                                      widget.list[_playingIndex].no_of_likes) +
                                  1)
                              .toString();
                        }
                      },
                    );
                  } else {
                    _showSignInModal(context);
                  }
                },
                heroTag: null,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Container(
                  child: Text(
                    googleUser != null
                        ? widget.list[_playingIndex].no_of_likes
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                backgroundColor: Colors.transparent,
                child: Image.asset('assets/Home/icon-comment-normal.png'),
                onPressed: () async {
                  if (googleUser != null) {
                    getComment(_playingIndex)
                        .then((response) => showCommentBottomModal(context))
                        .catchError((e) {
                      print('Error');
                    });
                  } else {
                    _showSignInModal(context);
                  }
                },
                heroTag: null,
              ),
              SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                backgroundColor: Colors.transparent,
                child: Image.asset('assets/Home/icon-share-normal.png'),
                onPressed: () {
                  if (googleUser != null) {
                    _shareThisVideo(context, _playingIndex);
                  } else {
                    _showSignInModal(context);
                  }
                },
                heroTag: null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  //comment modal bottom sheet
  void showCommentBottomModal(context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Container(
            color: Colors.grey[850],
            height: MediaQuery.of(context).size.height * .80,
            child: Container(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        child: Image.asset(
                          'assets/Comments/comment-popup-header@3x.png',
                          width: MediaQuery.of(context).size.width,
                          repeat: ImageRepeat.repeat,
                        ),
                      ),
                      IconButton(
                        icon:
                            Image.asset('assets/Comments/close-btn-white.png'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  ),
                  commentsList(),
                  Padding(padding: EdgeInsets.all(2.0)),
                  commentPost(context)
                ],
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(27.0),
                  topRight: const Radius.circular(26.0),
                ),
              ),
            ),
          );
        });
  }

  Widget commentPost(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: TextFormField(
              autofocus: false,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(color: Colors.deepPurple[400]),
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    borderSide: BorderSide(color: Colors.deepPurple[400])),
                filled: true,
                fillColor: Colors.grey[300],
                hintText: "Write Your Comment...",
              ),
              controller: _commentController,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            FontAwesomeIcons.paperPlane,
            color: Colors.deepPurple[400],
            size: 35,
          ),
          onPressed: () async {
            var comment = _commentController.text.trim();
            await postComment(comment, _playingIndex);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget commentsList() {
    return Wrap(
      children: [
        Container(
          height: 390,
          child: ListView.builder(
            itemCount: (comments.length != null) ? comments.length : null,
            itemBuilder: (context, index) {
              return Card(
                //color: Colors.blueGrey[400],
                child: ListTile(
                  onTap: () {},
                  leading: Icon(
                    FontAwesomeIcons.userCircle,
                    size: 40,
                    color: Colors.deepPurple[400],
                  ),
                  title: Text(
                    comments[index]['user_id'],
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  subtitle: Text(
                    comments[index]['comment'],
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _shareThisVideo(BuildContext context, playingIndex) async {
    final RenderBox box = context.findRenderObject();
    String videoUrl = widget.list[playingIndex].assetVideo;
    await Share.share(videoUrl,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  //bottom nevigation bar
  _getBottomBar(BuildContext context) {
    return Row(
      children: [
        buildNavBarItem('assets/Home/icon-home-hover.png', 0),
        buildNavBarItem('assets/Home/icon-search-hover.png', 1),
        SizedBox.shrink(),
        buildNavBarItem('assets/Home/icon-help-hover.png', 2),
        buildNavBarItem('assets/Home/icon-profile-hover.png', 3),
      ],
    );
  }

  Widget buildNavBarItem(String icon, int index) {
    return GestureDetector(
      onTap: () {
        onPauseVideo();
        //print(index);
        setState(() {
          _currentNav = index;
        });

        if (index == 0) {
          Navigator.of(context).pop();
        }

        if (index == 2) {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => MyCon()));
        }

        if (index == 3) {
          if (googleUser != null) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => UserProfile(user: googleUser)));
          } else {
            _showSignInModal(context);
          }
        }
      },
      child: Container(
        height: 60,
        width: MediaQuery.of(context).size.width / 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(10.0),
          ),
        ),
        child: Image.asset(
          icon,
          color: index == _currentNav ? Colors.grey[600] : null,
        ),
      ),
    );
  }

  //sign-in bottom sheet
  void _showSignInModal(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Container(
            color: Colors.grey[850],
            height: MediaQuery.of(context).size.height * .60,
            child: Container(
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(),
                      IconButton(
                        icon: Image.asset('assets/Home/close-btn.png'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  ),
                  Text(
                    'You need to Sign-In to continue',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.normal,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Padding(padding: EdgeInsets.all(10.0)),
                  Container(
                    width: 320,
                    child: Align(
                      alignment: Alignment.center,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        color: Colors.blue[900],
                        padding: EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ImageIcon(
                              AssetImage(
                                'assets/Home/icon-google@2x.png',
                              ),
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 6.0,
                            ),
                            Text(
                              'Sign-In With Google',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {
                          handleSignIn();
                        },
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(10.0)),
                  Container(
                    width: 320,
                    child: Align(
                      alignment: Alignment.center,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        color: Colors.blue,
                        padding: EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ImageIcon(
                              AssetImage(
                                'assets/Home/icon-facebook@2x.png',
                              ),
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 6.0,
                            ),
                            Text(
                              'Sign-In With Facebook',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(5.0)),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: new Container(
                          margin:
                              const EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Divider(
                            color: Colors.black,
                            height: 50,
                          ),
                        ),
                      ),
                      Text("OR"),
                      Expanded(
                        child: new Container(
                          margin:
                              const EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Divider(
                            color: Colors.black,
                            height: 50,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(padding: EdgeInsets.all(5.0)),
                  Container(
                    width: 320,
                    child: Align(
                      alignment: Alignment.center,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        color: Colors.redAccent[700],
                        padding: EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ImageIcon(
                              AssetImage(
                                'assets/Home/icon-phone@2x.png',
                              ),
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 6.0,
                            ),
                            Text(
                              'Sign-In Using Phone No.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => PhoneSignUp()));
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: 320,
                    margin: EdgeInsets.all(8.0),
                    child: RichText(
                      text: TextSpan(
                        style: defaultStyle,
                        children: <TextSpan>[
                          TextSpan(
                              text: 'By Signing In, you indicate that you '),
                          TextSpan(text: 'have read & agree to the '),
                          TextSpan(
                              text: 'Terms of Service',
                              style: linkStyle,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => MyCon()));
                                }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(27.0),
                  topRight: const Radius.circular(26.0),
                ),
              ),
            ),
          );
        });
  }

  //fetching particular video comment
  Future<void> getComment(playingIndex) async {
    //api key
    String key =
        '6adca579a9111ab5af265be8ed52742797f5ae6e67eebcfc793449d63618e7e5';

    String assetId = widget.list[playingIndex].v_id;

    //http request to fetch video data
    String url =
        "http://api.teapai.in/api_getComment.php?api_key=$key&assetId=$assetId&type=video";

    try {
      final response = await http.get(url);
      //comments = jsonDecode(response.body);

      var data = jsonDecode(response.body);

      if (data.runtimeType == [].runtimeType) {
        // List of comments
        comments = data;
      } else {
        // Object
        comments = [];
      }

      print(comments);
    } catch (e) {
      debugPrint('error');
    }
  }

  //post a comment for video
  Future<void> postComment(comment, vId) async {
    final String api_key =
        "6adca579a9111ab5af265be8ed52742797f5ae6e67eebcfc793449d63618e7e5";

    final String apiUrl = "http://api.teapai.in/api_putComment.php";

    String assetId = widget.list[vId].v_id;

    String userId = googleUser.displayName == null
        ? googleUser.phoneNumber
        : googleUser.displayName;

    final response = await http.post(apiUrl, body: {
      "userId": userId,
      "assetId": assetId,
      "type": 'video',
      "comment": comment,
      "api_key": api_key,
    });

    if (response.statusCode == 200) {
      print(response.body);
    } else {
      print('error');
    }
    _commentController.clear();
  }

  //liking a particular video
  Future<void> likeVideo(id) async {
    final String api_key =
        "6adca579a9111ab5af265be8ed52742797f5ae6e67eebcfc793449d63618e7e5";

    final String apiUrl = "http://api.teapai.in/api_putLike.php";

    String videoId = widget.list[id].v_id;
    String videoOwner = widget.list[id].userId;

    String userId = googleUser.displayName == null
        ? googleUser.phoneNumber
        : googleUser.displayName;

    final response = await http.post(apiUrl, body: {
      "userId": userId,
      "assetId": videoId,
      "type": 'video',
      "owner": videoOwner,
      "api_key": api_key,
    });

    if (response.statusCode == 200) {
      print(response.body);
    } else {
      print('error');
    }
  }
}

//end
//share
//_shareThisVideoNw(BuildContext context, playingIndex) {
//   showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (BuildContext context) {
//         return Container(
//           color: Colors.grey[850],
//           height: MediaQuery.of(context).size.height * .40,
//           child: Container(
//             child: Column(
//               children: [
//                 Stack(
//                   alignment: Alignment.topRight,
//                   children: [
//                     Container(
//                       child: Image.asset(
//                         'assets/Share/share-popup-header@2x.png',
//                         width: MediaQuery.of(context).size.width,
//                         repeat: ImageRepeat.repeat,
//                       ),
//                     ),
//                     IconButton(
//                       icon: Image.asset('assets/Comments/close-btn-white.png'),
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                     )
//                   ],
//                 ),
//                 Padding(padding: EdgeInsets.only(bottom: 40.0)),
//                 Padding(
//                   padding: const EdgeInsets.only(
//                     left: 15.0,
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         child: Text('Share to'),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Container(
//                         margin: EdgeInsets.only(left: 4.0, right: 16.0),
//                         child: GestureDetector(
//                           onTap: null,
//                           child: Image.asset('assets/Share/icon-whatsapp.png'),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Container(
//                         margin: EdgeInsets.only(left: 18.0, right: 18.0),
//                         child: GestureDetector(
//                           onTap: null,
//                           child: Image.asset('assets/Share/icon-facebook.png'),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Container(
//                         margin: EdgeInsets.only(left: 18.0, right: 18.0),
//                         child: GestureDetector(
//                           onTap: null,
//                           child: Image.asset('assets/Share/icon-instagram.png'),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Container(
//                         margin: EdgeInsets.only(left: 18.0),
//                         child: GestureDetector(
//                           onTap: null,
//                           child: Image.asset('assets/Share/icon-message.png'),
//                         ),
//                       ),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//             decoration: BoxDecoration(
//               color: Theme.of(context).canvasColor,
//               borderRadius: BorderRadius.only(
//                 topLeft: const Radius.circular(27.0),
//                 topRight: const Radius.circular(26.0),
//               ),
//             ),
//           ),
//         );
//       });
//}
