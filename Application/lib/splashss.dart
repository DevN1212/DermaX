import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'main.dart';

class SplashScreen extends StatefulWidget {
  final CameraDescription firstCamera;

  SplashScreen({required this.firstCamera});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Duration splashDuration = Duration(seconds: 3);

  void navigateToMainScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MyApp(firstCamera: widget.firstCamera),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(splashDuration, () {
      navigateToMainScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Image.asset('assets/skin.png'),
              height: 150,
              width: 150,
            ),
            Text(
              'Skin Disease Identifier',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              color: Colors.white60,
            ),
          ],
        ),
      ),
    );
  }
}
