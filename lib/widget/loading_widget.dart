import 'package:flutter/material.dart';

Widget loadingWidget() {
  return Flexible(
    child: Center(
      child: SizedBox(
        height: 30.0,
        width: 30.0,
        child: CircularProgressIndicator(
          value: null,
          strokeWidth: 3.0,
        ),
      ),
    ),
  );
}
