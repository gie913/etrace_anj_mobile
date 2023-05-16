import 'package:e_trace_app/base/strings/constants.dart';
import 'package:flutter/material.dart';

Future<bool> onWillPopForm(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Keluar Form'),
      content: Text('Anda belum menyimpan data, \nApakah Anda ingin keluar dari form ?'),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.all(14),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child: Text(NO, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(true),
            child: Text(YES, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    ),
  );
}
