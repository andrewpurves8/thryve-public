import 'package:flutter/material.dart';
import 'package:thryve/src/utilities/helpers.dart';

class ThryveTextField extends StatelessWidget {
  ThryveTextField({
    super.key,
    required this.labelText,
    this.onChanged,
    this.obscureText = false,
    this.errorText,
    this.keyboardType,
    this.onTap,
    this.value,
    this.readOnly = false,
    this.maxLines = 1,
  });

  final String labelText;
  final Function(String)? onChanged;
  final bool obscureText;
  final String? errorText;
  final TextInputType? keyboardType;
  final Function()? onTap;
  final String? value;
  final bool readOnly;
  final int? maxLines;

  late final controller = TextEditingController(text: value);

  @override
  Widget build(BuildContext context) {
    if (value != null) {
      controller.text = value!;
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: getHorizontalMargin(context)),
      child: TextField(
        decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            labelText: labelText,
            errorText: errorText),
        onChanged: onChanged,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onTap: onTap,
        readOnly: readOnly,
        controller: (value != null) ? controller : null,
        maxLines: maxLines,
      ),
    );
  }
}
