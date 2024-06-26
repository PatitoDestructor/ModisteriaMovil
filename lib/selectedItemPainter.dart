import 'package:flutter/material.dart';

class SelectedItemPainter extends CustomPainter {
  final int selectedIndex;
  final Color color;

  SelectedItemPainter({required this.selectedIndex, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2.0;

    double startX = (size.width / 3) * selectedIndex;
    double startY = size.height - 2.0;
    double endX = startX + (size.width / 3);
    double endY = startY;

    canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
