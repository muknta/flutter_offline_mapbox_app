import 'package:flutter/material.dart';

class InkWrapper extends StatelessWidget {
  const InkWrapper({
    super.key,
    this.borderRadius = BorderRadius.zero,
    this.border,
    this.padding = EdgeInsets.zero,
    this.onTap,
    this.height,
    this.width,
    this.backgroundColor,
    required this.child,
  });

  final BorderRadius borderRadius;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Border? border;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: ColoredBox(
        color: backgroundColor ?? Colors.transparent,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: padding,
              height: height,
              width: width,
              decoration: BoxDecoration(
                border: border,
                borderRadius: borderRadius,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
