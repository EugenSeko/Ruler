import 'dart:async';

class MyTimer {
  MyTimer(this._function);
  Timer? _timer;
  final void Function()? _function;

  void startTimer(Duration duration) {
    stopTimer();
    _timer = Timer.periodic(duration, (timer) {
      _function?.call();
    });
  }

  void stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }
}
