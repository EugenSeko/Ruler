import 'dart:async';
import 'dart:math';

import 'package:flutter_sensors/flutter_sensors.dart' as fs;

class SensorManager {
  List<double> _accelData = List.filled(3, 0.0);
  List<double> _gyroData = List.filled(3, 0.0);
  List<double> _linearAccelData = List.filled(3, 0.0);

  StreamSubscription? accelSubscription;
  StreamSubscription? gyroSubscription;
  StreamSubscription? linearAccelSubscription;

  bool accelAvailable = false;
  bool gyroAvailable = false;
  bool linearAccelAvailable = false;

  Duration accelDelay = fs.Sensors.SENSOR_DELAY_GAME;
  Duration gyroDelay = fs.Sensors.SENSOR_DELAY_GAME;
  Duration linearAccelDelay = fs.Sensors.SENSOR_DELAY_GAME;

  // bool get accelAvailable => _accelAvailable;
  // bool get gyroAvailable => _gyroAvailable;
  // bool get linearAccelAvailable => _linearAccelAvailable;

  List<double> get accelData => _accelData;
  List<double> get gyroData => _gyroData;
  List<double> get linearAccelData => _linearAccelData;

  double get tiltAngle => atan2(_accelData[1],
      sqrt(_accelData[0] * _accelData[0] + _accelData[2] * _accelData[2]));
  double get pitchAngle => atan2(-_accelData[0],
      sqrt(_accelData[1] * _accelData[1] + _accelData[2] * _accelData[2]));

  void checkAccelerometerStatus() async {
    await fs.SensorManager()
        .isSensorAvailable(fs.Sensors.ACCELEROMETER)
        .then((result) {
      accelAvailable = result;
    });
  }

  void checkGyroscopeStatus() async {
    await fs.SensorManager()
        .isSensorAvailable(fs.Sensors.GYROSCOPE)
        .then((result) {
      gyroAvailable = result;
    });
  }

  void checkLinearAccelerometerStatus() async {
    await fs.SensorManager()
        .isSensorAvailable(fs.Sensors.LINEAR_ACCELERATION)
        .then((result) {
      linearAccelAvailable = result;
    });
  }

  void stopAccelerometer() {
    if (accelSubscription == null) return;
    accelSubscription?.cancel();
    accelSubscription = null;
  }

  void stopGyroscope() {
    if (gyroSubscription == null) return;
    gyroSubscription?.cancel();
    gyroSubscription = null;
  }

  void stopLinearAccelerometer() {
    if (linearAccelSubscription == null) return;
    linearAccelSubscription?.cancel();
    linearAccelSubscription = null;
  }

  void stopAll() {
    stopAccelerometer();
    stopGyroscope();
    stopLinearAccelerometer();
  }

  Future<void> startAccelerometer() async {
    if (accelSubscription != null) return;
    if (accelAvailable) {
      final stream = await fs.SensorManager().sensorUpdates(
        sensorId: fs.Sensors.ACCELEROMETER,
        interval: accelDelay,
      );
      accelSubscription = stream.listen((sensorEvent) {
        _accelData = sensorEvent.data;
      });
    }
  }

  Future<void> startGyroscope() async {
    if (gyroSubscription != null) return;
    if (gyroAvailable) {
      final stream = await fs.SensorManager()
          .sensorUpdates(sensorId: fs.Sensors.GYROSCOPE, interval: gyroDelay);
      gyroSubscription = stream.listen((sensorEvent) {
        _gyroData = sensorEvent.data;
      });
    }
  }

  Future<void> startLinearAccelerometer() async {
    if (linearAccelSubscription != null) return;
    if (linearAccelAvailable) {
      final stream = await fs.SensorManager().sensorUpdates(
        sensorId: fs.Sensors.LINEAR_ACCELERATION,
        interval: linearAccelDelay,
      );
      linearAccelSubscription = stream.listen((sensorEvent) {
        _linearAccelData = sensorEvent.data;
      });
    }
  }
}
