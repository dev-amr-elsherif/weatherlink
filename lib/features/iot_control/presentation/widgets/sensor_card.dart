import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'sparkline_chart.dart';

class SensorCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLarge;
  final List<double>? sparklineData;
  final String? secondaryTitle;
  final String? secondaryValue;
  final IconData? secondaryIcon;

  const SensorCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isLarge = false,
    this.sparklineData,
    this.secondaryTitle,
    this.secondaryValue,
    this.secondaryIcon,
  });

  @override
  Widget build(BuildContext context) {
    Color iconActualColor = color;
    Color glowActualColor = Color(color.value).withAlpha(0x66);

    if (title.toLowerCase().contains('temp') || (secondaryTitle?.toLowerCase().contains('temp') ?? false)) {
      final valToParse = title.toLowerCase().contains('temp') ? value : (secondaryValue ?? '');
      final cleanedVal = valToParse.replaceAll(RegExp(r'[^0-9.-]'), '');
      final numericVal = double.tryParse(cleanedVal);
      if (numericVal != null) {
        if (numericVal > 30) {
          iconActualColor = const Color(0xFFFF1744);
          glowActualColor = const Color(0x66FF1744);
        } else if (numericVal < 20) {
          iconActualColor = const Color(0xFF2979FF);
          glowActualColor = const Color(0x662979FF);
        }
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0x1AFFFFFF),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0x33FFFFFF), width: 1),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isLarge ? 24.0 : 16.0,
            vertical: isLarge ? 24.0 : 20.0,
          ),
          child: isLarge
              ? _buildLargeLayout(context, iconActualColor, glowActualColor)
              : _buildStandardLayout(context, iconActualColor, glowActualColor),
        ),
      ),
    );
  }

  Widget _buildLargeLayout(BuildContext context, Color iconActualColor, Color glowActualColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double titleFontSize = (screenWidth * 0.035).clamp(12.0, 16.0);
    final double valueFontSize = (screenWidth * 0.1).clamp(32.0, 56.0);
    final double iconSize = (screenWidth * 0.06).clamp(20.0, 28.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildIconBox(icon, iconActualColor, glowActualColor, size: iconSize),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FittedBox(
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.scaleDown,
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              color: const Color(0xCCFFFFFF),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: valueFontSize,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFFFFF),
                        shadows: [Shadow(color: glowActualColor, blurRadius: 12)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (secondaryTitle != null && secondaryValue != null && secondaryIcon != null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: FittedBox(
                            alignment: Alignment.centerRight,
                            fit: BoxFit.scaleDown,
                            child: Text(
                              secondaryTitle!,
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                                color: const Color(0xCCFFFFFF),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildIconBox(secondaryIcon!, iconActualColor, glowActualColor, size: iconSize),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        secondaryValue!,
                        style: TextStyle(
                          fontSize: valueFontSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFFFFF),
                          shadows: [Shadow(color: glowActualColor, blurRadius: 12)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        if (sparklineData != null) ...[
          const Spacer(),
          SizedBox(
            height: (MediaQuery.of(context).size.height * 0.1).clamp(60.0, 100.0),
            width: double.infinity,
            child: SparklineChart(
              data: sparklineData!,
              lineColor: iconActualColor,
              gradientColor: glowActualColor,
              glowColor: glowActualColor,
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildStandardLayout(BuildContext context, Color iconActualColor, Color glowActualColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double titleFontSize = (screenWidth * 0.03).clamp(10.0, 14.0);
    final double valueFontSize = (screenWidth * 0.08).clamp(24.0, 40.0);
    final double iconSize = (screenWidth * 0.08).clamp(24.0, 32.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIconBox(icon, iconActualColor, glowActualColor, size: iconSize),
        const Spacer(),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: const Color(0xCCFFFFFF),
            ),
            maxLines: 1,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFFFFF),
              shadows: [Shadow(color: glowActualColor, blurRadius: 12)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconBox(IconData ic, Color actualColor, Color actualGlowColor, {required double size}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x1A000000),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: actualGlowColor,
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        ic,
        size: size,
        color: actualColor,
      ),
    );
  }
}
