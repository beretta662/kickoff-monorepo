import 'package:flutter/material.dart';

/// Dessine une bordure en pointillés autour d'un rectangle arrondi.
/// Réutilisé partout où on a besoin d'un cadre "optionnel/à compléter"
/// (choix de sport personnalisé, upload de logo, etc.), plutôt que
/// dupliqué à chaque écran.
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const DashedBorderPainter({required this.color, this.radius = 10});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    final dashPath = Path();

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        dashPath.addPath(metric.extractPath(distance, next.clamp(0, metric.length)), Offset.zero);
        distance = next + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}