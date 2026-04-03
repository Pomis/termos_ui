import 'package:flutter/material.dart';

import 'dot_grid_painter.dart';
import 'pointer_event_handler.dart';

/// Drives expansion / decay animation for mesh tap effects (filled blob then outward ring).
class MeshGradientAnimation {
  MeshGradientAnimation({
    required this.vsync,
    required this.onAnimationUpdate,
    this.expansionDuration = const Duration(milliseconds: 200),
    this.decayDuration = const Duration(milliseconds: 400),
    this.expansionCurve = Curves.easeOut,
    this.decayCurve = Curves.easeIn,
  });

  final TickerProvider vsync;
  final Duration expansionDuration;
  final Duration decayDuration;
  final Curve expansionCurve;
  final Curve decayCurve;
  final void Function() onAnimationUpdate;

  final Map<int, AnimationController> _animationControllers = {};
  final Map<int, Animation<double>> _animations = {};

  void startExpansion(int pointerId) {
    final oldAnimation = _animations[pointerId];
    double startValue = 0.3;

    if (oldAnimation != null) {
      final currentValue = oldAnimation.value;
      if (currentValue.isFinite && currentValue > 0.0 && currentValue <= 0.5) {
        startValue = currentValue;
      }
    }

    _removeAnimation(pointerId);

    final controller = AnimationController(
      vsync: vsync,
      duration: expansionDuration,
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    final clampedStartValue = startValue.clamp(0.0, 1.0);
    final tween = Tween<double>(begin: clampedStartValue, end: clampedStartValue);
    final animation = tween.animate(controller);

    _animationControllers[pointerId] = controller;
    _animations[pointerId] = animation;

    animation.addListener(onAnimationUpdate);

    controller.value = 0.0;
  }

  void startDecay(int pointerId) {
    final oldAnimation = _animations[pointerId];
    final oldController = _animationControllers[pointerId];
    if (oldAnimation == null || oldController == null) {
      return;
    }

    final rawValue = oldAnimation.value;
    final currentValue = (rawValue.isFinite && rawValue > 0.0 && rawValue <= 1.0)
        ? rawValue.clamp(0.0, 1.0)
        : 0.3;

    oldAnimation.removeListener(onAnimationUpdate);
    oldController.dispose();

    final expandController = AnimationController(
      vsync: vsync,
      duration: decayDuration,
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    final clampedCurrentValue = currentValue.clamp(0.0, 1.0);
    final tween = Tween<double>(begin: clampedCurrentValue, end: 1.5);
    final expandAnimation = tween.animate(
      CurvedAnimation(
        parent: expandController,
        curve: Curves.easeOut,
      ),
    );

    _animationControllers[pointerId] = expandController;
    _animations[pointerId] = expandAnimation;
    expandAnimation.addListener(onAnimationUpdate);

    expandController.forward().then((_) {
      _removeAnimation(pointerId);
    });
  }

  void updateDecayDuration(int pointerId, Duration duration) {
    final controller = _animationControllers[pointerId];
    if (controller != null) {
      controller.duration = duration;
    }
  }

  double getAnimationValue(int pointerId) {
    final animation = _animations[pointerId];
    if (animation == null) {
      return 0.0;
    }
    final value = animation.value;
    if (!value.isFinite || value < 0) {
      return 0.0;
    }
    return value;
  }

  List<TouchPoint> getAnimatedTouchPoints(List<TouchPointData> touchPointData) {
    return touchPointData.map((data) {
      final animationValue = getAnimationValue(data.pointerId);
      return TouchPoint(
        pointerId: data.pointerId,
        position: data.position,
        animationValue: animationValue,
        color: data.color,
      );
    }).toList();
  }

  void _removeAnimation(int pointerId) {
    final controller = _animationControllers.remove(pointerId);
    final animation = _animations.remove(pointerId);

    animation?.removeListener(onAnimationUpdate);
    controller?.dispose();
  }

  void dispose() {
    for (final controller in _animationControllers.values) {
      controller.dispose();
    }
    _animationControllers.clear();
    _animations.clear();
  }

  bool get hasActiveAnimations => _animationControllers.isNotEmpty;
}
