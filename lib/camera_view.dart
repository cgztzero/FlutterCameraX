import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camerax/callback/camera_callback.dart';
import 'package:flutter_camerax/const/camera_constant.dart';
import 'package:flutter_camerax/controller/camera_controller.dart';
import 'package:flutter_camerax/option/camera_option.dart';
import 'package:flutter_camerax/option/water_mark_option.dart';
import 'package:flutter_camerax/util/image_analyzer.dart';

///function:
///@author:zhangteng
///@date:2025/1/23

class CameraPreviewWidget extends StatefulWidget {
  final CameraXController cameraController;
  final CameraCallBack? cameraCallBack;
  final double? width;
  final double? height;
  final CameraOption? cameraOption;
  final ValueChanged<List<BarcodeData>>? onScanSuccess;
  final Widget? loadingWidget;
  final WatermarkOption? watermarkOption;

  const CameraPreviewWidget({
    super.key,
    required this.cameraController,
    this.cameraCallBack,
    this.width,
    this.height,
    this.cameraOption,
    this.onScanSuccess,
    this.loadingWidget,
    this.watermarkOption,
  });

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  double _currentZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  ImageAnalyzer? _imageAnalyzer;
  final GlobalKey _waterKey = GlobalKey();
  final GlobalKey _previewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CameraStatus>(
      valueListenable: widget.cameraController,
      builder: (cxt, status, Widget? child) {
        return Container(
          color: Colors.black,
          width: widget.width,
          height: widget.height,
          child: _centerWidget(status),
        );
      },
    );
  }

  Widget _centerWidget(CameraStatus status) {
    switch (status) {
      case CameraStatus.loading:
      case CameraStatus.changingCamera:
      case CameraStatus.changingFlash:
        return Center(
          child: widget.loadingWidget ?? const SizedBox(),
        );
      case CameraStatus.normal:
        _initControllerParams();
        return _normalWidget();
    }
  }

  Widget _normalWidget() {
    Widget result = GestureDetector(
      onScaleUpdate: (detail) => _zoom(detail),
      child: CameraPreview(
        widget.cameraController.getFlutterController()!,
        key: _previewKey,
      ),
    );
    if (widget.watermarkOption != null) {
      result = Stack(
        fit: StackFit.expand,
        children: [
          result,
          _getWatermarkWidget(),
        ],
      );
    }
    return result;
  }

  Widget _getWatermarkWidget() {
    WatermarkPositionData data = widget.watermarkOption!.positionData;
    Widget realWater = RepaintBoundary(
      key: _waterKey,
      child: widget.watermarkOption!.watermarkWidget,
    );
    Widget waterWidget;
    switch (data.position) {
      case WatermarkPosition.topLeft:
        waterWidget = Positioned(left: data.x, top: data.y, child: realWater);
        break;
      case WatermarkPosition.topRight:
        waterWidget = Positioned(right: data.x, top: data.y, child: realWater);
        break;
      case WatermarkPosition.center:
        waterWidget = Center(child: realWater);
        break;
      case WatermarkPosition.bottomLeft:
        waterWidget = Positioned(left: data.x, bottom: data.y, child: realWater);
        break;
      case WatermarkPosition.bottomRight:
        waterWidget = Positioned(right: data.x, bottom: data.y, child: realWater);
        break;
    }

    widget.cameraController.setWaterWidgetKey(_previewKey,_waterKey, widget.watermarkOption!.positionData);
    return waterWidget;
  }

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  void _initCamera() async {
    final list = await availableCameras();
    widget.cameraController.addCameras(list);
    if (list.isEmpty) {
      _errorCallBack(CameraErrorCode.noCameraFound, 'No camera found');
      return;
    }
    _startLiveFeed();
  }

  void _startLiveFeed() async {
    try {
      final CameraType cameraType;
      if (widget.cameraOption?.camera != null) {
        cameraType = widget.cameraOption!.camera;
      } else {
        cameraType = CameraType.back;
      }
      final CameraLensDirection cameraLensDirection =
          CameraType.toFlutterCameraLensDirection(cameraType);
      final camera = widget.cameraController.getAllCameras().firstWhere(
            (element) => element.lensDirection == cameraLensDirection,
          );
      bool isOK = await widget.cameraController.initController(
        camera,
        ResolutionPresetType.toFlutterResolutionPreset(
            widget.cameraOption?.resolutionPresetType ?? ResolutionPresetType.high),
        widget.cameraOption?.enableAudio ?? true,
        FlashType.toFlutterFlashMode(widget.cameraOption?.flashType ?? FlashType.auto),
      );
      if (!isOK) {
        _errorCallBack(
          CameraErrorCode.initFlutterControllerFail,
          'init flutter CameraController fail',
        );
      }
    } on StateError {
      _errorCallBack(CameraErrorCode.noCameraFound, 'No Camera found');
    } on Exception catch (e) {
      _errorCallBack(CameraErrorCode.commonException, '$e');
    }
  }

  Future<void> _initControllerParams() async {
    double minZoomLevel = await widget.cameraController.getMinZoomLevel();
    _currentZoomLevel = minZoomLevel;
    _minAvailableZoom = minZoomLevel;
    double maxZoomLevel = await widget.cameraController.getMaxZoomLevel();
    _maxAvailableZoom = maxZoomLevel;
    if (widget.onScanSuccess != null) {
      _imageAnalyzer ??= ImageAnalyzer();
      if (!widget.cameraController.isStreamingImages()) {
        widget.cameraController.startImageStream(_processCameraImage);
      }
    }
  }

  void _processCameraImage(CameraImage image) async {
    final inputImage = _imageAnalyzer?.transCameraImage2InputImage(
        image, widget.cameraController.getFlutterController()!);
    if (inputImage == null) {
      return;
    }
    List<BarcodeData>? result = await _imageAnalyzer?.analysisImage(inputImage);
    if (result == null) return;
    widget.onScanSuccess?.call(result);
  }

  void _zoom(ScaleUpdateDetails detail) {
    var scale = detail.scale.clamp(_minAvailableZoom, _maxAvailableZoom);
    if (_currentZoomLevel == scale) {
      return;
    }
    _currentZoomLevel = scale;
    widget.cameraController.setZoomLevel(scale);
  }

  void _errorCallBack(int code, String message) {
    widget.cameraCallBack?.call(code, message);
  }

  @override
  void dispose() {
    super.dispose();
    widget.cameraController.dispose();
  }
}
