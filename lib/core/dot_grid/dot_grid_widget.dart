import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'dot_grid_controller.dart';
import 'dot_grid_group.dart';
import 'dot_grid_painter.dart';
import 'mesh_gradient_animation.dart';
import 'pointer_event_handler.dart';
import 'selection_point.dart';

/// Synthetic pointer ID range for programmatic triggers (avoids collision with real pointers).
int _nextSyntheticPointerId = 0x7FFF0000;

/// Layered dot mesh with tap ripples (filled blob then expanding ring) and optional hover.
class DotGridWidget extends StatefulWidget {
  const DotGridWidget({
    super.key,
    required this.child,
    this.controller,
    this.dotSize = 4.0,
    this.gridSpacing = 6.0,
    this.primaryColor = Colors.blue,
    this.backgroundColor = Colors.white,
    this.dotPattern = const [1, 5],
    this.expansionDuration = const Duration(milliseconds: 200),
    this.decayDuration = const Duration(milliseconds: 400),
    this.blobRadius = 100.0,
    this.gradientColors = const [],
    this.hoverOpacity = 1.0,
    this.enableHoverEffect = true,
    this.enabled = true,
    this.interactiveMesh = true,
  });

  final Widget child;
  final DotGridController? controller;
  final double dotSize;
  final double gridSpacing;
  final Color primaryColor;
  final Color backgroundColor;
  final List<int> dotPattern;
  final Duration expansionDuration;
  final Duration decayDuration;
  final double blobRadius;
  final List<Color> gradientColors;
  final double hoverOpacity;
  final bool enableHoverEffect;
  final bool enabled;

  /// Mesh response to pointers and [DotGridController.triggerAt]. Grid still paints when false.
  final bool interactiveMesh;

  @override
  State<DotGridWidget> createState() => _DotGridWidgetState();
}

class _DotGridWidgetState extends State<DotGridWidget> with TickerProviderStateMixin {
  final Float32List _pointsBuffer = Float32List(200000);

  DotGridController? _ownedController;

  DotGridController get _effectiveController =>
      widget.controller ?? (_ownedController ??= DotGridController());

  late PointerEventHandler _pointerHandler;
  late MeshGradientAnimation _animation;
  List<TouchPoint> _touchPoints = [];
  Map<int, bool> _hoverStates = {};
  Set<int> _previousActivePointerIds = {};
  Offset? _selectionPosition;
  Color? _selectionColor;
  List<SelectionPoint> _externalSelectionPoints = [];
  final GlobalKey _childKey = GlobalKey();
  final GlobalKey _paintKey = GlobalKey();

  Offset _gridOffset = Offset.zero;
  bool _gridOffsetComputed = false;

  @override
  void initState() {
    super.initState();
    _effectiveController.attach(
      trigger: _triggerAt,
      setSelection: _setSelection,
      setSelections: _setSelections,
    );

    _animation = MeshGradientAnimation(
      vsync: this,
      expansionDuration: widget.expansionDuration,
      decayDuration: widget.decayDuration,
      onAnimationUpdate: () {
        if (mounted) {
          setState(() {
            _updateTouchPoints();
          });
        }
      },
    );

    _pointerHandler = PointerEventHandler(
      onTouchPointsChanged: _handleTouchPointsChanged,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleGridOffsetUpdate();
  }

  void _scheduleGridOffsetUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final groupKey = DotGridGroup.maybeOf(context);
      if (groupKey == null) {
        if (_gridOffset != Offset.zero || !_gridOffsetComputed) {
          setState(() {
            _gridOffset = Offset.zero;
            _gridOffsetComputed = true;
          });
        }
        return;
      }
      final paintBox = _paintKey.currentContext?.findRenderObject() as RenderBox?;
      final groupBox = groupKey.currentContext?.findRenderObject() as RenderBox?;
      final myBox = paintBox ?? _childKey.currentContext?.findRenderObject() as RenderBox?;
      if (myBox == null || !myBox.hasSize || groupBox == null || !groupBox.hasSize) {
        _scheduleGridOffsetUpdate();
        return;
      }
      try {
        final myTopLeft = myBox.localToGlobal(Offset.zero);
        final groupTopLeft = groupBox.localToGlobal(Offset.zero);
        final newOffset = myTopLeft - groupTopLeft;
        if ((newOffset - _gridOffset).distance > 0.5 || !_gridOffsetComputed) {
          setState(() {
            _gridOffset = newOffset;
            _gridOffsetComputed = true;
          });
        }
      } catch (_) {
        if (_gridOffset != Offset.zero || _gridOffsetComputed) {
          setState(() {
            _gridOffset = Offset.zero;
            _gridOffsetComputed = false;
          });
        }
      }
    });
  }

  @override
  void didUpdateWidget(DotGridWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleGridOffsetUpdate();

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach();
      _ownedController?.detach();
      _ownedController = null;
      if (widget.controller == null) {
        _ownedController = DotGridController();
      }
      _effectiveController.attach(
        trigger: _triggerAt,
        setSelection: _setSelection,
        setSelections: _setSelections,
      );
    }

    if (oldWidget.enableHoverEffect && !widget.enableHoverEffect) {
      for (final pointerId in _hoverStates.keys.where((id) => _hoverStates[id] == true)) {
        _pointerHandler.handlePointerUp(pointerId);
      }
    }

    if (oldWidget.interactiveMesh && !widget.interactiveMesh) {
      _pointerHandler.clear();
      _previousActivePointerIds = {};
      _hoverStates = {};
    }

    if (oldWidget.expansionDuration != widget.expansionDuration ||
        oldWidget.decayDuration != widget.decayDuration) {
      _animation.dispose();
      _animation = MeshGradientAnimation(
        vsync: this,
        expansionDuration: widget.expansionDuration,
        decayDuration: widget.decayDuration,
        onAnimationUpdate: () {
          if (mounted) {
            setState(() {
              _updateTouchPoints();
            });
          }
        },
      );
    }
  }

  @override
  void dispose() {
    if (widget.controller != null) {
      widget.controller!.detach();
    } else {
      _ownedController?.detach();
    }
    _animation.dispose();
    super.dispose();
  }

  void _triggerAt(Offset position, Color? color) {
    if (!widget.enabled || !widget.interactiveMesh) return;
    final syntheticId = _nextSyntheticPointerId--;
    if (_nextSyntheticPointerId < 0x7FFE0000) {
      _nextSyntheticPointerId = 0x7FFF0000;
    }
    _pointerHandler.handlePointerDown(syntheticId, position, color: color);
    Future.delayed(widget.expansionDuration, () {
      if (mounted) {
        _pointerHandler.handlePointerUp(syntheticId);
      }
    });
  }

  void _setSelection(Offset? position, Color? color) {
    if (_selectionPosition == position && _selectionColor == color) return;
    _selectionPosition = position;
    _selectionColor = color;
    if (mounted) setState(() {});
  }

  void _setSelections(List<SelectionPoint> points) {
    if (_listEquals(_externalSelectionPoints, points)) return;
    _externalSelectionPoints = List.from(points);
    if (mounted) setState(() {});
  }

  bool _listEquals(List<SelectionPoint> a, List<SelectionPoint> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      final pa = a[i];
      final pb = b[i];
      if ((pa.position - pb.position).distance > 0.5 ||
          pa.color != pb.color ||
          pa.radiusMultiplier != pb.radiusMultiplier) {
        return false;
      }
    }
    return true;
  }

  List<SelectionPoint> _buildSelectionPoints() {
    final points = <SelectionPoint>[];
    if (_selectionPosition != null && _selectionColor != null) {
      points.add(SelectionPoint(
        position: _selectionPosition!,
        color: _selectionColor!,
        radiusMultiplier: 0.6,
      ));
    }
    points.addAll(_externalSelectionPoints);
    return points;
  }

  void _handleTouchPointsChanged(List<TouchPointData> touchPointData) {
    if (!mounted) return;

    final activePointerIds =
        touchPointData.where((tp) => tp.isActive).map((tp) => tp.pointerId).toSet();

    for (final pointerId in activePointerIds) {
      final wasPreviouslyActive = _previousActivePointerIds.contains(pointerId);
      final currentValue = _animation.getAnimationValue(pointerId);

      if (!wasPreviouslyActive || currentValue > 0.35) {
        _animation.startExpansion(pointerId);
      }
    }

    for (final pointerId in _previousActivePointerIds) {
      if (!activePointerIds.contains(pointerId)) {
        final currentValue = _animation.getAnimationValue(pointerId);
        if (currentValue > 0.0 && currentValue <= 0.35) {
          _animation.startDecay(pointerId);
        }
      }
    }

    _previousActivePointerIds = activePointerIds;

    setState(() {
      _updateTouchPoints();
    });
  }

  void _updateTouchPoints() {
    final touchPointData = _pointerHandler.getAllTouchPoints();
    _touchPoints = _animation.getAnimatedTouchPoints(touchPointData);

    _hoverStates = {for (final data in touchPointData) data.pointerId: data.isHover};

    _touchPoints = _touchPoints.where((tp) {
      return _animation.getAnimationValue(tp.pointerId) > 0.0 ||
          _pointerHandler.getActiveTouchPoints().any((data) => data.pointerId == tp.pointerId);
    }).toList();
  }

  Offset _globalToCanvas(Offset globalPosition) {
    final paintBox = _paintKey.currentContext?.findRenderObject() as RenderBox?;
    if (paintBox != null) {
      try {
        return paintBox.globalToLocal(globalPosition);
      } catch (_) {}
    }
    final childBox = _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (childBox != null) {
      try {
        return childBox.globalToLocal(globalPosition);
      } catch (_) {}
    }
    return globalPosition;
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!widget.enabled || !widget.interactiveMesh) return;

    final canvasPos = _globalToCanvas(event.position);
    _pointerHandler.handlePointerDown(event.pointer, canvasPos);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!widget.enabled || !widget.interactiveMesh) return;

    final canvasPos = _globalToCanvas(event.position);
    _pointerHandler.handlePointerMove(event.pointer, canvasPos);
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (!widget.enabled || !widget.interactiveMesh) return;

    _pointerHandler.handlePointerUp(event.pointer);
  }

  void _handlePointerHover(PointerEvent event) {
    if (!widget.enabled || !widget.interactiveMesh || !widget.enableHoverEffect) return;

    final canvasPos = _globalToCanvas(event.position);
    final existingTouch =
        _pointerHandler.getAllTouchPoints().where((tp) => tp.pointerId == event.pointer).isNotEmpty;

    if (!existingTouch) {
      _pointerHandler.handlePointerDown(event.pointer, canvasPos, isHover: true);
    } else {
      _pointerHandler.handlePointerMove(event.pointer, canvasPos);
    }
  }

  void _handlePointerExit(PointerEvent event) {
    if (!widget.enabled || !widget.interactiveMesh) return;

    _pointerHandler.handlePointerUp(event.pointer);
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (!widget.enabled || !widget.interactiveMesh) return;
    _pointerHandler.handlePointerCancel(event.pointer);
  }

  @override
  Widget build(BuildContext context) {
    final stack = Stack(
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: [
        if (widget.enabled)
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  key: _paintKey,
                  painter: DotGridPainter(
                    dotSize: widget.dotSize,
                    gridSpacing: widget.gridSpacing,
                    primaryColor: widget.primaryColor,
                    backgroundColor: widget.backgroundColor,
                    pointsBuffer: _pointsBuffer,
                    dotPattern: widget.dotPattern,
                    touchPoints: _gridOffsetComputed ? _touchPoints : const [],
                    selectionPoints: _buildSelectionPoints(),
                    blobRadius: widget.blobRadius,
                    gradientColors: widget.gradientColors,
                    hoverOpacity: widget.hoverOpacity,
                    hoverStates: _hoverStates,
                    gridOffset: _gridOffset,
                  ),
                ),
              ),
            ),
          ),
        widget.child,
      ],
    );

    final listener = Listener(
      key: _childKey,
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      behavior: HitTestBehavior.translucent,
      child: stack,
    );

    if (!widget.interactiveMesh) {
      return listener;
    }

    return MouseRegion(
      onHover: _handlePointerHover,
      onExit: _handlePointerExit,
      child: listener,
    );
  }
}
