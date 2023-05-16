import 'package:e_trace_app/base/strings/constants.dart';
import 'package:flutter/material.dart';

openWarningDialog(BuildContext context, String message) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
          title: Text("Login Gagal"),
          content: Text(message),
          actions: <Widget>[
            new TextButton(
                child: new Text(OK, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        );
      }).then((val) {
    Navigator.pop(context);
  });
}
