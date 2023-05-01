import 'dart:async';
import 'dart:math';

import 'package:flutter_sensors/flutter_sensors.dart' as fs;

class SensorManager {
  List<double> _accelData = List.filled(3, 0.0);
  StreamSubscription? accelSubscription;
  bool _accelAvailable = false;

  List<double> get accelData => _accelData;
  double get tiltAngle => atan2(_accelData[1],
      sqrt(_accelData[0] * _accelData[0] + _accelData[2] * _accelData[2]));
  double get pitchAngle => atan2(-_accelData[0],
      sqrt(_accelData[1] * _accelData[1] + _accelData[2] * _accelData[2]));

  void checkAccelerometerStatus() async {
    await fs.SensorManager()
        .isSensorAvailable(fs.Sensors.ACCELEROMETER)
        .then((result) {
      _accelAvailable = result;
    });
  }

  void stopAccelerometer() {
    if (accelSubscription == null) return;
    accelSubscription?.cancel();
    accelSubscription = null;
  }

  Future<void> startAccelerometer() async {
    if (accelSubscription != null) return;
    if (_accelAvailable) {
      final stream = await fs.SensorManager().sensorUpdates(
        sensorId: fs.Sensors.ACCELEROMETER,
        interval: fs.Sensors.SENSOR_DELAY_FASTEST,
      );
      accelSubscription = stream.listen((sensorEvent) {
        _accelData = sensorEvent.data;
      });
    }
  }
}
