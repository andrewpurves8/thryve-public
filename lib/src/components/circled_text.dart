import 'package:flutter/material.dart';
import 'package:thryve/src/utilities/constants.dart';
import 'package:thryve/src/utilities/helpers.dart';

class CircledText extends StatelessWidget {
  const CircledText({
    super.key,
    required this.text,
  });

  final String text;

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
        child: Text(
          text,
          style: TextStyle(fontSize: convertFontSize(context, 16.0)),
        ),
      ),
    );
  }
}
