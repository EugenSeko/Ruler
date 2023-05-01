import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:sensor_app/style/color_schema.dart';
import 'package:sensor_app/utils/timer.dart';
import 'package:sensor_app/widgets/entry_decimal.dart';

import '../utils/sensor_manager.dart';

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
  final SensorManager sensorManager = SensorManager();

  String _buttonText = 'Set distance';
  double _distance = 0;
  double _lenght = 0;
  double _height = 0;

  double get distance => _height / tan((pi / 2) - sensorManager.tiltAngle);
  bool get isCameraUp => sensorManager.accelData[2].isNegative;

  void Function()? onButtonTap;
  MyTimer? timer;
  var duration = const Duration(milliseconds: 100);

  @override
  void initState() {
    sensorManager.checkAccelerometerStatus();
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    timer = MyTimer(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    sensorManager.stopAccelerometer();
    _controller.dispose();
    timer?.stopTimer();
    super.dispose();
  }

  Color sunColor = colorI2;

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
                    padding: const EdgeInsets.fromLTRB(0, 0, 28, 140),
                    child: SizedBox(
                      height: 34,
                      width: 109,
                      child: EntryDecimal(
                        onSubmitted: _setHeight,
                        onTap: () => timer?.stopTimer(),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 26, 190),
                    child: TextButton(
                      style: ButtonStyle(
                          minimumSize:
                              MaterialStateProperty.all(const Size(100, 32)),
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
                      onPressed: onButtonTap,
                      child: Text(
                        _buttonText,
                        textScaleFactor: 1.2,
                        style: const TextStyle(color: colorI1),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 64, 0, 0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Distance: ${_distance == 0 ? distance : _distance}',
                          style: const TextStyle(color: colorI1),
                          textScaleFactor: 1.2,
                        ),
                        Text(
                          'Height: $_height',
                          style: const TextStyle(color: colorI1),
                          textScaleFactor: 1.2,
                        ),
                        Text(
                          'Lenght: $_lenght',
                          style: const TextStyle(color: colorI1),
                          textScaleFactor: 1.2,
                        ),
                      ]),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 0, 0, 32),
                      child: IconButton(
                        icon: const Icon(
                          Icons.sunny,
                          size: 38,
                        ),
                        color: sunColor,
                        onPressed: _swichSensors,
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _swichSensors() {
    if (sensorManager.accelSubscription != null) {
      sensorManager.stopAccelerometer();
      setState(() {
        sunColor = colorI2;
        onButtonTap = null;
      });
      timer?.stopTimer();
    } else {
      sensorManager.startAccelerometer();
      setState(() {
        sunColor = colorI1;
        onButtonTap = _onButtonTap;
      });
    }
  }

  void _onButtonTap() {
    if (_height == 0) return;
    if (_buttonText == 'Reset') {
      _buttonText = 'Set distance';
      _reset();
      return;
    }
    if (_distance == 0) {
      _buttonText = 'Set point A';
      _setDistance();
    } else {
      _buttonText = h1 == 0 ? 'Set point B' : 'Reset';
      _setPoint();
      if (h2 != 0) {
        _getLenght();
      }
    }
  }

  void _setDistance() {
    timer?.stopTimer();
    setState(() {
      _distance = distance;
    });
  }

  void _reset() {
    h1 = h2 = _distance = _lenght = 0;
    timer?.startTimer(duration);
  }

  double h1 = 0;
  double h2 = 0;

  void _setPoint() {
    setState(() {
      if (true) {
        double x = _distance * tan(((pi / 2) - sensorManager.tiltAngle));

        if (h1 == 0) {
          h1 = isCameraUp ? _height + x : _height - x;
        } else {
          h2 = isCameraUp ? _height + x : _height - x;
        }
      }
    });
  }

  void _getLenght() {
    if (h1 == h2) return;
    setState(() {
      _lenght = h1 > h2 ? h1 - h2 : h2 - h1;
    });
  }

  void _setHeight(String str) {
    if (str.isEmpty) return;
    _reset();
    setState(() {
      double height = double.parse(str);
      _height = height;
    });
    timer?.startTimer(duration);
  }
}
