import 'package:flutter/material.dart';

import 'selection_point.dart';

/// Routes programmatic [triggerAt] / [setSelection] calls into the active [DotGridWidget].
///
/// Attach/detach is wired by [DotGridWidget]; the controller holds no animation state.
class DotGridController {
  DotGridController();

  void Function(Offset, Color?)? _onTriggerAt;
  void Function(Offset?, Color?)? _onSetSelection;
  void Function(List<SelectionPoint>)? _onSetSelections;

  void triggerAt(Offset position, {Color? color}) {
    _onTriggerAt?.call(position, color);
  }

  void setSelection(Offset? position, Color? color) {
    _onSetSelection?.call(position, color);
  }

  void setSelections(List<SelectionPoint> points) {
    _onSetSelections?.call(points);
  }

  void attach({
    void Function(Offset, Color?)? trigger,
    void Function(Offset?, Color?)? setSelection,
    void Function(List<SelectionPoint>)? setSelections,
  }) {
    _onTriggerAt = trigger;
    _onSetSelection = setSelection;
    _onSetSelections = setSelections;
  }

  void detach() {
    _onTriggerAt = null;
    _onSetSelection = null;
    _onSetSelections = null;
  }

  void dispose() {
    detach();
  }
}
