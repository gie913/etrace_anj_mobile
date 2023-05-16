import 'dart:io';

import 'package:e_trace_app/base/strings/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<bool> onWillPop(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Keluar'),
      content: Text('Apakah Anda ingin keluar ?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => exit(0),
          child: Text(YES, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(NO, style : TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}
