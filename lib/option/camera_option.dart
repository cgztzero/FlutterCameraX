import 'package:camera/camera.dart';
import 'package:flutter_camerax/const/camera_constant.dart';

///function:
///@author:zhangteng
///@date:2025/1/23

class CameraOption {
  final CameraType camera;
  final ResolutionPreset resolutionPreset;
  final bool enableAudio;
  final ImageFormatGroup? imageFormat;
  final FlashType flashType;

  CameraOption({
    this.camera = CameraType.back,
    this.resolutionPreset = ResolutionPreset.high,
    this.enableAudio = false,
    this.imageFormat,
    this.flashType = FlashType.auto,
  });
}
