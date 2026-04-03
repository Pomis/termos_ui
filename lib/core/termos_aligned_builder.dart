import 'package:flutter/material.dart';

import 'dot_grid/dot_grid_group.dart';

/// Computes this widget's [Offset] relative to a [DotGridGroup] and passes it
/// to [builder]. Use when painting a dot grid that must align with [DotGridWidget]
/// instances in the same group.
///
/// When not inside a [DotGridGroup], [Offset.zero] is passed.
class TermosAlignedBuilder extends StatefulWidget {
  const TermosAlignedBuilder({super.key, required this.builder});

  final Widget Function(Offset gridOffset) builder;

  @override
  State<TermosAlignedBuilder> createState() => _TermosAlignedBuilderState();
}

class _TermosAlignedBuilderState extends State<TermosAlignedBuilder> {
  final GlobalKey _key = GlobalKey();
  Offset _gridOffset = Offset.zero;
  bool _computed = false;

  void _scheduleUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final groupKey = DotGridGroup.maybeOf(context);
      if (groupKey == null) {
        if (_gridOffset != Offset.zero || !_computed) {
          setState(() {
            _gridOffset = Offset.zero;
            _computed = true;
          });
        }
        return;
      }
      final myBox = _key.currentContext?.findRenderObject() as RenderBox?;
      final groupBox = groupKey.currentContext?.findRenderObject() as RenderBox?;
      if (myBox == null || !myBox.hasSize || groupBox == null || !groupBox.hasSize) {
        _scheduleUpdate();
        return;
      }
      try {
        final newOffset = myBox.localToGlobal(Offset.zero) -
            groupBox.localToGlobal(Offset.zero);
        if ((newOffset - _gridOffset).distance > 0.5 || !_computed) {
          setState(() {
            _gridOffset = newOffset;
            _computed = true;
          });
        }
      } catch (_) {
        if (_gridOffset != Offset.zero || _computed) {
          setState(() {
            _gridOffset = Offset.zero;
            _computed = false;
          });
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.builder(_gridOffset),
    );
  }
}
