import 'package:flutter/material.dart';

class ShimmerBento extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerBento({
    super.key,
    required this.child,
    required this.isLoading,
  });

  @override
  State<ShimmerBento> createState() => _ShimmerBentoState();
}

class _ShimmerBentoState extends State<ShimmerBento> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: const Color(0x1AFFFFFF),
      end: const Color(0x33FFFFFF),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                const Color(0x00FFFFFF),
                _colorAnimation.value ?? const Color(0x1AFFFFFF),
                const Color(0x00FFFFFF),
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              transform: GradientRotation(_controller.value * 2 * 3.14159),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class SkeletonBentoBox extends StatelessWidget {
  final double height;
  final double width;

  const SkeletonBentoBox({
    super.key,
    required this.height,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x33FFFFFF), width: 1),
      ),
    );
  }
}
