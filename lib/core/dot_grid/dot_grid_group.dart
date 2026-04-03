import 'package:flutter/material.dart';

class _InheritedDotGridGroup extends InheritedWidget {
  const _InheritedDotGridGroup({
    required this.groupContext,
    required super.child,
  });

  final BuildContext groupContext;

  static BuildContext? maybeOf(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<_InheritedDotGridGroup>()
        ?.groupContext;
  }

  @override
  bool updateShouldNotify(_InheritedDotGridGroup oldWidget) =>
      groupContext != oldWidget.groupContext;
}

/// Establishes a shared grid origin so [DotGridWidget] and aligned overlays line up.
class DotGridGroup extends StatefulWidget {
  const DotGridGroup({super.key, required this.child});

  final Widget child;

  static BuildContext? maybeOf(BuildContext context) =>
      _InheritedDotGridGroup.maybeOf(context);

  @override
  State<DotGridGroup> createState() => _DotGridGroupState();
}

class _DotGridGroupState extends State<DotGridGroup> {
  @override
  Widget build(BuildContext context) {
    return _InheritedDotGridGroup(
      groupContext: context,
      child: widget.child,
    );
  }
}
