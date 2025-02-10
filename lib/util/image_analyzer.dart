import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

///function:
///@author:zhangteng
///@date:2025/2/3

class ImageAnalyzer {
  final BarcodeScanner _barcodeScanner = BarcodeScanner();

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? transCameraImage2InputImage(CameraImage image, CameraController controller) {
    final camera = controller.description;
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = _orientations[controller.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }

  bool _isProcessImage = false;

  Future<List<BarcodeData>?> analysisImage(InputImage inputImage) async {
    final barcodes = await _barcodeScanner.processImage(inputImage);
    if (barcodes.isEmpty) {
      return null;
    }

    if (_isProcessImage) {
      return null;
    }
    _isProcessImage = true;

    debugPrint('array length：${barcodes.length}');
    List<BarcodeData> list = barcodes.map((barcode) {
      debugPrint(
          'barcode result:${barcode.displayValue} - coordinate：${barcode.boundingBox.toString()}');
      // return barcode.displayValue ?? '';
      return BarcodeData(barcode.displayValue ?? '', barcode.boundingBox);
    }).toList();
    _isProcessImage = false;
    return list;
    // pausePreview();
    // if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
    //
    //   List<String> list = barcodes.map((barcode) => barcode.displayValue ?? '').toList();
    //   widget.onCodeList(list);
    //   stopLiveFeed();
    // } else {
    //   List<String> list = barcodes.map((barcode) => barcode.displayValue ?? '').toList();
    //   widget.onCodeList(list);
    //   stopLiveFeed();
    // }
  }
}

class BarcodeData {
  final String value;
  final Rect boundingBox;

  BarcodeData(this.value, this.boundingBox);
}
