import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:e_trace_app/base/path/image_path.dart';
import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/base/ui/palette.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/database_local/database_collection_point.dart';
import 'package:e_trace_app/database_local/database_farmer_transaction.dart';
import 'package:e_trace_app/database_local/database_harvest_ticket.dart';
import 'package:e_trace_app/model/delivery_order.dart';
import 'package:e_trace_app/model/farmer_transaction.dart';
import 'package:e_trace_app/model/harvesting_ticket.dart';
import 'package:e_trace_app/utils/separator_thousand.dart';
import 'package:e_trace_app/utils/storage_manager.dart';
import 'package:e_trace_app/widget/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRScreenDelivery extends StatefulWidget {
  final String message;
  final DeliveryOrder deliveryOrder;
  final List<HarvestingTicket> listHarvestingTicket;

  QRScreenDelivery(
      {this.message, this.deliveryOrder, this.listHarvestingTicket});

  @override
  _QRScreenDeliveryState createState() => _QRScreenDeliveryState();
}

class _QRScreenDeliveryState extends State<QRScreenDelivery> {
  GlobalKey _globalKey = new GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _controller = ScreenshotController();
  String company;

  File image;
  final picker = ImagePicker();

  Future getImage() async {
    await picker.getImage(source: ImageSource.gallery);
  }

  @override
  void initState() {
    initQRCodeScreen();
    super.initState();
  }

  initQRCodeScreen() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      company = pref.getString('userPT');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text("e-SPB TBS"),
        actions: [
          InkWell(
            onTap: () {
              _saveScreen();
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Icon(Icons.save),
            ),
          ),
          InkWell(
            onTap: () {
              shareScreenshot();
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Icon(Icons.share),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: RepaintBoundary(
          key: _globalKey,
          child: Screenshot(
            controller: _controller,
            child: Card(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20, left: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Icon(
                                    Linecons.truck,
                                    size: 30,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text("e-SP TBS", style: text24BoldBlack),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Column(
                                children: [
                                  Text(
                                    "Tanggal",
                                    style: text14BoldBlack,
                                  ),
                                  Text("${widget.deliveryOrder.dateDelivery}",
                                      style: text14Black)
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: 3,
                        color: Colors.blue,
                        margin: EdgeInsets.all(12),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "ID Surat Pengantar",
                                  style: text16Black,
                                ),
                                Text("${widget.deliveryOrder.idDelivery}",
                                    style: text16BoldBlack),
                              ],
                            ),
                            Divider(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Supplier",
                                      style: text16Black,
                                    ),
                                    Text(
                                      "${widget.deliveryOrder.supplierName}",
                                      style: text16BoldBlack,
                                    )
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Pembuat",
                                      style: text16Black,
                                    ),
                                    Text("${widget.deliveryOrder.createdBy}",
                                        style: text16BoldBlack)
                                  ],
                                ),
                              ],
                            ),
                            Divider(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Supir",
                                      style: text16Black,
                                    ),
                                    Text("${widget.deliveryOrder.driverName}",
                                        style: text16BoldBlack)
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Plat Nomor",
                                      style: text16Black,
                                    ),
                                    Text("${widget.deliveryOrder.platNumber}",
                                        style: text16BoldBlack)
                                  ],
                                ),
                              ],
                            ),
                            Divider(),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              child: FutureBuilder(
                                future: _loadOverlayImage(),
                                builder: (ctx, snapshot) {
                                  return CustomPaint(
                                    size: Size.square(220.0),
                                    painter: QrPainter(
                                      data: widget.message,
                                      version: QrVersions.auto,
                                      embeddedImage: snapshot.data,
                                      embeddedImageStyle: QrEmbeddedImageStyle(
                                        size: Size.square(50),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    height: widget.listHarvestingTicket.length * 80.toDouble(),
                    child: ListView.builder(
                      itemCount: widget.listHarvestingTicket.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(
                                  Linecons.note,
                                  size: 30,
                                  color: Colors.orange,
                                ),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "Kode Areal: ${widget.listHarvestingTicket[index].ascendFarmerCode}",
                                            style: text16BoldBlack),
                                        Text(
                                            "Janjang/Berat(Kg): ${widget.listHarvestingTicket[index].quantity}/${formatThousandSeparator(widget.listHarvestingTicket[index].weight.round())}",
                                            style: text16Black),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Divider()
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    padding: EdgeInsets.only(left: 20),
                    color: Colors.black12,
                    width: MediaQuery.of(context).size.width,
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text("$company", style: text16BoldBlack)],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Card(
        color: Colors.green,
        child: OutlinedButton(
          onPressed: () {
            doneQRDialog(context);
          },
          child: Text(
            "Selesai",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  updateTonnagePerYearFarmer() async {
    for (int i = 0; i < widget.listHarvestingTicket.length; i++) {
      DatabaseFarmerTransaction()
          .selectFarmerTransactionByFarmer(
              widget.listHarvestingTicket[i].ascendFarmerCode)
          .then((value) => {
                if (value != null)
                  {
                    setSumKgPerYear(
                        widget.listHarvestingTicket[i].quantity, value)
                  }
              });
    }
  }

  setSumKgPerYear(int janjang, Farmer farmer) async {
    double abw = await StorageManager.readData("abw");
    int useMaxTonnage = await StorageManager.readData("useMaxTonnage");
    if (useMaxTonnage == 1) {
      if (abw != null) {
        int month = DateTime.now().month;
        double estimationKg = (abw * janjang);
        List<dynamic> list = jsonDecode(farmer.trMonth);
        list[month - 1] = list[month - 1] + estimationKg.toInt();
        farmer.trMonth = list.toString();
        DatabaseFarmerTransaction().updateFarmerTransaction(farmer);
      }
    }
  }

  doneQRDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pastikan Data Sudah Benar'),
        content: Text('Sebelum dikirim ke Timbangan'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(14),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Text(NO,
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (this.widget.deliveryOrder.transferred != "true") {
                    updateTonnagePerYearFarmer();
                  }
                  this.widget.deliveryOrder.transferred = "true";
                  DatabaseHarvestTicket().updateHarvestTicketDeliveryTransfer(
                      this.widget.deliveryOrder.idDelivery);
                  DatabaseCollectionPoint()
                      .updateCollectionPointDeliveryTransfer(
                          this.widget.deliveryOrder.idDelivery);
                });
                Navigator.pop(context, this.widget.deliveryOrder);
                Navigator.pop(context, this.widget.deliveryOrder);
              },
              child: Text(YES,
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  _saveScreen() async {
    var status = await Permission.storage.request();
    print(status);
    RenderRepaintBoundary boundary =
        _globalKey.currentContext.findRenderObject() as RenderRepaintBoundary;
    loadingDialog(context);
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData byteData =
        await (image.toByteData(format: ui.ImageByteFormat.png));
    if (byteData != null) {
      final result = await ImageGallerySaver.saveImage(
          byteData.buffer.asUint8List(),
          name:
              "${widget.deliveryOrder.idDelivery}_${widget.deliveryOrder.dateDelivery}");
      if (result != null) {
        print(result.toString());
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Berhasil disimpan',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          backgroundColor: primaryColor,
          action: SnackBarAction(
            label: 'Open',
            onPressed: () {
              getImage();
            },
          ),
          duration: Duration(seconds: 5),
        ));
      }
    }
  }

  Future<ui.Image> _loadOverlayImage() async {
    final completer = Completer<ui.Image>();
    final byteData = await rootBundle.load(IMAGE_QRCODE);
    ui.decodeImageFromList(byteData.buffer.asUint8List(), completer.complete);
    return completer.future;
  }

  shareScreenshot() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 2);
      final directory = (await getExternalStorageDirectory()).path;
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      File imgFile = new File(
          '$directory/"${widget.deliveryOrder.idDelivery}_${widget.deliveryOrder.dateDelivery}".png');
      imgFile.writeAsBytes(pngBytes);
      final RenderBox box = context.findRenderObject();
      Share.shareFiles([
        File('$directory/"${widget.deliveryOrder.idDelivery}_${widget.deliveryOrder.dateDelivery}".png')
            .path
      ],
          subject: 'Share File',
          text: 'Halo, ini surat pengantar TBS yang harus dikirimkan',
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } on PlatformException catch (e) {
      print("Exception while taking screenshot:" + e.toString());
    }
  }
}
