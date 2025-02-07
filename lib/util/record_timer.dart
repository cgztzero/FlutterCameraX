import 'dart:async';

import 'package:flutter_camerax/callback/camera_callback.dart';


///function:
///@author:zhangteng
///@date:2025/2/1

class RecordTimer {
  Timer? _timer;
  bool _isTiming = false;
  int _maxTime = 60;
  int _currentTime = 0;
  TimerCallBack? timerCallBack;

  RecordTimer({this.timerCallBack});

  void startTimer({int second = 1, int max = -1}) {
    if (_isTiming) {
      return;
    }
    _isTiming = true;
    Duration duration = Duration(seconds: second);
    _maxTime = max;
    _timer = Timer.periodic(duration, (timer) {
      _currentTime++;
      timerCallBack?.onTiming(_currentTime, _maxTime);
      if (_currentTime == _maxTime) {
        stopTimer();
      }
    });
  }

  void stopTimer() {
    timerCallBack?.onTimerFinish();
    _currentTime = 0;
    _isTiming = false;
    _timer?.cancel();
  }

  void dispose(){
    timerCallBack = null;
    stopTimer();
  }
}
