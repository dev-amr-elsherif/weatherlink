import 'dart:math';
import 'package:flutter/material.dart';

class SparklineChart extends StatelessWidget {
  final List<double> data;
  final Color lineColor;
  final Color gradientColor;
  final Color glowColor;

  const SparklineChart({
    super.key,
    required this.data,
    required this.lineColor,
    required this.gradientColor,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    
    return CustomPaint(
      size: const Size.fromHeight(60), // Match the desired height
      painter: SparklinePainter(
        data: data,
        lineColor: lineColor,
        gradientColor: gradientColor,
        glowColor: glowColor,
      ),
    );
  }
}

class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final Color gradientColor;
  final Color glowColor;

  SparklinePainter({
    required this.data,
    required this.lineColor,
    required this.gradientColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double maxVal = data.reduce(max);
    final double minVal = data.reduce(min);
    final double range = (maxVal - minVal) == 0 ? 1 : (maxVal - minVal);

    final double xStep = size.width / (data.length > 1 ? data.length - 1 : 1);

    final Path path = Path();
    final Path fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final double x = i * xStep;
      final double normalizedY = (data[i] - minVal) / range;
      final double y = size.height - (normalizedY * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        // Use bezier curves for smooth lines
        final prevX = (i - 1) * xStep;
        final prevNormalizedY = (data[i - 1] - minVal) / range;
        final prevY = size.height - (prevNormalizedY * size.height);
        
        final controlX1 = prevX + (xStep / 2);
        final controlY1 = prevY;
        final controlX2 = x - (xStep / 2);
        final controlY2 = y;
        
        path.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
        fillPath.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      }
      
      if (i == data.length - 1) {
        fillPath.lineTo(x, size.height);
      }
    }

    fillPath.close();

    // Draw the gradient fill
    final paintFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          gradientColor,
          const Color(0x00000000), // Transparent ending
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, paintFill);

    // Draw the glowing shadow line
    final paintGlow = Paint()
      ..color = glowColor
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      
    canvas.drawPath(path, paintGlow);

    // Draw the main line
    final paintLine = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
      
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) {
    return oldDelegate.data != data ||
           oldDelegate.lineColor != lineColor ||
           oldDelegate.gradientColor != gradientColor ||
           oldDelegate.glowColor != glowColor;
  }
}
