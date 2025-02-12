import 'package:flutter/cupertino.dart';

///function:
///@author:zhangteng
///@date:2025/2/11

class WatermarkOption {
  final Widget watermarkWidget;

  final WatermarkPositionData positionData;

  WatermarkOption({required this.watermarkWidget, required this.positionData});
}

class WatermarkPositionData {
  final WatermarkPosition position;
  final double x;
  final double y;

  WatermarkPositionData({required this.position, this.x = 0, this.y = 0});
}

enum WatermarkPosition {
  topLeft,
  topRight,
  center,
  bottomLeft,
  bottomRight;
}
