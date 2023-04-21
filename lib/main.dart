import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:sensor_app/style/color_schema.dart';
import 'package:sensor_app/widgets/entry_decimal.dart';

import 'package:flutter_sensors/flutter_sensors.dart';

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
  double _distance = 0;
  double _lenght = 0;
  double _height = 0;

  double get distance => _height / tan((pi / 2) - tiltAngle);

  bool _accelAvailable = false;
  List<double> _accelData = List.filled(3, 0.0);
  StreamSubscription? _accelSubscription;
  bool get isCameraUp => _accelData[2].isNegative;

  double get tiltAngle => atan2(_accelData[1],
      sqrt(_accelData[0] * _accelData[0] + _accelData[2] * _accelData[2]));

  double get pitchAngle => atan2(-_accelData[0],
      sqrt(_accelData[1] * _accelData[1] + _accelData[2] * _accelData[2]));

  @override
  void initState() {
    _checkAccelerometerStatus();
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _stopAccelerometer();
    _controller.dispose();
    super.dispose();
  }

  void _checkAccelerometerStatus() async {
    await SensorManager()
        .isSensorAvailable(Sensors.ACCELEROMETER)
        .then((result) {
      setState(() {
        _accelAvailable = result;
      });
    });
  }

  void _stopAccelerometer() {
    if (_accelSubscription == null) return;
    _accelSubscription?.cancel();
    _accelSubscription = null;
  }

  Future<void> _startAccelerometer() async {
    if (_accelSubscription != null) return;
    if (_accelAvailable) {
      final stream = await SensorManager().sensorUpdates(
        sensorId: Sensors.ACCELEROMETER,
        interval: Sensors.SENSOR_DELAY_FASTEST,
      );
      _accelSubscription = stream.listen((sensorEvent) {
        setState(() {
          _accelData = sensorEvent.data;
        });
      });
    }
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
                      child: EntryDecimal(
                        onSubmitted: _setHeight,
                      ),
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
                      onPressed: _onButtonTap,
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
                      children: [
                        Text('Distance: $_distance'),
                        Text('Height: $_height'),
                        Text('Lenght: $_lenght'),
                      ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
    // _startAccelerometer();
    setState(() {
      _distance = distance;
    });
    // _stopAccelerometer();
  }

  void _reset() {
    setState(() {
      h1 = h2 = _distance = _lenght = 0;
    });
  }

  double h1 = 0;
  double h2 = 0;

  void _setPoint() {
    // _startAccelerometer();
    setState(() {
      if (true) {
        double x = _distance * tan(((pi / 2) - tiltAngle));

        if (h1 == 0) {
          h1 = isCameraUp ? _height + x : _height - x;
        } else {
          h2 = isCameraUp ? _height + x : _height - x;
        }
      }
    });
    // _stopAccelerometer();
  }

  void _getLenght() {
    if (h1 == h2) return;
    setState(() {
      _lenght = h1 > h2 ? h1 - h2 : h2 - h1;
    });
  }

  void _setHeight(String str) {
    _startAccelerometer();
    _reset();
    setState(() {
      double height = double.parse(str);
      _height = height;
    });
  }
}
