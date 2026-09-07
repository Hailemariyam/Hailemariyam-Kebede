import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// A row of [length] single-digit, obscured boxes that together form the PIN.
/// Emits the full string on every change and auto-submits when it fills.
class PinInput extends StatefulWidget {
  const PinInput({
    super.key,
    this.length = 4,
    required this.onChanged,
    this.onCompleted,
    this.hasError = false,
    this.enabled = true,
    this.autofocus = true,
  });

  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final bool hasError;
  final bool enabled;
  final bool autofocus;

  @override
  State<PinInput> createState() => PinInputState();
}

class PinInputState extends State<PinInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _value => _controllers.map((c) => c.text).join();

  /// Public: let the page reset the field (e.g. after a failed attempt).
  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    if (mounted) {
      setState(() {});
      _nodes.first.requestFocus();
    }
  }

  void _handleChange(int index, String raw) {
    // Support paste of the whole code into one box.
    if (raw.length > 1) {
      final digits = raw.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < widget.length; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      final next = digits.length.clamp(0, widget.length - 1);
      _nodes[next].requestFocus();
    } else if (raw.isNotEmpty && index < widget.length - 1) {
      _nodes[index + 1].requestFocus();
    } else if (raw.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
    }

    setState(() {});
    widget.onChanged(_value);
    if (_value.length == widget.length) {
      widget.onCompleted?.call(_value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.length, (i) {
        final filled = _controllers[i].text.isNotEmpty;
        final borderColor = widget.hasError
            ? AppColors.error
            : (filled ? AppColors.primary : AppColors.divider);
        return SizedBox(
          width: 60,
          height: 68,
          child: TextField(
            controller: _controllers[i],
            focusNode: _nodes[i],
            enabled: widget.enabled,
            autofocus: widget.autofocus && i == 0,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            obscureText: true,
            obscuringCharacter: '●',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            cursorColor: AppColors.primary,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: filled
                  ? AppColors.primary.withValues(alpha: 0.06)
                  : AppColors.scaffoldBackground,
              contentPadding: EdgeInsets.zero,
              enabledBorder: _boxBorder(
                borderColor,
                width: filled || widget.hasError ? 2 : 1,
              ),
              focusedBorder: _boxBorder(AppColors.primary, width: 2),
              disabledBorder: _boxBorder(borderColor),
            ),
            onChanged: (v) => _handleChange(i, v),
          ),
        );
      }),
    );
  }

  OutlineInputBorder _boxBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
