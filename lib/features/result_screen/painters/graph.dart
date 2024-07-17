import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:process_control/repositories/process_params.dart';

const double LeftBorder = 15;
const double RightBorder = 3;
const double TopBorder = 5;
const double BottomBorder = 5;


class Graph extends CustomPainter {
  Graph(this.values, this.freq) {
  }

  late List<DataBlock> values;
  late int freq;
  late double min = -100;
  late double max = 100;
  final Paint _paintFrame = Paint()
    ..color = Colors.black87
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  final Paint _paintAxis = Paint()..color = Colors.black87..strokeWidth = 1;
  final Paint _paintGrid = Paint()..color = Colors.black45..style = PaintingStyle.stroke;
  final Paint _paintGraph = Paint()..color = Colors.blue.shade900..strokeWidth = 1;

  Paragraph createText(String text) {
    final builder = ParagraphBuilder(ParagraphStyle(fontSize: 12));
    builder.addText(text);
    return builder.build();
  }

  @override
  void paint(Canvas canvas, Size size) {
    min = 100000;
    max = -100000;
    for (int i = 0; i < values.length - 1; ++i){
      if (values[i].ax < min) {min = values[i].ax;}
      if (values[i].ax > max) {max = values[i].ax;}
      if (values[i].ay < min) {min = values[i].ay;}
      if (values[i].ay > max) {max = values[i].ay;}
      if (values[i].az < min) {min = values[i].az;}
      if (values[i].az > max) {max = values[i].az;}
    }

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

    double prop = (zoneHeight - BottomBorder - TopBorder) / (max - min).toDouble();
    double step = (size.width - LeftBorder - RightBorder) / values.length.toDouble();

    for (int i = 0; i < values.length - 1; ++i){
      double x1 = LeftBorder + i * step;
      double x2 = LeftBorder + (i + 1) * step;

      var p1 = Offset(x1, zoneHeight - BottomBorder - (values[i].ax-min).toDouble() * prop);
      var p2 = Offset(x2, zoneHeight - BottomBorder - (values[i+1].ax-min).toDouble() * prop);
      canvas.drawLine(p1, p2, _paintGraph);

      p1 = Offset(x1, zoneHeight * 2 - BottomBorder - (values[i].ay-min).toDouble() * prop);
      p2 = Offset(x2, zoneHeight * 2 - BottomBorder - (values[i+1].ay-min).toDouble() * prop);
      canvas.drawLine(p1, p2, _paintGraph);

      p1 = Offset(x1, size.height - BottomBorder - (values[i].az-min).toDouble() * prop);
      p2 = Offset(x2, size.height - BottomBorder - (values[i+1].az-min).toDouble() * prop);
      canvas.drawLine(p1, p2, _paintGraph);

      if ((i+1) % freq == 0) {
        p1 = Offset(x2, TopBorder);
        p2 = Offset(x2, size.height - BottomBorder);
        canvas.drawLine(p1, p2, _paintGrid);

        par = createText(((i+1) / freq).toString())..layout(const ParagraphConstraints(width: 20));
        canvas.drawParagraph(par, Offset(x2 + 2, size.height - BottomBorder - 12));
      }
   }
  } // paint

  @override
  bool shouldRepaint(Graph oldDelegate) => false;
}
