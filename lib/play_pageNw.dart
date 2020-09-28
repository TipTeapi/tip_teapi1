import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import './VideoInfo.dart';
import 'dart:math';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share/share.dart';
import './categoryNw.dart';
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
List<VideoInfo> videos;
String noOfLikes;
int _currentNav = 0;

final TextEditingController _commentController = new TextEditingController();

class PlayPage extends StatefulWidget {
  final UserSelCategoryData data;

  PlayPage({this.data});

  @override
  _PlayPageState createState() => _PlayPageState(data: data);
}

class _PlayPageState extends State<PlayPage> with WidgetsBindingObserver {
  final UserSelCategoryData data;
  _PlayPageState({this.data});
  VideoPlayerController _videoController;
  var categoryList;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = new GoogleSignIn();
  User user;
  bool checked = false;
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

  //fetching user selected category videos
  Future<void> fetchVideoUrl() async {
    //getting user selected category
    categoryList = data.dataList;

    String userCategory = categoryList.join(",");

    //api key
    String key =
        '6adca579a9111ab5af265be8ed52742797f5ae6e67eebcfc793449d63618e7e5';

    //http request to fetch video data
    String url =
        "http://api.teapai.in/api_getVideoMultipleCategory.php?api_key=$key&cat=$userCategory";
    try {
      final response = await http.get(url);
      final List<dynamic> jsonDat = jsonDecode(response.body);

      videos = jsonDat
          .map((vid) => VideoInfo(
              v_id: vid['v_id'],
              category: vid['category'],
              userId: vid['userId'],
              place: vid['place'],
              assetVideo: "http://api.teapai.in/" + vid['assetVideo'],
              no_of_likes: vid['no_of_likes']))
          .toList();

      //print(videos);
      //calling video player
      _initializeAndPlay(0);

      if (googleUser != null) {
        //getting likes
        await getUserLike();
      }
    } catch (error) {
      debugPrint(error);
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

  var _disposed = false;
  var _isEndOfClip = false;
  var _progress = 0.0;
  var isInitialized = true;
  Timer _timerVisibleControl;
  double _controlAlpha = 1.0;

  var _playing = false;
  bool get _isPlaying {
    return _playing;
  }

  set _isPlaying(bool value) {
    _playing = value;
    _timerVisibleControl?.cancel();
    if (value) {
      _timerVisibleControl = Timer(Duration(seconds: 2), () {
        setState(() {
          _controlAlpha = 0.0;
        });
      });
    } else {
      _timerVisibleControl = Timer(Duration(milliseconds: 200), () {
        setState(() {
          _controlAlpha = 1.0;
        });
      });
    }
  }

  void _onTapVideo() {
    debugPrint("_onTapVideo $_controlAlpha");
    setState(() {
      _controlAlpha = _controlAlpha > 0 ? 0 : 1;
    });
    _timerVisibleControl?.cancel();
    _timerVisibleControl = Timer(Duration(seconds: 2), () {
      if (_isPlaying) {
        setState(() {
          _controlAlpha = 0.0;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      googleUser = user;
    });

    //fetching from server
    fetchVideoUrl();

    //adding observer
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _disposed = true;
    _timerVisibleControl?.cancel();
    _videoController?.pause(); // mute instantly
    _videoController?.dispose();
    _videoController = null;
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

  void _initializeAndPlay(int index) async {
    print("_initializeAndPlay ---------> $index");

    var url = videos[index].assetVideo;

    final controller = VideoPlayerController.network(url);
    final old = _videoController;
    _videoController = controller;
    if (old != null) {
      old.removeListener(_onControllerUpdated);
      await old.pause();
    }
    setState(() {
      debugPrint("---- controller changed");
    });

    controller
      ..initialize().then((_) {
        debugPrint("---- controller initialized");
        old?.dispose();
        _playingIndex = index;
        controller.addListener(_onControllerUpdated);
        controller.play();
        setState(() {});
      });

    //getting currently playing video id
    if (googleUser != null) {
      vidId = videos[_playingIndex].v_id;
    }
  }

  var _updateProgressInterval = 0.0;

  Future<void> _onControllerUpdated() async {
    if (_disposed) return;
    final controller = _videoController;
    if (controller == null) return;
    if (!controller.value.initialized) return;
    final position = await controller.position;
    final duration = controller.value.duration;
    if (position == null || duration == null) return;

    final playing = controller.value.isPlaying;
    final isEndOfClip =
        position.inMilliseconds > 0 && position.inSeconds == duration.inSeconds;

    // blocking too many updation
    final interval = position.inMilliseconds / 250.0;
    if (playing && _updateProgressInterval != interval) {
      // handle progress indicator
      _updateProgressInterval = interval;
      if (_disposed) return;
      setState(() {
        _progress = position.inMilliseconds.ceilToDouble() /
            duration.inMilliseconds.ceilToDouble();
      });
    }

    // handle clip end
    if (_isPlaying != playing || _isEndOfClip != isEndOfClip) {
      _isPlaying = playing;
      _isEndOfClip = isEndOfClip;
      debugPrint(
          "updated -----> isPlaying=$playing / isEndPlaying=$isEndOfClip");
      if (isEndOfClip && !playing) {
        debugPrint(
            "========================== End of Clip / Handle NEXT ========================== ");
        final isComplete = _playingIndex == videos.length - 1;
        if (!isComplete) {
          _initializeAndPlay(_playingIndex + 1);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _videoController;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[850],
        body: SafeArea(
          child: controller != null && controller.value.initialized
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(padding: EdgeInsets.all(40.0)),
                    Container(
                      child: Center(
                        child: _playView(context),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    //Padding(padding: EdgeInsets.only(bottom: 30.0)),
                    Container(
                      child: _sideNavigation(),
                    )
                  ],
                )
              : Container(
                  child: Center(
                    child: SpinKitFadingCircle(
                      color: Colors.grey[300],
                      size: 60.0,
                    ),
                  ),
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
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => Upload()));
          },
          child: Image.asset('assets/Home/icon-tipteapi@2x.png'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _playView(BuildContext context) {
    // final controller = _videoController;
    // if (controller != null && controller.value.initialized) {
    return AspectRatio(
      aspectRatio: 16.0 / 9.0,
      child: Stack(
        //fit: StackFit.loose,
        children: [
          GestureDetector(
            child: VideoPlayer(_videoController),
            onTap: _onTapVideo,
            //onVerticalDragUpdate: (DragUpdateDetails details) async {},
          ),
          _controlAlpha > 0
              ? AnimatedOpacity(
                  opacity: _controlAlpha,
                  duration: Duration(milliseconds: 250),
                  child: _controlView(context),
                )
              : Container(),
        ],
      ),
    );
    // } else {
    //   return Center(
    //     child: SpinKitFadingCircle(
    //       color: Colors.grey[300],
    //       size: 40.0,
    //     ),
    //   );
    // }
  }

  Widget _controlView(BuildContext context) {
    return Column(
      children: <Widget>[
        _topUI(),
        Expanded(
          child: _centerUI(),
        ),
        //_sideNavigation(),
        //_bottomUI()
      ],
    );
  }

  Widget _sideNavigation() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: Container()),
        Expanded(child: Container()),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                child: Image.asset('assets/Home/icon-near-by-normal@3x.png'),
                onPressed: () async {},
                heroTag: null,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: FloatingActionButton(
                //backgroundColor: Colors.transparent,
                child: userLikes.contains(vidId)
                    ? Image.asset('assets/Home/icon-like-hover@3x.png')
                    : Image.asset('assets/Home/icon-like-normal@3x.png'),
                onPressed: () async {
                  if (googleUser != null) {
                    await likeVideo(_playingIndex);
                    setState(() {
                      userLikes.add(vidId);

                      print(videos[_playingIndex].no_of_likes.runtimeType);

                      if (videos[_playingIndex].no_of_likes.isEmpty) {
                        // Haven't liked yet

                        videos[_playingIndex].no_of_likes = "1";
                      } else {
                        // Can be converted into INteger

                        videos[_playingIndex].no_of_likes =
                            (int.parse(videos[_playingIndex].no_of_likes) + 1)
                                .toString();
                      }
                    });
                  } else {
                    _showSignInModal(context);
                  }
                },
                heroTag: null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Container(
                child: Text(
                  googleUser != null ? videos[_playingIndex].no_of_likes : '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: FloatingActionButton(
                //backgroundColor: Colors.transparent,
                child: Image.asset('assets/Home/icon-comment-normal@3x.png'),
                onPressed: () async {
                  if (googleUser != null) {
                    if (_isPlaying) {
                      _videoController.pause();
                    }
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
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: FloatingActionButton(
                //backgroundColor: Colors.transparent,
                child: Image.asset('assets/Home/icon-share-normal@3x.png'),
                onPressed: () {
                  if (_isPlaying) {
                    _videoController.pause();
                  }
                  if (googleUser != null) {
                    _shareThisVideo(context, _playingIndex);
                  } else {
                    _showSignInModal(context);
                  }
                },
                heroTag: null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _centerUI() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            onPressed: () async {
              final index = _playingIndex - 1;
              if (index > 0 && videos.length > 0) {
                _initializeAndPlay(index);
              }
            },
            child: Icon(
              Icons.fast_rewind,
              size: 36.0,
              color: Colors.white,
            ),
          ),
          FlatButton(
            onPressed: () async {
              if (_isPlaying) {
                _videoController?.pause();
                _isPlaying = false;
              } else {
                final controller = _videoController;
                if (controller != null) {
                  final position = await controller.position;
                  final isEnd =
                      controller.value.duration.inSeconds == position.inSeconds;
                  if (isEnd) {
                    _initializeAndPlay(_playingIndex);
                  } else {
                    controller.play();
                  }
                }
              }
              setState(() {});
            },
            child: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              size: 56.0,
              color: Colors.white,
            ),
          ),
          FlatButton(
            onPressed: () async {
              final index = _playingIndex + 1;
              if (index < videos.length - 1) {
                _initializeAndPlay(index);
              }
            },
            child: Icon(
              Icons.fast_forward,
              size: 36.0,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String convertTwo(int value) {
    return value < 10 ? "0$value" : "$value";
  }

  Widget _topUI() {
    final noMute = (_videoController?.value?.volume ?? 0) > 0;
    final duration = _videoController == null
        ? 0
        : _videoController.value.duration.inSeconds;
    final head = _videoController == null
        ? 0
        : _videoController.value.position.inSeconds;
    final remained = max(0, duration - head);
    final min = convertTwo(remained ~/ 60.0);
    final sec = convertTwo(remained % 60);
    return Row(
      children: <Widget>[
        InkWell(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                  BoxShadow(
                      offset: const Offset(0.0, 0.0),
                      blurRadius: 4.0,
                      color: Color.fromARGB(50, 0, 0, 0)),
                ]),
                child: Icon(
                  noMute ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white,
                )),
          ),
          onTap: () {
            if (noMute) {
              _videoController?.setVolume(0);
            } else {
              _videoController?.setVolume(1.0);
            }
            setState(() {});
          },
        ),
        Expanded(
          child: Container(),
        ),
        Text(
          "$min:$sec",
          style: TextStyle(
            color: Colors.white,
            shadows: <Shadow>[
              Shadow(
                offset: Offset(0.0, 1.0),
                blurRadius: 4.0,
                color: Color.fromARGB(150, 0, 0, 0),
              ),
            ],
          ),
        ),
        SizedBox(width: 10)
      ],
    );
  }

  // Widget _bottomUI() {
  //   return Row(
  //     children: <Widget>[
  //       SizedBox(width: 20),
  //       Expanded(
  //         child: Slider(
  //           value: max(0, min(_progress * 100, 100)),
  //           min: 0,
  //           max: 100,
  //           onChanged: (value) {
  //             setState(() {
  //               _progress = value * 0.01;
  //             });
  //           },
  //           onChangeStart: (value) {
  //             debugPrint("-- onChangeStart $value");
  //             _videoController?.pause();
  //           },
  //           onChangeEnd: (value) {
  //             debugPrint("-- onChangeEnd $value");
  //             final duration = _videoController?.value?.duration;
  //             if (duration != null) {
  //               var newValue = max(0, min(value, 99)) * 0.01;
  //               var millis = (duration.inMilliseconds * newValue).toInt();
  //               _videoController?.seekTo(Duration(milliseconds: millis));
  //               _videoController?.play();
  //             }
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

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
    String videoUrl = videos[playingIndex].assetVideo;
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
        if (_isPlaying) {
          _videoController.pause();
        }

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
                  Padding(padding: EdgeInsets.all(20.0)),
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
                        onPressed: () {
                          // if (checked != false) {
                          //   handleSignIn();
                          // } else {
                          //   Fluttertoast.showToast(
                          //     msg: "Accept Terms & Conditions",
                          //     toastLength: Toast.LENGTH_SHORT,
                          //     gravity: ToastGravity.BOTTOM,
                          //     backgroundColor: Colors.grey[300],
                          //     textColor: Colors.black,
                          //     fontSize: 16.0,
                          //   );
                          // }
                        },
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(10.0)),
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
                  Padding(padding: EdgeInsets.all(8.0)),
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
}

//share
_shareThisVideoNw(BuildContext context, playingIndex) {
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          color: Colors.grey[850],
          height: MediaQuery.of(context).size.height * .40,
          child: Container(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      child: Image.asset(
                        'assets/Share/share-popup-header@2x.png',
                        width: MediaQuery.of(context).size.width,
                        repeat: ImageRepeat.repeat,
                      ),
                    ),
                    IconButton(
                      icon: Image.asset('assets/Comments/close-btn-white.png'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
                Padding(padding: EdgeInsets.only(bottom: 40.0)),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 15.0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        child: Text('Share to'),
                      ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        margin: EdgeInsets.only(left: 4.0, right: 16.0),
                        child: GestureDetector(
                          onTap: null,
                          child: Image.asset('assets/Share/icon-whatsapp.png'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        margin: EdgeInsets.only(left: 18.0, right: 18.0),
                        child: GestureDetector(
                          onTap: null,
                          child: Image.asset('assets/Share/icon-facebook.png'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        margin: EdgeInsets.only(left: 18.0, right: 18.0),
                        child: GestureDetector(
                          onTap: null,
                          child: Image.asset('assets/Share/icon-instagram.png'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        margin: EdgeInsets.only(left: 18.0),
                        child: GestureDetector(
                          onTap: null,
                          child: Image.asset('assets/Share/icon-message.png'),
                        ),
                      ),
                    ),
                  ],
                )
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

  String assetId = videos[playingIndex].v_id;

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

Future<void> postComment(comment, vId) async {
  final String api_key =
      "6adca579a9111ab5af265be8ed52742797f5ae6e67eebcfc793449d63618e7e5";

  final String apiUrl = "http://api.teapai.in/api_putComment.php";

  String assetId = videos[vId].v_id;

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

Future<void> likeVideo(id) async {
  final String api_key =
      "6adca579a9111ab5af265be8ed52742797f5ae6e67eebcfc793449d63618e7e5";

  final String apiUrl = "http://api.teapai.in/api_putLike.php";

  String videoId = videos[id].v_id;
  String videoOwner = videos[id].userId;

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
