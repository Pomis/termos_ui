import 'package:flutter/material.dart';

/// Tracks pointer positions for [DotGridWidget] mesh effects.
class PointerEventHandler {
  PointerEventHandler({
    required this.onTouchPointsChanged,
  });

  final void Function(List<TouchPointData>) onTouchPointsChanged;

  final Map<int, TouchPointData> _activeTouches = {};

  void handlePointerDown(int pointerId, Offset localPosition, {bool isHover = false, Color? color}) {
    _activeTouches[pointerId] = TouchPointData(
      pointerId: pointerId,
      position: localPosition,
      timestamp: DateTime.now(),
      isActive: true,
      isHover: isHover,
      color: color,
    );

    _notifyListeners();
  }

  void handlePointerMove(int pointerId, Offset localPosition) {
    final touchPoint = _activeTouches[pointerId];
    if (touchPoint != null) {
      _activeTouches[pointerId] = touchPoint.copyWith(
        position: localPosition,
        timestamp: DateTime.now(),
      );

      _notifyListeners();
    }
  }

  void handlePointerUp(int pointerId) {
    final touchPoint = _activeTouches[pointerId];
    if (touchPoint != null) {
      _activeTouches[pointerId] = touchPoint.copyWith(
        isActive: false,
        timestamp: DateTime.now(),
      );

      _notifyListeners();
    }
  }

  void handlePointerCancel(int pointerId) {
    _activeTouches.remove(pointerId);
    _notifyListeners();
  }

  List<TouchPointData> getActiveTouchPoints() {
    return _activeTouches.values.where((tp) => tp.isActive).toList();
  }

  List<TouchPointData> getAllTouchPoints() {
    return _activeTouches.values.toList();
  }

  void removeTouchPoint(int pointerId) {
    _activeTouches.remove(pointerId);
    _notifyListeners();
  }

  void clear() {
    _activeTouches.clear();
    _notifyListeners();
  }

  void _notifyListeners() {
    onTouchPointsChanged(getAllTouchPoints());
  }
}

/// Data for one tracked pointer (local coordinates).
class TouchPointData {
  TouchPointData({
    required this.pointerId,
    required this.position,
    required this.timestamp,
    this.isActive = true,
    this.isHover = false,
    this.color,
  });

  final int pointerId;
  final Offset position;
  final DateTime timestamp;
  final bool isActive;
  final bool isHover;
  final Color? color;

  TouchPointData copyWith({
    int? pointerId,
    Offset? position,
    DateTime? timestamp,
    bool? isActive,
    bool? isHover,
    Color? color,
  }) {
    return TouchPointData(
      pointerId: pointerId ?? this.pointerId,
      position: position ?? this.position,
      timestamp: timestamp ?? this.timestamp,
      isActive: isActive ?? this.isActive,
      isHover: isHover ?? this.isHover,
      color: color ?? this.color,
    );
  }
}
