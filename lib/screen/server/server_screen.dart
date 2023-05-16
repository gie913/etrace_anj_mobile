import 'package:e_trace_app/base/path/image_path.dart';
import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_trace_app/database_local/database_helper.dart';
import 'package:e_trace_app/database_local/database_entity.dart';
import 'package:toast/toast.dart';
import 'package:sqflite/sqflite.dart';

class ServerScreen extends StatefulWidget {
  @override
  _ServerScreenState createState() => _ServerScreenState();
}

class _ServerScreenState extends State<ServerScreen> {
  final serverAddressController = new TextEditingController();
  String userBaseUrl;

  @override
  void initState() {
    // checkBaseUrl();
    super.initState();
  }

  void checkBaseUrl() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userBaseUrl = prefs.getString('baseUrl');
    if (userBaseUrl != null) {
      setState(() {
        serverAddressController.text = userBaseUrl;
      });
    }
  }


  void resetData() async {
    Database db = await DatabaseHelper().database;
    int deletedHarvestTicket = await db.delete(TABLE_HARVEST_TIKET);
    int deleteCollectionPoint = await db.delete(TABLE_COLLECTION_POINT);
    int deleteDeliveryOrder = await db.delete(TABLE_DELIVERY_ORDER);
    int count =
        deletedHarvestTicket + deleteCollectionPoint + deleteDeliveryOrder;
    if (count > 0 || count <= 3) {
      Navigator.pop(context);
      Toast.show("Reset Data Berhasil", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else {
      Toast.show("Tidak Berhasil Reset Data", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  onResetData(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(RESET_DATA),
        content: Text(RESET_DATA_SUBTITLE_DIALOG),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(NO,
                style:
                TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => resetData(),
            child: Text(
              YES,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Konfigurasi Aplikasi"),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 30, top: 40),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(IMAGE_ICON,
                              width:
                              MediaQuery.of(context).size.width * 0.1),
                          Text(
                            "e-Trace",
                            style: TextStyle(
                                fontFamily: "DIN Pro",
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width *
                                    0.1),
                          )
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        onResetData(context);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Reset Data",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Reset Data akan menghapus seluruh data",
                          textAlign: TextAlign.center,
                          style: text16,
                        ),
                      ),
                    ),
                  ]),
            ),
          ),
        ),
    );
  }
}
