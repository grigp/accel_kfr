

import 'package:flutter/material.dart';

const double LeftBorder = 15;
const double RightBorder = 1;
const double TopBorder = 5;
const double BottomBorder = 5;

class Histogram extends CustomPainter{
  Histogram({required this.data, required this.max}){}
  List<double> data;
  double max;

  final Paint _paintFrame = Paint()
    ..color = Colors.black87
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  final Paint _paintGraph = Paint()..color = Colors.blue.shade900..strokeWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    // Рамка
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), _paintFrame);

    // Пропорции
    double widthOne = (size.width - RightBorder - LeftBorder) / data.length;
    double prop = (size.height - BottomBorder - TopBorder) / max;

    // Сама диаграмма
    for(int i = 0; i < data.length; ++i){
      double x = LeftBorder + i * widthOne + widthOne / 2;
      canvas.drawRect(
          Rect.fromLTRB(x - (widthOne / 2 - 2), size.height - BottomBorder - data[i] * prop,
                        x + (widthOne / 2 - 2), size.height - BottomBorder),
          _paintGraph
      );
    }
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}