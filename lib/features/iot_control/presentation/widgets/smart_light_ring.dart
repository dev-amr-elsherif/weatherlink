import 'dart:math' as math;
import 'package:flutter/material.dart';

class SmartLightRing extends StatelessWidget {
  final int activePairs; // range 0 to 8

  const SmartLightRing({super.key, required this.activePairs});

  @override
  Widget build(BuildContext context) {
    const int totalLeds = 16;
    const double radius = 75.0;
    const double ledSize = 12.0;

    final Set<int> onIndices = {};
    for (int i = 0; i < activePairs; i++) {
      if (i < 8) {
        onIndices.add(i);
        onIndices.add(15 - i);
      }
    }

    return SizedBox(
      height: (radius * 2) + (ledSize * 2.5),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: radius * 1.3,
              height: radius * 1.3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xB3000000),
                border: Border.all(
                  color: const Color(0x6600E5FF),
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4000E5FF), // Restored radiant ambient composite halo
                    blurRadius: 25,
                    spreadRadius: 3,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$activePairs / 8',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFFFFF),
                      shadows: [
                        Shadow(
                          color: Color(0xFF00E5FF),
                          blurRadius: 16,
                        ),
                        Shadow(
                          color: Color(0x9900E5FF),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'PAIRS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.5,
                      color: Color(0xE600E5FF),
                    ),
                  ),
                ],
              ),
            ),
            
            ...List.generate(totalLeds, (index) {
              final double angle = (2 * math.pi * index / totalLeds) - (math.pi / 2);
              final double dx = radius * math.cos(angle);
              final double dy = radius * math.sin(angle);

              final bool isOn = onIndices.contains(index);
              final Color coreColor = isOn ? const Color(0xFFFFFFFF) : const Color(0x1AFFFFFF);

              return Transform.translate(
                offset: Offset(dx, dy),
                child: Container(
                  width: ledSize,
                  height: ledSize,
                  decoration: BoxDecoration(
                    color: coreColor,
                    shape: BoxShape.circle,
                    border: isOn ? null : Border.all(color: const Color(0x33FFFFFF), width: 0.5),
                    boxShadow: isOn
                        ? const [
                            // Multi-layered bloom glow using stacked BoxShadow layers
                            BoxShadow(
                              color: Color(0xFF00E5FF),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: Color(0xCC00E5FF),
                              blurRadius: 16,
                              spreadRadius: 4,
                            ),
                            BoxShadow(
                              color: Color(0x6600E5FF),
                              blurRadius: 28,
                              spreadRadius: 8,
                            ),
                          ]
                        : const [
                            // Deep, semi-reflective appearance
                            BoxShadow(
                              color: Color(0x4D000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
