一个使用简单，代码量极少的flutter相机库,
支持拍照，录制视频，扫码，双指缩放功能,拍照加水印功能开发中

首先添加依赖
```
  flutter_camerax:
    git:
      url: https://github.com/cgztzero/FlutterCameraX.git
```

1.第一步创建一个相机Controller
```
final CameraXController _controller = CameraXController();
```

2.第二步在页面中创建相机预览widget，并和Controller绑定
```
CameraPreviewWidget(
  cameraController: _controller,
  cameraOption: CameraOption(camera: CameraType.back),//相机参数，可以不设置
  width: 100,//预览的宽高，也可以不设置，
  height: 100,
  cameraCallBack: (int? code, String? message) {
     //相机错误的回调，可以不设置           
  },
  //切换摄像头，初始化等耗时操作的loading，可以自定义	
  loadingWidget: const SizedBox(
     width: 50,
     height: 50,
     child: CircularProgressIndicator(),
  ),	
)
```

3.可以通过Controller进行相关操作了

	拍照的方法
```
_button(
 text: 'TakePicture',
 onTap: () async {
   final image = await _controller.takePicture();
   debugPrint('image file path:${image?.path}');
   },
)
```

	切换摄像头
```
_button(text: 'switch', onTap: () => _controller.switchCamera()),
```
	录制视频
```
if (_controller.isRecording()) {
 _controller.stopRecording();
} else {
 _controller.startVideoRecording(
   max: 60,//视频录制最长时间，单位秒，不设置则没有限制 
   onRecordFinish: (file) => debugPrint('video file path:${file.path}'),
 );
}
```

	相机一些初始化参数
```
CameraOption(
  camera: CameraType.back,//摄像头类型 默认back
  resolutionPresetType: ResolutionPresetType.veryHigh,//图片质量 默认high
  enableAudio: true,//是否可以录音 默认false
  flashType: FlashType.auto,//闪光灯 默认auto
)
```
	支持扫描二维码只需要新增一个预览回调即可
```
CameraPreviewWidget(
  cameraController: _controller,
  cameraOption: CameraOption(
       camera: CameraType.back,
       resolutionPresetType: ResolutionPresetType.veryHigh,
       enableAudio: true,
       flashType: FlashType.auto,
    ),
  onScanSuccess: (list) {
    //遍历list即可,因为一张图片里可能有多个二维码
  },
)
```
	也可以用Controller暂停/开启预览
```
_controller.pausePreview();
_controller.resumePreview();

``` 
  

	
