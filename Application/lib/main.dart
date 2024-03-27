import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:skin_disease_identifier/splashss.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the camera before running the app
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(
      firstCamera: firstCamera,
    ),
  ));
}

class MyApp extends StatefulWidget {
  final CameraDescription firstCamera;

  MyApp({required this.firstCamera});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String predict_res = "No image selected";
  late CameraController _cameraController;
  late File _image;
  File? _imageFile;
  XFile? imageselected;

  @override
  void initState() {
    super.initState();
    // Initialize the camera controller
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameraController = CameraController(
      widget.firstCamera,
      ResolutionPreset.ultraHigh,
    );

    // Initialize the camera controller
    await _cameraController.initialize();
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  void dispose() {
    // Dispose of the camera controller when no longer needed
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    try {
      final XFile image = await _cameraController.takePicture();
      setState(() {
        _imageFile = File(image.path);
        imageselected = image;
        predict_res = "Processing...";
        _processImageAndPredict();
      });
    } catch (e) {
      print('Error capturing photo: $e');
      setState(() {
        predict_res = "Error capturing photo: $e";
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image =
      await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) {
        print('Error parsing image');
        return;
      }
      setState(() {
        _imageFile = File(image.path);
        imageselected = image;
        predict_res = "Image Selected";
        _processImageAndPredict();
      });
    } catch (e) {
      print('Error picking image: $e');
      setState(() {
        predict_res = "Error picking image: $e";
      });
    }
  }

  Future<void> _processImageAndPredict() async {
    if (_imageFile != null) {
      try {
        print("Preparing to send the request");
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('http://192.168.43.250:5000/index'),
        );
        request.files.add(
          await http.MultipartFile.fromPath('file', _imageFile!.path),
        );
        print("File added to the request");
        final response = await request.send();
        print("Request sent");

        if (response.statusCode == 200) {
          print("Received a 200 response");
          final responseData = await response.stream.bytesToString();
          final predictions =
          json.decode(responseData) as Map<String, dynamic>;
          print("Received prediction: ${predictions['prediction']}");
          setState(() {
            predict_res = "You are diagnosed with: " + predictions['prediction'];
          });
        } else {
          print("Received an error response: ${response.statusCode}");
          setState(() {
            predict_res = "Error: ${response.statusCode}";
          });
        }
      } catch (e) {
        print("Caught an error: $e");
        setState(() {
          predict_res = "Error Catch: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('Skin Disease Identifier'),
        backgroundColor: Colors.grey[850],
      ),
      body: _imageFile == null
          ? _cameraController?.value.isInitialized == true
          ? Center(
        child: _cameraPreviewWidget(size),
        heightFactor: 1.05,
      )
          : Center(
        child: CircularProgressIndicator(),
      )
          : Center(
        child: _imageDisplayWidget(size),
        heightFactor: 1.05,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsetsDirectional.symmetric(horizontal: 30),
            child: Text(
              predict_res,
              style: TextStyle(
                fontSize: 16,
                color: Colors.amber,
              ),
            ),
          ),
          SizedBox(height: 60,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: temp,
                  child: Text("          Nearby Doctors                     ")),
              TextButton(onPressed: temp, child: Text(" Online Consultation")),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Capture  ",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                    FloatingActionButton(
                      onPressed: _captureImage,
                      child: Icon(Icons.camera),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Upload  ",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                    FloatingActionButton(
                      onPressed: _pickImage,
                      child: Icon(Icons.upload_rounded),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cameraPreviewWidget(Size size) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber),
      ),
      width: size.width * 0.9, // 90% of screen width
      height: size.height * 0.75, // 75% of screen height
      child: CameraPreview(_cameraController),
    );
  }

  Widget _imageDisplayWidget(Size size) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber),
      ),
      width: size.width * 0.9, // 90% of screen width
      height: size.height * 0.5, // 75% of screen height
      child: _imageFile != null
          ? Image.file(_imageFile!, fit: BoxFit.cover)
          : Container(),
    );
  }
}

void temp() {}
