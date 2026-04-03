import 'package:flutter/material.dart';

/// Constrains [icon] to a square slot and tints it with [tintColor] ([BlendMode.srcIn]).
///
/// Best with monochrome glyphs on a transparent background (e.g. vector icon
/// painted in [Colors.white]) so state-driven colors match the theme.
class TermosIconSlot extends StatelessWidget {
  const TermosIconSlot({
    super.key,
    required this.icon,
    required this.tintColor,
    required this.slotSize,
  });

  final Widget icon;
  final Color tintColor;
  final double slotSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: slotSize,
      height: slotSize,
      child: FittedBox(
        fit: BoxFit.contain,
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(tintColor, BlendMode.srcIn),
          child: icon,
        ),
      ),
    );
  }
}
