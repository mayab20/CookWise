import 'dart:math';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/colors.dart'; 

class FloatingShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final color1 = AppColors.mainColor;
    final color2 = AppColors.secondaryColor;

    // TOP LEFT
    _drawShapeUnit(
      canvas,
      center: Offset(size.width * 0.12, size.height * 0.18),
      color: color1,
      width: 210,
      height: 130,
    );

    // TOP RIGHT
    _drawShapeUnit(
      canvas,
      center: Offset(size.width * 0.85, size.height * 0.15),
      color: color2,
      width: 170,
      height: 140,
    );

    // BOTTOM LEFT
    _drawShapeUnit(
      canvas,
      center: Offset(size.width * 0.18, size.height * 0.88),
      color: color2,
      width: 240,
      height: 110,
    );

    // BOTTOM RIGHT
    _drawShapeUnit(
      canvas,
      center: Offset(size.width * 0.78, size.height * 0.75),
      color: color1,
      width: 190,
      height: 125,
    );
  }

  void _drawShapeUnit(
    Canvas canvas, {
    required Offset center,
    required Color color,
    required double width,
    required double height,
  }) {
    final whiteFill = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255)
      ..style = PaintingStyle.fill;

    final mainPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // The "Black Lines" - using a thin stroke
    final linePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // 1. Draw the thin organic outline (slightly larger and rotated/offset)
    _drawBlob(
      canvas,
      linePaint,
      center.translate(5, -5),
      width * 1.2,
      height * 1.2,
      seed: color.value + 2,
    );

    // 2. Organic white "shadow" blob
    _drawBlob(
      canvas,
      whiteFill,
      center.translate(-8, 8),
      width * 1.12,
      height * 1.12,
      seed: color.value,
    );

    // 3. Main colored organic blob
    _drawBlob(
      canvas,
      mainPaint,
      center,
      width,
      height,
      seed: color.value + 1,
    );
  }

  void _drawBlob(
    Canvas canvas,
    Paint paint,
    Offset center,
    double width,
    double height, {
    required int seed,
  }) {
    final path = Path();
    final rand = Random(seed);
    const pointsCount = 8;
    final angleStep = (2 * pi) / pointsCount;

    List<Offset> points = [];
    for (int i = 0; i < pointsCount; i++) {
      final angle = i * angleStep;
      final rx = (width / 2) * (0.8 + rand.nextDouble() * 0.4);
      final ry = (height / 2) * (0.8 + rand.nextDouble() * 0.4);

      points.add(Offset(
        center.dx + cos(angle) * rx,
        center.dy + sin(angle) * ry,
      ));
    }

    path.moveTo(
      (points[0].dx + points[pointsCount - 1].dx) / 2,
      (points[0].dy + points[pointsCount - 1].dy) / 2,
    );

    for (int i = 0; i < pointsCount; i++) {
      final p1 = points[i];
      final p2 = points[(i + 1) % pointsCount];
      final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      path.quadraticBezierTo(p1.dx, p1.dy, mid.dx, mid.dy);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}