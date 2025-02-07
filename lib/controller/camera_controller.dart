import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_camerax/callback/camera_callback.dart';
import 'package:flutter_camerax/util/record_timer.dart';

///function:
///@author:zhangteng
///@date:2025/1/23

class CameraXController extends ValueNotifier<CameraStatus> with TimerCallBack {
  CameraController? _controller;

  CameraXController() : super(CameraStatus.loading);

  final List<CameraDescription> _cameras = [];
  ValueChanged<XFile>? _onRecordFinish;
  RecordTimer? _timer;

  void addCameras(List<CameraDescription> list) {
    _cameras.clear();
    _cameras.addAll(list);
  }

  List<CameraDescription> getAllCameras() {
    return _cameras;
  }

  void bindFlutterController(CameraController controller) {
    _controller = controller;
  }

  bool isInitialized() {
    return _controller != null && _controller!.value.isInitialized;
  }

  CameraController? getFlutterController() {
    return _controller;
  }

  Future<bool> initialize() async {
    try {
      _checkController();
      _changeCameraStatus(CameraStatus.loading);
      await _controller!.initialize();
      return true;
    } on Exception {
      return false;
    } finally {
      value = CameraStatus.normal;
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    _checkController();
    _changeCameraStatus(CameraStatus.changingFlash);
    await _controller!.setFlashMode(mode);
    _toNormal();
  }

  Future<double> getMinZoomLevel() {
    _checkController();
    return _controller!.getMinZoomLevel();
  }

  Future<double> getMaxZoomLevel() {
    _checkController();
    return _controller!.getMaxZoomLevel();
  }

  Future<bool> switchCamera() async {
    _checkController();
    final lensDirection = _controller!.description.lensDirection;
    final queryDirection = lensDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    final list = getAllCameras();
    final resultCamera = list.firstWhere((element) => element.lensDirection == queryDirection);
    _changeCameraStatus(CameraStatus.changingCamera);
    bool isOK = await initController(
      resultCamera,
      _controller!.resolutionPreset,
      _controller!.enableAudio,
      _controller!.imageFormatGroup,
      _controller!.value.flashMode,
    );
    return isOK;
  }

  bool isRecording() {
    _checkController();
    return _controller!.value.isRecordingVideo;
  }

  bool isStreamingImages() {
    _checkController();
    return _controller!.value.isStreamingImages;
  }

  CameraValue getCameraValue() {
    _checkController();
    return _controller!.value;
  }

  void startVideoRecording({
    required ValueChanged<XFile> onRecordFinish,
    int second = 1,
    int max = -1,
  }) async {
    if (isRecording()) {
      return;
    }
    _onRecordFinish = onRecordFinish;
    await _controller!.prepareForVideoRecording();
    _controller!.startVideoRecording();
    _timer ??= RecordTimer(timerCallBack: this);
    _timer?.startTimer(second: second, max: max);
  }

  Future<bool> stopRecording() async {
    if (!isRecording()) {
      return false;
    }
    _checkController();
    XFile result = await _controller!.stopVideoRecording();
    _onRecordFinish?.call(result);
    _timer?.stopTimer();
    return true;
  }

  Future<bool> initController(
    CameraDescription camera,
    ResolutionPreset resolutionPreset,
    bool enableAudio,
    ImageFormatGroup? imageFormatGroup,
    FlashMode mode,
  ) {
    _controller = CameraController(
      camera,
      resolutionPreset,
      enableAudio: enableAudio,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );
    _controller!.setFlashMode(mode);
    bindFlutterController(_controller!);
    _toNormal();
    return initialize();
  }

  void setZoomLevel(double scale) {
    try {
      _checkController();
      _controller!.setZoomLevel(scale);
    } on CameraException catch (e) {
      throw Exception('setZoomLevel Exception:${e.description}');
    }
  }

  Future<XFile?> takePicture() async {
    _checkController();
    bool isOK = isInitialized();
    if (!isOK) {
      return null;
    }
    return _controller!.takePicture();
  }

  void startImageStream(onLatestImageAvailable onAvailable) {
    if (isRecording()) {
      return;
    }
    _controller!.startImageStream(onAvailable);
  }

  void _checkController() {
    if (_controller == null) {
      throw Exception('Please bind flutter CameraController');
    }
  }

  void _toNormal() {
    _changeCameraStatus(CameraStatus.normal);
  }

  void _changeCameraStatus(CameraStatus status) {
    value = status;
  }

  void pausePreview() {
    _controller?.pausePreview();
  }

  void resumePreview() {
    _controller?.resumePreview();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.dispose();
    _controller?.dispose();
  }

  @override
  void onTimerFinish() {
    stopRecording();
  }

  @override
  void onTiming(int current, int max) {}
}

enum CameraStatus {
  loading,
  changingCamera,
  changingFlash,
  normal,
}
