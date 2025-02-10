import 'package:camera/camera.dart';
import 'package:flutter_camerax/const/camera_constant.dart';

///function:
///@author:zhangteng
///@date:2025/1/23

class CameraOption {
  final CameraType camera;
  final ResolutionPresetType resolutionPresetType;
  final bool enableAudio;
  final FlashType flashType;

  CameraOption({
    this.camera = CameraType.back,
    this.resolutionPresetType = ResolutionPresetType.high,
    this.enableAudio = false,
    this.flashType = FlashType.auto,
  });
}
