import 'package:flutter/material.dart';

class BackgroundLineArtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color.fromARGB(255, 5, 37, 63).withOpacity(0.08)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

    // Top left corner circles
    canvas.drawCircle(Offset(-50, size.height * 0.1), 80, paint);
    canvas.drawCircle(Offset(size.width * 0.15, -30), 100, paint);

    // Top right wavy lines
    final path1 = Path();
    path1.moveTo(size.width * 0.7, 0);
    path1.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.08,
      size.width,
      size.height * 0.15,
    );
    canvas.drawPath(path1, paint);

    final path2 = Path();
    path2.moveTo(size.width * 0.8, 0);
    path2.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.05,
      size.width,
      size.height * 0.08,
    );
    canvas.drawPath(path2, paint);

    // Bottom left curved lines
    final path3 = Path();
    path3.moveTo(0, size.height * 0.8);
    path3.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.85,
      size.width * 0.3,
      size.height,
    );
    canvas.drawPath(path3, paint);

    // Bottom right circles
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.9), 60, paint);
    canvas.drawCircle(Offset(size.width + 30, size.height * 0.95), 90, paint);

    // Diagonal accent line
    final path4 = Path();
    path4.moveTo(size.width * 0.1, size.height * 0.4);
    path4.lineTo(size.width * 0.3, size.height * 0.5);
    canvas.drawPath(path4, paint);

    // Small dots scattered
    final dotPaint =
        Paint()
          ..color = Colors.blue.withOpacity(0.1)
          ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 4, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.4), 4, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.7), 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
