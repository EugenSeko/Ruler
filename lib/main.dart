import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(const CameraApp());
}

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;

  @override
  void initState() {
    super.initState();

    controller = CameraController(_cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: Scaffold(
          body: CameraMask(
        controller: controller,
      )),
    );
  }
}

class CameraMask extends StatefulWidget {
  final CameraController controller;
  CameraMask({super.key, required this.controller});

  int count = 0;

  @override
  State<CameraMask> createState() => _CameraMaskState();
}

class _CameraMaskState extends State<CameraMask> {
  @override
  Widget build(BuildContext context) {
    var sizes = MediaQuery.of(context).size;

    var height = sizes.height;
    var width = sizes.width;

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(widget.controller),
        const Center(
          child: Icon(
            Icons.add_circle,
            color: Colors.white,
          ),
        ),
        Positioned(
            top: height / 3,
            left: width / 3,
            right: 0,
            bottom: 0,
            child: Container(
                color: Colors.transparent,
                child: TextField(
                  decoration: const InputDecoration(hintText: 'You text here'),
                  onChanged: (value) => print(value),
                  onSubmitted: (value) {
                    widget.count++;
                  },
                ))),
        Positioned(
            top: height / 4,
            left: width / 4,
            right: 0,
            bottom: 0,
            child: Container(
                color: Colors.transparent,
                child: Text(
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    '${widget.count}'))),
      ],
    );
  }
}
