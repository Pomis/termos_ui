import 'package:flutter/material.dart';

class _InheritedDotGridGroup extends InheritedWidget {
  const _InheritedDotGridGroup({
    required this.groupKey,
    required super.child,
  });

  final GlobalKey groupKey;

  static GlobalKey? maybeOf(BuildContext context) {
    return context.getInheritedWidgetOfExactType<_InheritedDotGridGroup>()?.groupKey;
  }

  @override
  bool updateShouldNotify(_InheritedDotGridGroup oldWidget) =>
      groupKey != oldWidget.groupKey;
}

/// Establishes a shared grid origin so [DotGridWidget] and aligned overlays line up.
class DotGridGroup extends StatefulWidget {
  const DotGridGroup({super.key, required this.child});

  final Widget child;

  static GlobalKey? maybeOf(BuildContext context) => _InheritedDotGridGroup.maybeOf(context);

  @override
  State<DotGridGroup> createState() => _DotGridGroupState();
}

class _DotGridGroupState extends State<DotGridGroup> {
  final GlobalKey _groupKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return _InheritedDotGridGroup(
      groupKey: _groupKey,
      child: KeyedSubtree(
        key: _groupKey,
        child: widget.child,
      ),
    );
  }
}
