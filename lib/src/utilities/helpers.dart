import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:thryve/src/utilities/constants.dart';

void showToast(String text) {
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey.shade300,
      textColor: Colors.black,
      fontSize: 16.0);
}

double doubleFromMongo(Map<String, dynamic> mongoVal) {
  return double.parse(mongoVal['\$numberDecimal']);
}

double getHorizontalMargin(BuildContext context) {
  return MediaQuery.of(context).size.width * kHorizontalMarginMultiplier;
}

double getCircleDimension(BuildContext context) {
  return MediaQuery.of(context).size.width * kCircleWidthMultiplier;
}

double convertFontSize(BuildContext context, double fontSize) {
  return fontSize * MediaQuery.of(context).size.width * kFontSizeMultiplier;
}

String durationToString(Duration duration) {
  String negativeSign = duration.isNegative ? '-' : '';
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
  String hours = duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : '';
  return "$negativeSign$hours$twoDigitMinutes:$twoDigitSeconds";
}

String doubleToTruncatedString(double value) {
  RegExp regex = RegExp(r'([.]*0)(?!.*\d)');
  return value.toString().replaceAll(regex, '');
}

double calculateOneRepMax(double weight, int reps) {
  return weight * (36 / (37 - reps));
  // return weight * (1 + 0.0333 * reps);
  // return (100 * weight) / (101.3 - 2.67123 * reps);
}

int compare(double a, double b) {
  if (a < b) {
    return -1;
  } else if (a > b) {
    return 1;
  } else {
    return 0;
  }
}
