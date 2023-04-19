import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:sensor_app/style/color_schema.dart';
import 'package:sensor_app/widgets/entry_decimal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(CameraApp(camera: firstCamera));
}

class CameraApp extends StatefulWidget {
  final CameraDescription camera;

  const CameraApp({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  String _buttonText = 'Set distance';
  double? _distance;
  double? _lenght;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var devicePixelRatio = window.devicePixelRatio;
    var h = window.physicalSize.height / devicePixelRatio;
    var w = window.physicalSize.width / devicePixelRatio;

    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(_controller);
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.circle,
                    color: Colors.red,
                    size: 5,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 28, 130),
                    child: SizedBox(
                      height: 32,
                      width: 89,
                      child: EntryDecimal(),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 26, 200),
                    child: TextButton(
                      style: ButtonStyle(
                          minimumSize:
                              MaterialStateProperty.all(const Size(10, 90)),
                          overlayColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Colors.black.withOpacity(0.5);
                              }
                              return primaryColor; // используется цвет по умолчанию
                            },
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.transparent),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(60.0),
                                      side: const BorderSide(color: colorI1)))),
                      onPressed: () {},
                      child: Text(
                        _buttonText,
                        style: const TextStyle(color: colorI1),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 64, 0, 0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Distance: '),
                        Text('Height: '),
                        Text('Lenght: '),
                      ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
