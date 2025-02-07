///function:
///@author:zhangteng
///@date:2025/1/23

abstract class CameraCallBack {
  void onCameraError(int? code, String? message);
}

abstract class TimerCallBack {
  void onTimerFinish();

  void onTiming(int current, int max);
}
