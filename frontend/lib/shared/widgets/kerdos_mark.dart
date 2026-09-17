import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Compact static Kerdos logomark: three nodes in a triangle, two joined
/// by a solid edge and one by a dashed edge — "a network, with one
/// relationship still being watched." Used in app bars and anywhere the
/// full entry animation would be too heavy.
class KerdosMark extends StatelessWidget {
  const KerdosMark({super.key, this.size = 28, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MarkPainter(color: color ?? AppColors.ledger),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final top = Offset(size.width * 0.5, size.height * 0.08);
    final left = Offset(size.width * 0.12, size.height * 0.88);
    final right = Offset(size.width * 0.88, size.height * 0.88);

    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..strokeWidth = size.width * 0.07
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(top, left, linePaint);
    canvas.drawLine(top, right, linePaint);

    final dashPaint = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..strokeWidth = size.width * 0.07
      ..strokeCap = StrokeCap.round;
    _drawDashedLine(canvas, left, right, dashPaint);

    final nodePaint = Paint()..color = color;
    final nodeRadius = size.width * 0.09;
    canvas.drawCircle(top, nodeRadius, nodePaint);
    canvas.drawCircle(left, nodeRadius, nodePaint);
    canvas.drawCircle(right, nodeRadius, nodePaint);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    final total = (end - start).distance;
    final direction = (end - start) / total;
    double covered = 0;
    while (covered < total) {
      final segmentEnd = (covered + dashWidth).clamp(0, total);
      canvas.drawLine(
        start + direction * covered,
        start + direction * segmentEnd.toDouble(),
        paint,
      );
      covered += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _MarkPainter oldDelegate) =>
      oldDelegate.color != color;
}