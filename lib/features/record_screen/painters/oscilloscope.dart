import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:process_control/repositories/process_params.dart';

const double LeftBorder = 15;
const double RightBorder = 1;
const double TopBorder = 5;
const double BottomBorder = 5;

List<DataBlock> _data = [];
int pos = LeftBorder.toInt();
int shift = 0;

class Oscilloscope extends CustomPainter {
  Oscilloscope(this.values, this.min, this.max) {
    _data.addAll(values);
    shift += values.length;
    values.clear();
  }

  late List<DataBlock> values;
  late double min;
  late double max;
  final Paint _paintFrame = Paint()
    ..color = Colors.black87
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  final Paint _paintAxis = Paint()..color = Colors.black87..strokeWidth = 1;
  final Paint _paintMarker = Paint()..color = Colors.red..strokeWidth = 1;
  final Paint _paintGraph = Paint()..color = Colors.blue.shade900..strokeWidth = 1;

  Paragraph createText(String text) {
    final builder = ParagraphBuilder(ParagraphStyle(fontSize: 20));
    builder.addText(text);
    return builder.build();
  }
  
  @override
  void paint(Canvas canvas, Size size) {
    // Рамка
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), _paintFrame);

    double zoneHeight = size.height / 3;
    canvas.drawLine(Offset(0, zoneHeight), Offset(size.width, zoneHeight), _paintAxis);
    canvas.drawLine(Offset(0, zoneHeight * 2), Offset(size.width, zoneHeight * 2), _paintAxis);

    var par = createText('X')..layout(const ParagraphConstraints(width: 20));
    canvas.drawParagraph(par, Offset(0, zoneHeight / 2));
    par = createText('Y')..layout(const ParagraphConstraints(width: 20));
    canvas.drawParagraph(par, Offset(0, zoneHeight * 3 / 2));
    par = createText('Z')..layout(const ParagraphConstraints(width: 20));
    canvas.drawParagraph(par, Offset(0, zoneHeight * 5 / 2));

    // Оси
    // canvas.drawLine(
    //     const Offset(LeftBorder, TopBorder), Offset(LeftBorder, size.height - BottomBorder), _paintAxis);
    // canvas.drawLine(Offset(LeftBorder, size.height - BottomBorder),
    //     Offset(size.width - RightBorder, size.height - BottomBorder), _paintAxis);

    var length = size.width - RightBorder - LeftBorder;

    // Коррекция длины массива
    if (_data.length > length) {
      _data.removeRange(0, (_data.length - length).toInt());
    }

    // Начальная точка построения
    pos += shift;
    if (pos > size.width - RightBorder) {
      pos = LeftBorder.toInt();
    }
    shift = 0;

    int l = _data.length;

    double prop = (zoneHeight - BottomBorder - TopBorder) / (max - min).toDouble();
    double x = pos.toDouble();
    for (int i = _data.length - 1; i > 0; --i){
      var p1 = Offset(x, zoneHeight - BottomBorder - (_data[i].ax-min).toDouble() * prop);
      var p2 = Offset(x-1, zoneHeight - BottomBorder - (_data[i-1].ax-min).toDouble() * prop);
      canvas.drawLine(p1, p2, _paintGraph);

      p1 = Offset(x, zoneHeight * 2 - BottomBorder - (_data[i].ay-min).toDouble() * prop);
       p2 = Offset(x-1, zoneHeight * 2 - BottomBorder - (_data[i-1].ay-min).toDouble() * prop);
      canvas.drawLine(p1, p2, _paintGraph);

      p1 = Offset(x, size.height - BottomBorder - (_data[i].az-min).toDouble() * prop);
      p2 = Offset(x-1, size.height - BottomBorder - (_data[i-1].az-min).toDouble() * prop);
      canvas.drawLine(p1, p2, _paintGraph);

      x -= 1;
      if (x <= LeftBorder){
        x = size.width - RightBorder;
      }
    }

    // print('-----------------------------');

    // Маркер
    canvas.drawLine(Offset(pos.toDouble(), TopBorder),
        Offset(pos.toDouble(), size.height - BottomBorder),
        _paintMarker);

  } // paint

  @override
  bool shouldRepaint(Oscilloscope oldDelegate) => false;
}
