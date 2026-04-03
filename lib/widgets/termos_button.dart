import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../core/dot_grid/dot_grid_controller.dart';
import '../core/termos_icon_slot.dart';
import '../core/termos_aligned_builder.dart';
import '../core/termos_tap_target.dart';
import '../painters/reactive_starfield_painter.dart';
import '../theme/termos_effects.dart';
import '../theme/termos_theme.dart';
import 'termos_loading_indicator.dart';

Color _borderColorForState(
  Set<WidgetState> states,
  Color accentColor,
  Color borderColor,
  TermosButtonEffects buttonEffects,
) {
  final t = states.contains(WidgetState.pressed)
      ? buttonEffects.borderPressedMix
      : states.contains(WidgetState.hovered)
          ? buttonEffects.borderHoveredMix
          : buttonEffects.borderHoverMix;
  return Color.lerp(borderColor, accentColor, t) ?? accentColor;
}

/// Primary CTA with dot grid mesh, starfield background, and optional typing loading animation.
class TermosButton extends StatefulWidget {
  const TermosButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.enabled = true,
    this.isLoading = false,
    this.loadingLabel,
    this.typingLoadingTransition = false,
    this.savedState = false,
    this.allowTapWhenSaved = false,
    this.savedLabel,
    this.savedIcon,
    this.height,
    this.width,
    this.expandWidth = true,
    this.color,
    this.borderRadius,
  });

  final Text label;
  final VoidCallback? onTap;
  final Widget? icon;
  final bool enabled;
  final bool isLoading;
  final String? loadingLabel;
  final bool typingLoadingTransition;
  final bool savedState;
  final bool allowTapWhenSaved;
  final String? savedLabel;
  final Widget? savedIcon;
  final double? height;
  final double? width;
  /// When true (default), the button fills available horizontal space. When false,
  /// width follows label + icon (unless [width] is set).
  final bool expandWidth;
  final Color? color;
  final BorderRadius? borderRadius;

  @override
  State<TermosButton> createState() => _TermosButtonState();
}

const bool _kDebugTypingDelays = false;

class _TermosButtonState extends State<TermosButton> {
  bool _hovered = false;
  bool _pressed = false;

  final DotGridController _dotGridController = DotGridController();
  late final int _starfieldSeed;

  @override
  void initState() {
    super.initState();
    _starfieldSeed = Random().nextInt(0x7FFFFFFF);
  }

  String? _typingDisplayText;
  Timer? _typingTimer;
  int _ellipsisFrame = 0;
  bool _isTransitioningToSaved = false;

  static int get _backspaceDelayMs => _kDebugTypingDelays ? 42 : 3;
  static int get _typeDelayMs => _kDebugTypingDelays ? 42 : 4;
  static int get _ellipsisDelayMs => _kDebugTypingDelays ? 210 : 140;

  void _cancelTypingTimer() {
    _typingTimer?.cancel();
    _typingTimer = null;
  }

  void _startTypingAnimation() {
    _cancelTypingTimer();
    final label = widget.label.data ?? '';
    var loadingBase = (widget.loadingLabel ?? '').replaceAll(RegExp(r'\.+$'), '');
    int phase = 0;
    int idx = 0;
    final rnd = Random();

    void scheduleNext() {
      _typingTimer = Timer(
        Duration(
          milliseconds: phase == 0
              ? _backspaceDelayMs
              : phase == 1
                  ? _typeDelayMs
                  : _ellipsisDelayMs,
        ),
        () {
          if (!mounted) return;
          setState(() {
            if (phase == 0) {
              idx += 1 + rnd.nextInt(3);
              if (idx >= label.length) {
                phase = 1;
                idx = 0;
                _typingDisplayText = loadingBase.isEmpty ? '' : loadingBase[0];
              } else {
                _typingDisplayText = label.substring(0, label.length - idx);
              }
            } else if (phase == 1) {
              idx += 1 + rnd.nextInt(3);
              if (idx >= loadingBase.length) {
                phase = 2;
                _ellipsisFrame = 0;
                _typingDisplayText = loadingBase;
              } else {
                _typingDisplayText =
                    loadingBase.substring(0, min(idx + 1, loadingBase.length));
              }
            } else {
              _ellipsisFrame = (_ellipsisFrame + 1) % 4;
              _typingDisplayText = loadingBase + (['', '.', '..', '...'][_ellipsisFrame]);
            }
          });
          if (mounted && widget.isLoading) scheduleNext();
        },
      );
    }

    _typingDisplayText = label;
    scheduleNext();
  }

  void _stopTypingAnimation() {
    _cancelTypingTimer();
    _typingDisplayText = null;
    _isTransitioningToSaved = false;
  }

  void _startTransitionToSavedAnimation() {
    _cancelTypingTimer();
    _isTransitioningToSaved = true;
    var fromText = (widget.loadingLabel ?? '').replaceAll(RegExp(r'\.+$'), '');
    final toText = widget.savedLabel ?? '';
    int phase = 0;
    int idx = 0;
    final rnd = Random();

    void scheduleNext() {
      _typingTimer?.cancel();
      _typingTimer = Timer(
        Duration(milliseconds: phase == 0 ? _backspaceDelayMs : _typeDelayMs),
        () {
          if (!mounted) return;
          setState(() {
            if (phase == 0) {
              idx += 1 + rnd.nextInt(3);
              if (idx >= fromText.length) {
                phase = 1;
                idx = 0;
                _typingDisplayText = toText.isEmpty ? '' : toText[0];
              } else {
                _typingDisplayText = fromText.substring(0, fromText.length - idx);
              }
            } else {
              idx += 1 + rnd.nextInt(3);
              if (idx >= toText.length) {
                _typingDisplayText = toText;
                _isTransitioningToSaved = false;
                _cancelTypingTimer();
                return;
              } else {
                _typingDisplayText = toText.substring(0, min(idx + 1, toText.length));
              }
            }
          });
          if (mounted && _isTransitioningToSaved) scheduleNext();
        },
      );
    }

    _typingDisplayText = fromText;
    scheduleNext();
  }

  @override
  void didUpdateWidget(covariant TermosButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.typingLoadingTransition) {
      if (widget.isLoading && !oldWidget.isLoading) {
        _startTypingAnimation();
      } else if (!widget.isLoading && oldWidget.isLoading) {
        if (widget.savedState) {
          _startTransitionToSavedAnimation();
        } else {
          _stopTypingAnimation();
        }
      }
    }
  }

  @override
  void dispose() {
    _cancelTypingTimer();
    _dotGridController.dispose();
    super.dispose();
  }

  Set<WidgetState> get _states {
    final s = <WidgetState>{};
    if (_hovered) s.add(WidgetState.hovered);
    if (_pressed) s.add(WidgetState.pressed);
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final termos = TermosTheme.of(context);
    final useHeavyVisualEffects = termos.heavyEffectsEnabled;
    final colors = termos.colors;
    final dg = termos.dotGrid;
    final textStyles = termos.textStyles;

    final isSaved = widget.savedState;
    final isTransitioning = _isTransitioningToSaved;
    final accentColor =
        (isSaved || isTransitioning) ? colors.success : (widget.color ?? colors.primary);
    final effectiveEnabled =
        widget.enabled && !widget.isLoading && !isSaved && !isTransitioning;
    final tapEnabled = effectiveEnabled || (widget.allowTapWhenSaved && isSaved);
    final isDisabled =
        !effectiveEnabled && !widget.isLoading && !isSaved && !isTransitioning;
    final useTyping = widget.typingLoadingTransition && widget.isLoading;
    final String? overrideLabel = useTyping && _typingDisplayText != null
        ? _typingDisplayText!
        : isTransitioning && _typingDisplayText != null
            ? _typingDisplayText!
            : widget.isLoading
                ? (widget.loadingLabel ?? '')
                : isSaved
                    ? (widget.savedLabel ?? '')
                    : null;
    final showSpinner = widget.isLoading && !useTyping;
    final displayIcon =
        (isSaved || isTransitioning) && widget.savedIcon != null ? widget.savedIcon! : widget.icon;
    final buttonEffects = termos.button;
    final starfield = termos.starfield;
    final metrics = termos.metrics;
    final enabledBorderColor = _borderColorForState(
      _states,
      accentColor,
      colors.dotGridButtonBorder,
      buttonEffects,
    );
    final disabledTransitionDuration = metrics.buttonDisabledTransitionDuration;
    const disabledTransitionCurve = Curves.easeInOut;

    final animatedBuilder = TweenAnimationBuilder<double>(
      key: ValueKey(isDisabled),
      tween: Tween(begin: isDisabled ? 0 : 1, end: isDisabled ? 1 : 0),
      duration: disabledTransitionDuration,
      curve: disabledTransitionCurve,
      builder: (context, t, _) {
        final borderColor = Color.lerp(enabledBorderColor, colors.textMuted, t)!;
        final contentColor = Color.lerp(
          accentColor,
          colors.textMuted.withValues(alpha: buttonEffects.contentMutedAlpha),
          t,
        )!;
        final glowColor = Color.lerp(accentColor, colors.textMuted, t)!;
        final isLight = Theme.of(context).brightness == Brightness.light;
        final glowIntensity = t * starfield.intensityButtonDisabledBlend +
            (1 - t) *
                (isLight
                    ? starfield.intensityButtonLight
                    : starfield.intensityButtonDark);

        final labelRow = Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showSpinner) ...[
              SizedBox(
                width: metrics.buttonLoadingSpinnerSlotSize,
                height: metrics.buttonLoadingSpinnerSlotSize,
                child: TermosLoadingIndicator(
                  size: metrics.buttonLoadingSpinnerSize,
                  color: accentColor,
                ),
              ),
              SizedBox(width: metrics.buttonIconSpacing),
            ] else if (displayIcon != null) ...[
              TermosIconSlot(
                icon: displayIcon,
                tintColor: contentColor,
                slotSize: metrics.buttonIconSize,
              ),
              SizedBox(width: metrics.buttonIconSpacing),
            ],
            if (overrideLabel != null)
              Text(overrideLabel)
            else
              widget.label,
          ],
        );
        final labelWithSidePadding = widget.expandWidth
            ? labelRow
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: metrics.buttonHorizontalPadding),
                child: labelRow,
              );
        final content = DefaultTextStyle.merge(
          style: textStyles.terminalHeader(contentColor),
          child: widget.expandWidth
              ? Center(child: labelWithSidePadding)
              : Align(
                  alignment: Alignment.center,
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: labelWithSidePadding,
                ),
        );

        final borderRadius = widget.borderRadius ??
            BorderRadius.circular(metrics.borderRadius);
        final cardBlend = Color.lerp(
          colors.background,
          colors.card,
          isLight ? buttonEffects.cardBlendLight : buttonEffects.cardBlendDark,
        )!;

        final Widget decorated;
        if (useHeavyVisualEffects) {
          final shrinkTap = !widget.expandWidth && widget.width == null;
          final tapTarget = TermosTapTarget(
            controller: widget.typingLoadingTransition && !isSaved && !isTransitioning
                ? _dotGridController
                : null,
            onTap: tapEnabled ? widget.onTap : null,
            enabled: tapEnabled || (widget.typingLoadingTransition && widget.isLoading),
            borderRadius: borderRadius,
            primaryColor: accentColor,
            blobRadius: dg.blobRadius,
            dotSize: dg.dotSize,
            gridSpacing: dg.spacing,
            idleMeshColor: colors.dotGridIdleMesh,
            shrinkWrapWidth: shrinkTap,
            child: content,
          );

          final starfieldLayer = ClipRRect(
            borderRadius: borderRadius,
            child: TermosAlignedBuilder(
              builder: (gridOffset) => CustomPaint(
                painter: ReactiveStarfieldPainter(
                  dotSize: dg.dotSize,
                  gridSpacing: dg.spacing,
                  glowPosition: starfield.glowPositionButton,
                  glowColor: glowColor,
                  intensity: glowIntensity,
                  gridOffset: gridOffset,
                  seed: _starfieldSeed,
                  glowRadiusFraction: starfield.glowRadiusFraction,
                ),
              ),
            ),
          );

          decorated = Container(
            decoration: BoxDecoration(
              color: cardBlend,
              borderRadius: borderRadius,
              border: Border.all(color: borderColor),
            ),
            child: widget.expandWidth
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      starfieldLayer,
                      tapTarget,
                    ],
                  )
                : Stack(
                    fit: StackFit.loose,
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(child: starfieldLayer),
                      tapTarget,
                    ],
                  ),
          );
        } else {
          final inner = Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: tapEnabled ? widget.onTap : null,
              borderRadius: borderRadius,
              child: Container(
                decoration: BoxDecoration(
                  color: cardBlend,
                  borderRadius: borderRadius,
                  border: Border.all(color: borderColor),
                ),
                child: content,
              ),
            ),
          );
          decorated = widget.expandWidth ? inner : IntrinsicWidth(child: inner);
        }

        return decorated;
      },
    );

    final effectiveHeight = widget.height ?? metrics.buttonHeight;
    final effectiveWidth = widget.width ??
        (widget.expandWidth ? double.infinity : null);
    final semanticLabel = overrideLabel ?? widget.label.data ?? '';
    return Semantics(
      button: true,
      enabled: tapEnabled,
      label: semanticLabel,
      child: SizedBox(
        height: effectiveHeight,
        width: effectiveWidth,
        child: Listener(
          onPointerDown: tapEnabled ? (_) => setState(() => _pressed = true) : null,
          onPointerUp: (_) => setState(() => _pressed = false),
          onPointerCancel: (_) => setState(() => _pressed = false),
          child: MouseRegion(
            onEnter: tapEnabled ? (_) => setState(() => _hovered = true) : null,
            onExit: (_) => setState(() => _hovered = false),
            child: animatedBuilder,
          ),
        ),
      ),
    );
  }
}
