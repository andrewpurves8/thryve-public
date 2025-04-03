import 'package:flutter/material.dart';
import 'package:thryve/src/utilities/constants.dart';
import 'package:thryve/src/utilities/helpers.dart';

class SmallTextField extends StatefulWidget {
  const SmallTextField({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  final String initialValue;
  final void Function(String)? onChanged;

  @override
  State<SmallTextField> createState() => _SmallTextFieldState();
}

class _SmallTextFieldState extends State<SmallTextField> {
  late final _controller = TextEditingController(text: widget.initialValue);

  @override
  Widget build(BuildContext context) {
    final dimension = getCircleDimension(context);
    return SizedBox(
      width: dimension,
      height: dimension,
      child: Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus) {
            _postProcessText();
          }
        },
        child: Center(
          child: TextField(
            controller: _controller,
            readOnly: widget.onChanged == null,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(dimension)),
                borderSide: BorderSide(
                  color: kPrimaryColor,
                  width: 4,
                ),
              ),
              contentPadding: EdgeInsets.fromLTRB(2.0, 0.0, 0.0, 0.0),
            ),
            onTap: () => widget.onChanged != null
                ? _controller.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _controller.value.text.length,
                  )
                : null,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            onChanged: widget.onChanged,
            style: TextStyle(fontSize: convertFontSize(context, 16.0)),
          ),
        ),
      ),
    );
  }

  void _postProcessText() {
    final possibleDouble = double.tryParse(_controller.text);
    if (possibleDouble != null) {
      _controller.text = doubleToTruncatedString(possibleDouble);
    }
  }
}
