import 'package:e_trace_app/base/strings/constants.dart';
import 'package:flutter/material.dart';

import 'loading_progress.dart';

loadingDialog(BuildContext context) {
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0.0,
          child: Container(
            width: 100.0,
            height: 100.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                LoadingProgress(),
                Padding(padding: EdgeInsets.all(10)),
                Text(LOADING)
              ],
            ),
          ),
        );
      });
}
