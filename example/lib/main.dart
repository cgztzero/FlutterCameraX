import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camerax/camera_view.dart';
import 'package:flutter_camerax/const/camera_constant.dart';
import 'package:flutter_camerax/controller/camera_controller.dart';
import 'package:flutter_camerax/option/camera_option.dart';
import 'package:flutter_camerax/option/water_mark_option.dart';
import 'dart:ui' as ui;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CameraXController _controller = CameraXController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: CameraPreviewWidget(
              cameraController: _controller,
              cameraOption: CameraOption(
                camera: CameraType.back,
                resolutionPresetType: ResolutionPresetType.veryHigh,
                enableAudio: true,
                flashType: FlashType.auto,
              ),
              watermarkOption: WatermarkOption(
                watermarkWidget: Text(
                  'This is watermark text!!!',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                positionData: WatermarkPositionData(
                  position: WatermarkPosition.topLeft,
                  x: 100,
                  y: 100,
                ),
              ),
              onScanSuccess: (list) {
                for (var barcode in list) {
                  debugPrint('barcode value:${barcode.value} - box:${barcode.boundingBox}');
                }
              },
            ),
          ),
          Row(
            children: [
              _button(
                text: 'TakePicture',
                onTap: () async {
                  final image = await _controller.takePicture();
                  debugPrint('image file path:${image?.path}');
                },
              ),
              _button(text: 'switch', onTap: () => _controller.switchCamera()),
              _button(
                text: 'record/stop',
                onTap: () {
                  if (_controller.isRecording()) {
                    _controller.stopRecording();
                  } else {
                    _controller.startVideoRecording(
                      max: 60,
                      onRecordFinish: (file) => debugPrint('video file path:${file.path}'),
                    );
                  }
                },
              ),
              _button(
                text: 'water',
                onTap: () async {
                  final image = await _controller.takePictureWithWatermark();
                  if (image == null) {
                    return;
                  }
                  Navigator.push(context, CupertinoPageRoute(
                    builder: (cxt) {
                      return ImageResultPage(image: image);
                    },
                  ));
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _button({required String text, required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      child: Center(
        child: Text(text),
      ),
    );
  }
}

class ImageResultPage extends StatelessWidget {
  final ui.Image image;

  const ImageResultPage({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image'),
      ),
      body: Center(
        child: RawImage(
          image: image,
        ),
      ),
    );
  }
}
