import 'package:flutter/material.dart';
import 'package:flutter_sensors/flutter_sensors.dart' as fs;
import 'package:sensor_app/utils/sensor_manager.dart';
import 'package:sensor_app/utils/timer.dart';

void main(List<String> args) {
  runApp(MyWidget());
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  SensorManager sm = SensorManager();
  MyTimer? timer;
  List<double> zAccels = [];
  Stopwatch stopwatch = Stopwatch();
  bool isReadData = false;
  int t = 0;
  List<double> negAccels = [];
  List<double> posAccels = [];
  double negSum = 0;
  double posSum = 0;

  void pullData() {
    stopwatch.start();
    isReadData = true;
  }

  void stopPullData() {
    stopwatch.stop();
    isReadData = false;
    t = stopwatch.elapsedMilliseconds;
    printResults();
    stopwatch.reset();
    zAccels.clear();
    negAccels.clear();
    posAccels.clear();
    negSum = posSum = 0;
  }

  void printResults() {
    for (var element in zAccels) {
      element.isNegative ? negAccels.add(element) : posAccels.add(element);
    }
    for (var element in negAccels) {
      // print('$element \n');
      negSum += element;
    }
    for (var element in posAccels) {
      // print('$element \n');
      posSum += element;
    }
    for (var element in zAccels) {
      print('$element \n');
    }
    print('Neg sum = $negSum \n');
    print('Pos sum = $posSum \n');
    print('Time = $t millisecounds \n');
    print('diff = ${posSum + negSum} \n');
    print('pos Average = ${posSum / posAccels.length} \n');
    print('neg Average = ${negSum / negAccels.length} \n');
    print('pos count = ${posAccels.length} \n');
    print('neg count = ${negAccels.length} \n');
  }

  @override
  void initState() {
    super.initState();
    timer = MyTimer(() {
      setState(() {});
    });
    timer?.startTimer(const Duration(milliseconds: 8));
    sm.linearAccelDelay = fs.Sensors.SENSOR_DELAY_FASTEST;
    sm.checkAccelerometerStatus();
    sm.checkLinearAccelerometerStatus();
  }

  @override
  void dispose() {
    sm.stopAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isReadData) {
      zAccels.add(sm.linearAccelData[2]);
    }
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Sensors Example'),
        ),
        body: Container(
          padding: EdgeInsets.all(16.0),
          alignment: AlignmentDirectional.topCenter,
          child: Column(
            children: <Widget>[
              Text(
                "Accelerometer Test",
                textAlign: TextAlign.center,
              ),
              Text(
                "Accelerometer Enabled: ${sm.accelAvailable}",
                textAlign: TextAlign.center,
              ),
              Padding(padding: EdgeInsets.only(top: 16.0)),
              Text(
                "[0](X) = ${sm.accelData[0]}",
                textAlign: TextAlign.center,
              ),
              Padding(padding: EdgeInsets.only(top: 16.0)),
              Text(
                "[1](Y) = ${sm.accelData[1]}",
                textAlign: TextAlign.center,
              ),
              Padding(padding: EdgeInsets.only(top: 16.0)),
              Text(
                "[2](Z) = ${sm.accelData[2]}",
                textAlign: TextAlign.center,
              ),
              Padding(padding: EdgeInsets.only(top: 16.0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    child: Text("Start"),
                    color: Colors.green,
                    onPressed: sm.accelAvailable
                        ? () => sm.startAccelerometer()
                        : null,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  MaterialButton(
                    child: Text("Stop"),
                    color: Colors.red,
                    onPressed:
                        sm.accelAvailable ? () => sm.stopAccelerometer() : null,
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 16.0)),
              Text(
                "LinearAccel Test",
                textAlign: TextAlign.center,
              ),
              Text(
                "LinearAccel Enabled: ${sm.linearAccelAvailable}",
                textAlign: TextAlign.center,
              ),
              Padding(padding: EdgeInsets.only(top: 16.0)),
              Text(
                "[0](X) = ${sm.linearAccelData[0]}",
                textAlign: TextAlign.center,
              ),
              Padding(padding: EdgeInsets.only(top: 16.0)),
              Text(
                "[1](Y) = ${sm.linearAccelData[1]}",
                textAlign: TextAlign.center,
              ),
              Padding(padding: EdgeInsets.only(top: 16.0)),
              Text(
                "[2](Z) = ${sm.linearAccelData[2]}",
                textAlign: TextAlign.center,
              ),
              Padding(padding: EdgeInsets.only(top: 16.0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    child: Text("Start"),
                    color: Colors.green,
                    onPressed: sm.linearAccelAvailable
                        ? () {
                            sm.startLinearAccelerometer();
                            pullData();
                          }
                        : null,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  MaterialButton(
                    child: Text("Stop"),
                    color: Colors.red,
                    onPressed: sm.linearAccelAvailable
                        ? () {
                            sm.stopLinearAccelerometer();
                            stopPullData();
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
