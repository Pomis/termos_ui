import 'package:flutter/material.dart';

import '../core/dot_grid/dot_grid_group.dart';

import '../core/termos_aligned_builder.dart';

/// Synchronizes dot grid alignment: wraps [child] in [DotGridGroup] so
/// [TermosAlignedBuilder] and starfield painters share the same grid origin.
class TermosGroup extends StatelessWidget {
  const TermosGroup({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DotGridGroup(child: child);
  }
}
