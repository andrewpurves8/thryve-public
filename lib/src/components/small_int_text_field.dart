import 'package:flutter/material.dart';
import 'package:thryve/src/components/small_text_field.dart';

class SmallIntTextField extends StatelessWidget {
  const SmallIntTextField({
    super.key,
    required this.initialValue,
    this.onChanged,
  });

  final int initialValue;
  final void Function(int)? onChanged;

  @override
  Widget build(BuildContext context) {
    return SmallTextField(
        initialValue: initialValue.toString(),
        onChanged: onChanged != null
            ? (value) => onChanged!(int.tryParse(value) ?? 0)
            : null);
  }
}
