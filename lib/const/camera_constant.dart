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

enum ResolutionPresetType {
  /// 352x288 on iOS, 240p (320x240) on Android and Web
  low,

  /// 480p (640x480 on iOS, 720x480 on Android and Web)
  medium,

  /// 720p (1280x720)
  high,

  /// 1080p (1920x1080)
  veryHigh,

  /// 2160p (3840x2160 on Android and iOS, 4096x2160 on Web)
  ultraHigh,

  /// The highest resolution available.
  max;

  static ResolutionPreset toFlutterResolutionPreset(ResolutionPresetType type) {
    switch (type) {
      case ResolutionPresetType.low:
        return ResolutionPreset.low;
      case ResolutionPresetType.medium:
        return ResolutionPreset.medium;
      case ResolutionPresetType.high:
        return ResolutionPreset.high;
      case ResolutionPresetType.veryHigh:
        return ResolutionPreset.veryHigh;
      case ResolutionPresetType.ultraHigh:
        return ResolutionPreset.ultraHigh;
      case ResolutionPresetType.max:
        return ResolutionPreset.max;
    }
  }
}
