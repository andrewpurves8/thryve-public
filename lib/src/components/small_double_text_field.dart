import 'package:flutter/material.dart';
import 'package:thryve/src/components/small_text_field.dart';
import 'package:thryve/src/utilities/helpers.dart';

class SmallDoubleTextField extends StatelessWidget {
  const SmallDoubleTextField({
    super.key,
    required this.initialValue,
    this.onChanged,
  });

  final double initialValue;
  final void Function(double)? onChanged;

  @override
  Widget build(BuildContext context) {
    return SmallTextField(
        initialValue: doubleToTruncatedString(initialValue),
        onChanged: onChanged != null
            ? (value) => onChanged!(double.tryParse(value) ?? 0)
            : null);
  }
}
