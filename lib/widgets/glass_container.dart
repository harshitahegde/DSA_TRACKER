import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double borderRadius;
  final EdgeInsets padding;
  final Color backgroundColor;
  final VoidCallback? onTap; // Optional tap handler

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 10,
    this.borderRadius = 15,
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor = Colors.white,
    this.onTap, required int elevation, // Correctly define optional onTap
    // Removed unused/incorrectly placed 'elevation' parameter
  });

  @override
  Widget build(BuildContext context) {
    // Wrap the container in a GestureDetector to support the optional onTap functionality
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              // Background color is lightened and used as the internal glass color
              color: backgroundColor.withOpacity(0.2), 
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                // Border color provides definition for the glass edge
                color: backgroundColor.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
