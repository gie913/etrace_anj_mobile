import 'package:flutter/material.dart';

termAndPolicyDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Container(
            alignment: Alignment.center, child: Text("Syarat dan Kebijakan")),
        content: Container(
          height: 100,
          child: Column(
            children: [
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              child: Text("Batal",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              child: Text("Lanjutkan",
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      );
    },
  );
}
