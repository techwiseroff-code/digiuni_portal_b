import 'package:flutter/material.dart';
import '../utils/styles.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;
  final double borderRadius;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double blurRadius;
  final double opacity;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.gradient,
    this.borderRadius = 16,
    this.height,
    this.width,
    this.margin,
    this.onTap,
    this.blurRadius = 10,
    this.opacity = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      padding: padding,
      margin: margin,
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: gradient ?? Styles.glassGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withAlpha((opacity * 255).toInt()),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: blurRadius,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: child,
      ),
    );

    return onTap != null
        ? GestureDetector(onTap: onTap, child: container)
        : container;
  }
}
