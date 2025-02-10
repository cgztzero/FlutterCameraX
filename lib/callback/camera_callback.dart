///function:
///@author:zhangteng
///@date:2025/1/23

typedef CameraCallBack = void Function(int? code, String? message);

abstract class TimerCallBack {
  void onTimerFinish();

  void onTiming(int current, int max);
}
