import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tip_teapi/comment.dart';
import 'package:video_player/video_player.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import './VideoInfo.dart';
import 'dart:math';
import './category_menu.dart';
import './sign_in.dart';
import './user_profile.dart';
import './upload.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';

List<dynamic> videoUrls = [];
List videoIds = [];
List videoUserIds = [];
User googleUser;

class PlayPage extends StatefulWidget {
  final UserCategoryData data;

  PlayPage({this.data});

  @override
  _PlayPageState createState() => _PlayPageState(data);
}

class _PlayPageState extends State<PlayPage> with WidgetsBindingObserver {
  final UserCategoryData data;
  _PlayPageState(this.data);
  VideoPlayerController _videoController;
  var categoryList;
  bool isLiked = true;

  Future<void> fetchVideo() async {
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

      var videos = jsonDat.map((vid) => VideoInfo(
            v_id: vid['v_id'],
            category: vid['category'],
            userId: vid['userId'],
            place: vid['place'],
            assetVideo: "http://api.teapai.in/" + vid['assetVideo'],
          ));

      videoUrls = videos?.map((e) => e.assetVideo)?.toList() ?? [];
      videoIds = videos.map((e) => e.v_id).toList();
      videoUserIds = videos.map((e) => e.userId).toList();

      //print(jsonDat);
      print(videoIds);

      //calling video player
      _initializeAndPlay(0);
    } catch (error) {
      debugPrint(error);
    }
  }

  var _playingIndex;
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
    fetchVideo();

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
    String url = videoUrls[index].toString();
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
        final isComplete = _playingIndex == videoUrls.length - 1;
        if (!isComplete) {
          _initializeAndPlay(_playingIndex + 1);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int _currentNav = 0;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: isInitialized ? _playView(context) : _playView(context),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          currentIndex: _currentNav,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.home, color: Colors.white, size: 35),
              title: Text(""),
            ),
            BottomNavigationBarItem(
              icon:
                  Icon(FontAwesomeIcons.search, color: Colors.white, size: 35),
              title: Text("Search"),
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.plus, color: Colors.white, size: 35),
              title: Text("Upload"),
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.user, color: Colors.white, size: 35),
              title: Text("Profile"),
            )
          ],
          onTap: (index) {
            if (_isPlaying) {
              _videoController.pause();
            }

            setState(() {
              _currentNav = index;
            });
            if (index == 0) {
              Navigator.of(context).pop();
            }

            if (index == 2) {
              if (googleUser != null) {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => Upload()));
              } else {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => SignIn()));
              }
            }

            if (index == 3) {
              if (googleUser != null) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => UserProfile(user: googleUser)));
              } else {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => SignIn()));
              }
            }
          },
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              backgroundColor: isLiked ? Colors.transparent : Colors.blueAccent,
              child: Icon(FontAwesomeIcons.thumbsUp, size: 30),
              onPressed: () async {
                await likeVideo(_playingIndex);
                setState(() {
                  isLiked = !isLiked;
                });
              },
              heroTag: null,
            ),
            SizedBox(
              height: 10,
            ),
            FloatingActionButton(
              backgroundColor: Colors.transparent,
              child:
                  Icon(FontAwesomeIcons.share, color: Colors.white, size: 30),
              onPressed: () {
                //print(_playingIndex);
              },
              heroTag: null,
            ),
            SizedBox(
              height: 10,
            ),
            FloatingActionButton(
              backgroundColor: Colors.transparent,
              child:
                  Icon(FontAwesomeIcons.comment, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => MyTextInput()));
              },
              heroTag: null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _playView(BuildContext context) {
    final controller = _videoController;
    if (controller != null && controller.value.initialized) {
      return SafeArea(
        child: Stack(
          children: [
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: _videoController.value.size?.width ?? 0,
                  height: _videoController.value.size?.height ?? 0,
                  child: VideoPlayer(_videoController),
                ),
              ),
            ),
            GestureDetector(
              child: VideoPlayer(_videoController),
              onTap: _onTapVideo,
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
    } else {
      return Center(
          child: SpinKitFadingCircle(
        color: Colors.white,
        size: 70.0,
      ));
    }
  }

  Widget _controlView(BuildContext context) {
    return Column(
      children: <Widget>[
        _topUI(),
        Expanded(
          child: _centerUI(),
        ),
        _bottomUI()
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
              if (index > 0 && videoUrls.length > 0) {
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
              if (index < videoUrls.length - 1) {
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

  Widget _bottomUI() {
    return Row(
      children: <Widget>[
        SizedBox(width: 20),
        Expanded(
          child: Slider(
            value: max(0, min(_progress * 100, 100)),
            min: 0,
            max: 100,
            onChanged: (value) {
              setState(() {
                _progress = value * 0.01;
              });
            },
            onChangeStart: (value) {
              debugPrint("-- onChangeStart $value");
              _videoController?.pause();
            },
            onChangeEnd: (value) {
              debugPrint("-- onChangeEnd $value");
              final duration = _videoController?.value?.duration;
              if (duration != null) {
                var newValue = max(0, min(value, 99)) * 0.01;
                var millis = (duration.inMilliseconds * newValue).toInt();
                _videoController?.seekTo(Duration(milliseconds: millis));
                _videoController?.play();
              }
            },
          ),
        ),
      ],
    );
  }
}

Future<void> likeVideo(id) async {
  final String api_key =
      "6adca579a9111ab5af265be8ed52742797f5ae6e67eebcfc793449d63618e7e5";

  final String apiUrl = "http://api.teapai.in/api_putLike.php";

  String videoId = videoIds[id];
  String videoOwner = videoUserIds[id];

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
