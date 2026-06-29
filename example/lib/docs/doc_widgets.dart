import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:termos_ui/termos_ui.dart';

/// A single documented widget: title, blurb, live demo, parameter controls, and
/// a copy-pasteable usage snippet. The building block of every docs page.
class DocSection extends StatelessWidget {
  const DocSection({
    super.key,
    required this.title,
    required this.description,
    required this.demo,
    this.controls = const [],
    this.code,
    this.demoBackground = true,
  });

  /// Widget name, e.g. `TermosButton`.
  final String title;

  /// One- or two-line description of what the widget is for.
  final String description;

  /// The live, interactive demo.
  final Widget demo;

  /// Parameter controls (slider/switch rows) specific to this widget.
  final List<Widget> controls;

  /// Optional Dart usage snippet reflecting the current control values.
  final String? code;

  /// Whether to frame the demo in a bordered card (off for things that bring
  /// their own surface, like the nav bar).
  final bool demoBackground;

  @override
  Widget build(BuildContext context) {
    final t = TermosTheme.of(context);
    final colors = t.colors;
    final text = t.textStyles;

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SelectableText(title, style: text.sectionTitle(colors.textPrimary)),
          const SizedBox(height: 4),
          SelectableText(description, style: text.body(colors.textMuted)),
          const SizedBox(height: 16),
          if (demoBackground)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: demo,
            )
          else
            demo,
          if (controls.isNotEmpty) ...[
            const SizedBox(height: 20),
            _Subhead(label: 'Parameters', colors: colors, text: text),
            const SizedBox(height: 8),
            ...controls,
          ],
          if (code != null) ...[
            const SizedBox(height: 12),
            _Subhead(label: 'Usage', colors: colors, text: text),
            const SizedBox(height: 8),
            CodeBlock(code: code!),
          ],
        ],
      ),
    );
  }
}

class _Subhead extends StatelessWidget {
  const _Subhead({required this.label, required this.colors, required this.text});

  final String label;
  final TermosColors colors;
  final TermosTextStyles text;

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      label.toUpperCase(),
      style: text.codePrimary(colors.textMuted).copyWith(
        fontSize: 11,
        letterSpacing: 1.5,
      ),
    );
  }
}

/// A monospaced, selectable code block with a copy button.
class CodeBlock extends StatelessWidget {
  const CodeBlock({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final t = TermosTheme.of(context);
    final colors = t.colors;
    final text = t.textStyles;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SelectableText(
              code,
              style: text.codePrimary(colors.textPrimary).copyWith(
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
          ),
          _CopyButton(code: code, colors: colors, text: text),
        ],
      ),
    );
  }
}

class _CopyButton extends StatefulWidget {
  const _CopyButton({required this.code, required this.colors, required this.text});

  final String code;
  final TermosColors colors;
  final TermosTextStyles text;

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: widget.code));
        if (!mounted) return;
        setState(() => _copied = true);
        await Future<void>.delayed(const Duration(seconds: 2));
        if (mounted) setState(() => _copied = false);
      },
      child: Text(
        _copied ? 'Copied' : 'Copy',
        style: widget.text.codePrimary(widget.colors.primary).copyWith(fontSize: 12),
      ),
    );
  }
}

/// A labelled coarse-step slider row.
class SliderRow extends StatelessWidget {
  const SliderRow({
    super.key,
    required this.label,
    required this.value,
    required this.start,
    required this.end,
    required this.step,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double start;
  final double end;
  final double step;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = TermosTheme.of(context);
    return _ControlShell(
      label: label,
      colors: t.colors,
      text: t.textStyles,
      child: TermosSlider(
        value: value,
        start: start,
        end: end,
        step: step,
        compact: true,
        onChanged: onChanged,
      ),
    );
  }
}

/// A labelled fine-grained slider row (major divisions + subdivisions).
class DetailedSliderRow extends StatelessWidget {
  const DetailedSliderRow({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.subdivisions,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final int subdivisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = TermosTheme.of(context);
    return _ControlShell(
      label: label,
      colors: t.colors,
      text: t.textStyles,
      child: TermosDetailedSlider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        subdivisions: subdivisions,
        compact: true,
        onChanged: onChanged,
      ),
    );
  }
}

/// A labelled continuous slider row.
class ContinuousSliderRow extends StatelessWidget {
  const ContinuousSliderRow({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = TermosTheme.of(context);
    return _ControlShell(
      label: label,
      colors: t.colors,
      text: t.textStyles,
      child: TermosContinuousSlider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        compact: true,
        onChanged: onChanged,
      ),
    );
  }
}

/// A labelled switch row.
class SwitchRow extends StatelessWidget {
  const SwitchRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = TermosTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: SelectableText(
              label,
              style: t.textStyles
                  .codePrimary(t.colors.textMuted)
                  .copyWith(fontSize: 12),
            ),
          ),
          TermosSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ControlShell extends StatelessWidget {
  const _ControlShell({
    required this.label,
    required this.child,
    required this.colors,
    required this.text,
  });

  final String label;
  final Widget child;
  final TermosColors colors;
  final TermosTextStyles text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            label,
            style: text.codePrimary(colors.textMuted).copyWith(fontSize: 12),
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          child,
        ],
      ),
    );
  }
}
