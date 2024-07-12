import 'package:flutter/material.dart';

class BarDiagramPainter extends CustomPainter {
  BarDiagramPainter(this._value);


  final Paint _paintFill = Paint()
    ..color = Colors.blueGrey
    ..style = PaintingStyle.fill;

  final Paint _paintBorder = Paint()
    ..color = Colors.black54
    ..style = PaintingStyle.stroke;

  double _value = 0;
  final int _diap = 100;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(size.width / 2, 0, (_value / _diap) * size.width / 2, size.height),
        _paintFill
    );

    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        _paintBorder
    );
  } // paint

  @override
  bool shouldRepaint(BarDiagramPainter oldDelegate) => false;

}
