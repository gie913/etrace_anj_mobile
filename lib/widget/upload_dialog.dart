import 'package:e_trace_app/screen/home/upload_data.dart';
import 'package:e_trace_app/widget/loading_dialog.dart';
import 'package:flutter/material.dart';

showUploadDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Unggah Data"),
        content: Text("Unggah Data ke Server"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              child: Text("Batal", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              child: Text("Lanjutkan", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              onTap: () {
                loadingDialog(context);
                UploadData(context).onInitialUpload();
              },
            ),
          ),
        ],
      );
    },
  );
}
