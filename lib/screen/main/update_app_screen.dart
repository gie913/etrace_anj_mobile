import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/base/path/image_path.dart';

class UpdateAppScreen extends StatefulWidget {
  final String directLink;

  UpdateAppScreen(this.directLink);

  @override
  _UpdateAppScreenState createState() => _UpdateAppScreenState();
}

class _UpdateAppScreenState extends State<UpdateAppScreen> {
  OtaEvent? currentEvent;

  @override
  void initState() {
    super.initState();
    tryOtaUpdate();
  }

  Future<void> tryOtaUpdate() async {
    try {
      OtaUpdate()
          .execute(
              "https://etrace.anj-group.co.id/download/beta-release-0.7.2.apk",
              destinationFilename: 'beta-release-0.7.2.apk')
          .listen(
        (OtaEvent event) {
          setState(() => currentEvent = event);
        },
      );
    } catch (e) {
      print('Failed to make OTA update. Details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentEvent == null) {
      return Scaffold();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update E-Trace'),
        leading: Container(),
      ),
      body: Center(
        child: Container(
          height: 300,
          alignment: Alignment.center,
          child: Column(
            children: [
              Image.asset(IMAGE_LOGO,
                  width: MediaQuery.of(context).size.width * 0.5),
              Text(
                '${currentEvent!.value} %',
                style: text16Bold,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Update status: ${currentEvent!.status}'),
              ),
              (currentEvent!.status.toString() == "OtaStatus.INSTALLING")
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Jika tidak dapat terinstall, lakukan secara manual di folder download',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
