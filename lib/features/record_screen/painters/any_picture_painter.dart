import 'package:flutter/material.dart';

class AnyPicturePainter extends CustomPainter {
  final Paint _paintLine = Paint()
    ..color = Colors.blueGrey
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), //80, 400),
        Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.stroke
    );

    canvas.drawCircle(const Offset(100, 100), 100, _paintLine);
    canvas.drawCircle(const Offset(150, 160), 80,
        Paint()
          ..color = Colors.cyan
          ..style = PaintingStyle.fill
    );
    canvas.drawLine(const Offset(20, 20), const Offset(120, 130),
        Paint()..color = Colors.red);
  } // paint

  @override
  bool shouldRepaint(AnyPicturePainter oldDelegate) => false;
}

