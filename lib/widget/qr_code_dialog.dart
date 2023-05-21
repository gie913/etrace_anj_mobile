import 'dart:async';
import 'dart:ui' as ui;

import 'package:e_trace_app/base/path/image_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeDialog extends StatelessWidget {
  final String? message;

  QRCodeDialog({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      alignment: Alignment.center,
      child: FutureBuilder(
        future: _loadOverlayImage(),
        builder: (ctx, snapshot) {
          return CustomPaint(
            size: Size.square(200.0),
            painter: QrPainter(
              data: message!,
              version: QrVersions.auto,
              embeddedImage: snapshot.data,
              embeddedImageStyle: QrEmbeddedImageStyle(
                size: Size.square(40),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<ui.Image> _loadOverlayImage() async {
    final completer = Completer<ui.Image>();
    final byteData = await rootBundle.load(IMAGE_QRCODE);
    ui.decodeImageFromList(byteData.buffer.asUint8List(), completer.complete);
    return completer.future;
  }
}
