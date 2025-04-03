import 'package:flutter/material.dart';
import 'package:thryve/src/utilities/constants.dart';
import 'package:thryve/src/utilities/helpers.dart';

class CircledIconButton extends StatelessWidget {
  const CircledIconButton({
    super.key,
    required this.icon,
    this.onPressed,
  });

  final IconData icon;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final dimension = getCircleDimension(context);
    return Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        border: Border.all(color: kWhite),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: GestureDetector(
          onTap: onPressed,
          child: Icon(icon, color: kWhite),
        ),
      ),
    );
  }
}
