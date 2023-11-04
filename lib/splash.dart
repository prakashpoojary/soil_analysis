import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MySplash extends StatefulWidget {
  const MySplash({Key? key}) : super(key: key);

  @override
  State<MySplash> createState() => _MySplashState();
}

class _MySplashState extends State<MySplash> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    checkForUserStatus();

    // Initialize the video controller with your video file
    _controller = VideoPlayerController.asset('lib/images/1.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown
        setState(() {});
        // Start playing the video
        _controller.play();
        // Add a listener for when the video completes
        _controller.addListener(() {
          if (_controller.value.position >= _controller.value.duration) {
            // Video has finished, navigate to the home page
            Navigator.pushReplacementNamed(context, "home");
          }
        });
      });
  }

  @override
  void dispose() {
    // Dispose of the video controller when the widget is disposed
    _controller.dispose();
    super.dispose();
  }

  checkForUserStatus() {
    FirebaseAuth.instance.userChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
        Navigator.pushNamedAndRemoveUntil(context, "login", (route) => false);
      } else {
        print('User is signed in!');
        // Don't navigate here, let the video complete first
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _controller.value.isInitialized
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            : CircularProgressIndicator(), // You can replace this with a loading indicator
      ),
    );
  }
}
