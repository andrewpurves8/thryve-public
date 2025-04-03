import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.color,
    required this.textColor,
    this.iconLeading,
    this.iconTrailing,
    this.enabled = true,
  });

  final String text;
  final Function() onPressed;
  final Color color;
  final Color textColor;
  final IconData? iconLeading;
  final IconData? iconTrailing;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    List<Widget> contents = [];
    if (iconLeading != null) {
      contents.add(Icon(iconLeading, color: textColor));
      contents.add(const SizedBox(width: 10.0));
    }
    contents.add(
      Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    if (iconTrailing != null) {
      contents.add(const SizedBox(width: 10.0));
      contents.add(Icon(iconTrailing, color: textColor));
    }

    return FittedBox(
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(color),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Row(
            children: contents,
          ),
        ),
      ),
    );
  }
}
