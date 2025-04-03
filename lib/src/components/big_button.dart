import 'package:flutter/material.dart';
import 'package:thryve/src/utilities/constants.dart';
import 'package:thryve/src/utilities/helpers.dart';

class BigButton extends StatelessWidget {
  const BigButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
    this.textColor,
    this.iconLeading,
    this.iconTrailing,
    this.enabled = true,
    this.rounded = true,
  });

  final String text;
  final Function()? onPressed;
  final Color? color;
  final Color? textColor;
  final IconData? iconLeading;
  final IconData? iconTrailing;
  final bool enabled;
  final bool rounded;

  @override
  Widget build(BuildContext context) {
    final buttonWidget = iconTrailing != null
        ? _createTrailingIconWidget(context)
        : iconLeading != null
            ? _createLeadingIconWidget(context)
            : null;
    return GestureDetector(
      onTap: enabled ? (onPressed ?? () {}) : null,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: getHorizontalMargin(context)),
        child: Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: color ?? kPrimaryColor,
            borderRadius: rounded ? BorderRadius.circular(25) : null,
          ),
          child: buttonWidget,
        ),
      ),
    );
  }

  Widget _createLeadingIconWidget(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          iconLeading,
          color: textColor ?? Colors.white,
        ),
        const SizedBox(width: 10),
        _createText(context),
      ],
    );
  }

  Widget _createTrailingIconWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 25, 0),
      child: Row(
        children: [
          Expanded(
            child: Center(child: _createText(context)),
          ),
          Icon(
            iconTrailing,
            color: textColor ?? Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _createText(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        // color: textColor ?? Theme.of(context).colorScheme.onPrimary,
        color: textColor ?? Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
