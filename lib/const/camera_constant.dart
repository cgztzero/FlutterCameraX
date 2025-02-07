import 'package:camera/camera.dart';

///function:
///@author:zhangteng
///@date:2025/1/23

class CameraErrorCode {
  static const int noCameraFound = -1;
  static const int initFlutterControllerFail = -2;
  static const int commonException = -999;
}

enum CameraType {
  front,
  back,
  external;

  static CameraLensDirection toFlutterCameraLensDirection(CameraType type) {
    if (type == CameraType.front) {
      return CameraLensDirection.front;
    } else if (type == CameraType.back) {
      return CameraLensDirection.back;
    } else {
      return CameraLensDirection.external;
    }
  }
}

enum FlashType {
  off,
  auto,
  always,
  torch;

  static FlashMode toFlutterFlashMode(FlashType type) {
    switch (type) {
      case FlashType.off:
        return FlashMode.off;
      case FlashType.auto:
        return FlashMode.auto;
      case FlashType.always:
        return FlashMode.always;
      case FlashType.torch:
        return FlashMode.torch;
    }
  }
}
