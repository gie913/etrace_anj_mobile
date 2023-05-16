import 'dart:async';

import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/base/ui/palette.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/database_local/database_farmer.dart';
import 'package:e_trace_app/database_local/database_harvest_ticket.dart';
import 'package:e_trace_app/database_local/database_helper.dart';
import 'package:e_trace_app/model/farmers.dart';
import 'package:e_trace_app/model/harvesting_ticket.dart';
import 'package:e_trace_app/model/transfer_response.dart';
import 'package:e_trace_app/model/user.dart';
import 'package:e_trace_app/screen/harvest_ticket/harvest_ticket_form.dart';
import 'package:e_trace_app/screen/harvest_ticket/send_harvest_ticket.dart';
import 'package:e_trace_app/screen/harvest_ticket/transfer_harvest_ticket.dart';
import 'package:e_trace_app/screen/harvest_ticket/transfer_repository.dart';
import 'package:e_trace_app/utils/separator_thousand.dart';
import 'package:e_trace_app/widget/loading_dialog.dart';
import 'package:e_trace_app/widget/qr_code_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lzstring/lzstring.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:screen/screen.dart';
import 'package:toast/toast.dart';

class HarvestTicketDetail extends StatefulWidget {
  final HarvestingTicket harvestTicket;

  HarvestTicketDetail({this.harvestTicket});

  @override
  HarvestTicketDetailState createState() =>
      HarvestTicketDetailState(this.harvestTicket);
}

class HarvestTicketDetailState extends State<HarvestTicketDetail> {
  HarvestTicketDetailState(this.harvestTicket);

  HarvestingTicket harvestTicket;

  DatabaseHelper dbHelper = DatabaseHelper();
  DatabaseHarvestTicket dbHarvest = DatabaseHarvestTicket();
  final controller = PageController();

  Position position;
  String message, uncompressed;
  Farmers farmerObject = Farmers();
  double brightnessInit;
  TextEditingController userTargetController = TextEditingController();

  // List<RecordEditor> _records = [];
  // bool _hasClosedWriteDialog = false;
  User userTarget;
  String menuTransfer;

  @override
  void initState() {
    getFarmerByID(widget.harvestTicket);
    super.initState();
  }

  void getFarmerByID(HarvestingTicket harvestTicket) async {
    Farmers farmers = await DatabaseFarmer().selectFarmerByID(harvestTicket);
    double brightness = await Screen.brightness;
    setState(() {
      this.brightnessInit = brightness;
      this.farmerObject = farmers;
    });
  }
  //
  // void _write(BuildContext context) async {
  //   List<NDEFRecord> records = _records.map((record) {
  //     return NDEFRecord.type(
  //       "Plain/Text",
  //       this.uncompressed,
  //     );
  //   }).toList();
  //   NDEFMessage message = NDEFMessage.withRecords(records);
  //   if (Platform.isAndroid) {
  //     showDialog(
  //       barrierDismissible: false,
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           backgroundColor: Colors.white,
  //           title: Center(
  //               child: Text("Tempel Kartu NFC",
  //                   style: TextStyle(color: Colors.black))),
  //           content: Container(
  //             height: 200,
  //             child: Column(
  //               children: [
  //                 Center(
  //                   child: Container(
  //                     margin: EdgeInsets.only(bottom: 10),
  //                     width: 100,
  //                     child: Image.asset("assets/tap-nfc.jpg"),
  //                   ),
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: Text(
  //                     "Untuk memasukkan data",
  //                     style: TextStyle(color: Colors.black),
  //                   ),
  //                 ),
  //                 Card(
  //                   color: primaryColor,
  //                   child: InkWell(
  //                     onTap: () {
  //                       _hasClosedWriteDialog = true;
  //                       Navigator.pop(context);
  //                     },
  //                     child: Container(
  //                       width: MediaQuery.of(context).size.width,
  //                       padding: EdgeInsets.all(10),
  //                       child: Center(
  //                           child: Text(CANCEL,
  //                               style: TextStyle(
  //                                   color: Colors.white,
  //                                   fontSize: 16,
  //                                   fontWeight: FontWeight.bold))),
  //                     ),
  //                   ),
  //                 )
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     );
  //   }
  //
  //   NDEFTag result = await NFC.writeNDEF(message).first;
  //   if (result != null) {
  //     if (!_hasClosedWriteDialog) {
  //       Toast.show("Data Sudah Tersimpan", context,
  //           duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  //       setState(() {
  //         this.harvestTicket.transferred = "true";
  //       });
  //       Navigator.pop(context, harvestTicket);
  //     }
  //   } else {
  //     Toast.show("Gagal Tersimpan", context,
  //         duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  //   }
  // }

  Future<String> compress(String uncompressed) async {
    final result = await LZString.compressToBase64(uncompressed);
    Screen.setBrightness(0.7);
    showQRCodeDialog(context, uncompressed);
    return result;
  }

  Future<HarvestingTicket> navigateToEntryForm(
      BuildContext context, HarvestingTicket contact) async {
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return HarvestTicketForm(harvestTicket: contact);
    }));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, harvestTicket);
        return true;
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(10.0),
              child: InkWell(
                  onTap: () {
                    Navigator.pop(context, harvestTicket);
                  },
                  child: Icon(Icons.arrow_back)),
            ),
            title: Text("Detail Tiket Panen"),
            actions: [
              (harvestTicket.transferred == "true" ||
                      harvestTicket.idCollectionTicket != null ||
                      harvestTicket.idDeliveryOrderTicket != null)
                  ? Container()
                  : InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: InkWell(
                            onTap: () async {
                              var contact = await navigateToEntryForm(
                                  context, widget.harvestTicket);
                              if (contact != null) editHarvestTicket(contact);
                            },
                            child: Icon(Typicons.edit)),
                      ),
                    )
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: TabBar(
                tabs: [
                  Tab(text: "Detail"),
                  Tab(text: "Kirim"),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              SingleChildScrollView(
                child: Card(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    margin: EdgeInsets.only(left: 4, top: 4),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          height: 5,
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          ),
                        ),
                        Column(
                          children: [
                            Container(
                                margin: EdgeInsets.only(bottom: 20),
                                alignment: Alignment.center,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Icon(Linecons.note,
                                          size: 40, color: Colors.orange),
                                    ),
                                    Container(
                                        child: Text(HARVEST_TICKET,
                                            style: text18Bold)),
                                  ],
                                )),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(ID_HARVEST_TICKET_FORM, style: text16Bold),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 6.0, bottom: 10.0),
                                  child: Text(widget.harvestTicket.idTicket,
                                      style: text16Bold),
                                )
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(DATE_FORM, style: text14Bold),
                                SelectableText(harvestTicket.dateTicket)
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(GPS_LOCATION_FORM, style: text14Bold),
                                Text("${harvestTicket.gpsLat ?? ""},${harvestTicket.gpsLong ?? ""}", overflow: TextOverflow.ellipsis)
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Text("Areal", style: text14Bold),
                                ),
                              ],
                            ),
                            Table(
                              border: TableBorder.all(),
                              children: [
                                TableRow(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("Kode Areal",
                                        textAlign: TextAlign.center),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Petani',
                                        textAlign: TextAlign.center),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Desa',
                                        textAlign: TextAlign.center),
                                  ),
                                ]),
                                TableRow(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        "${farmerObject.ascendFarmerCode}",
                                        textAlign: TextAlign.center),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("${farmerObject.fullname}",
                                        textAlign: TextAlign.center),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("${farmerObject.address}",
                                        textAlign: TextAlign.center),
                                  )
                                ]),
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(QUANTITY, style: text14Bold),
                                SelectableText("${harvestTicket.quantity}")
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(WEIGHT_JANJANG, style: text14Bold),
                                SelectableText(
                                    "${formatThousandSeparator(harvestTicket.weight.round())}")
                              ],
                            ),
                            // Divider(),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Text(CARD_NUMBER, style: text14Bold),
                            //     SelectableText("${harvestTicket.nfcNumber}")
                            //   ],
                            // ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Catatan", style: text14Bold),
                                SelectableText("${harvestTicket.note}")
                              ],
                            ),
                            Divider(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.9,
                margin: EdgeInsets.only(right: 4, top: 4),
                padding: EdgeInsets.all(20),
                child: harvestTicket.transferred != "true"
                    ? (harvestTicket.idCollectionTicket != null ||
                            harvestTicket.idDeliveryOrderTicket != null)
                        ? Center(child: Text("Tiket Sudah Masuk TK atau SP"))
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: OutlinedButton(
                                              onPressed: () {
                                                setState(() {
                                                  menuTransfer = "QR";
                                                  transferDialog();
                                                });
                                              },
                                              child: Container(
                                                height: 100,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.qr_code_rounded,
                                                      size: 30,
                                                      color: Colors.white,
                                                    ),
                                                    Text(
                                                      " Kode QR",
                                                      style: buttonStyle22,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: OutlinedButton(
                                              onPressed: () {
                                                setState(() {
                                                  menuTransfer = "Internet";
                                                  transferDialog();
                                                });
                                              },
                                              child: Container(
                                                height: 100,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .signal_cellular_alt_outlined,
                                                      size: 30,
                                                      color: Colors.white,
                                                    ),
                                                    Text(
                                                      " Internet",
                                                      style: buttonStyle22,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Padding(
                                          //   padding: const EdgeInsets.all(8.0),
                                          //   child: OutlinedButton(
                                          //     onPressed: () {
                                          //       doSetNFC();
                                          //     },
                                          //     child: Container(
                                          //       height: 100,
                                          //       width: MediaQuery.of(context)
                                          //           .size
                                          //           .width,
                                          //       child: Row(
                                          //           mainAxisAlignment:
                                          //               MainAxisAlignment
                                          //                   .center,
                                          //           children: [
                                          //             Icon(
                                          //               Icons.nfc_rounded,
                                          //               size: 30,
                                          //               color: Colors.white,
                                          //             ),
                                          //             Text(
                                          //               " NFC",
                                          //               style: buttonStyle22,
                                          //             ),
                                          //           ]),
                                          //     ),
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                    : Center(
                        child: Text("Tiket sudah ditransfer")),
              )
            ],
          ),
        ),
      ),
    );
  }

  showQRCodeDialog(BuildContext context, String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Colors.white,
            title: Center(
                child: Text(
              "QRCode Tiket Panen",
              style: TextStyle(color: Colors.black),
            )),
            content: Container(
              height: 280,
              child: Column(
                children: [
                  Text(
                    "${harvestTicket.idTicket}",
                    style: TextStyle(color: Colors.black),
                  ),
                  QRCodeDialog(message: message),
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(top: 14),
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Card(
                            color: primaryColor,
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  Screen.setBrightness(brightnessInit);
                                });
                              },
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Text(
                                        "  Batal ",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Card(
                            color: primaryColor,
                            child: InkWell(
                              onTap: () {
                                doneQRDialog(context);
                                setState(() {
                                  Screen.setBrightness(brightnessInit);
                                });
                              },
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Text("Selesai",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));
      },
    );
  }

  doneQRDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pastikan Data Sudah Diterima'),
        content: Text('Data tidak akan bisa di transfer lagi'),
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
                  this.harvestTicket.transferred = "true";
                });
                Navigator.pop(context, harvestTicket);
                Navigator.pop(context, harvestTicket);
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

  void editHarvestTicket(HarvestingTicket object) async {
    getFarmerByID(object);
    int result = await dbHarvest.updateHarvestTicket(object);
    if (result > 0) {
      updateListView();
    }
  }

  void updateListView() async {
    final Future<Database> dbFuture = dbHelper.initDb();
    dbFuture.then((database) {
      Future<List<HarvestingTicket>> harvestTicketListFuture =
          dbHarvest.getHarvestTicketList();
      harvestTicketListFuture.then((harvestTicketList) {
        setState(() {});
      });
    });
  }

  transferDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
              child: Text(
            "Masukkan Tujuan Transfer",
            style: text16,
          )),
          content: Container(
            height: 140,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                menuTransfer == "Internet"
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Card(
                            child: Container(
                              padding: EdgeInsets.all(8),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(userTarget == null
                                    ? "Tujuan Pengiriman"
                                    : "${userTarget.name}"),
                              ),
                            ),
                          ),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () async {
                                  User userTargetTemp = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SendHarvestTicket()));
                                  Navigator.pop(context);
                                  setState(() {
                                    userTarget = userTargetTemp;
                                    if (userTargetTemp != null) {
                                      transferDialog();
                                    }
                                  });
                                },
                                child: Container(
                                  child: Icon(Icons.search),
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    : TextField(
                        controller: userTargetController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          hintText: "Nama pengguna",
                          filled: true,
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton(
                    onPressed: () {
                      menuTransfer == "Internet"
                          ? doTransferTicket()
                          : doGenerateQR();
                    },
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: menuTransfer == "Internet"
                            ? Text("Kirim", style: buttonStyle16)
                            : menuTransfer == "NFC"
                                ? Text("Masukkan NFC", style: buttonStyle16)
                                : Text("Buat Kode QR", style: buttonStyle16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // void doSetNFC() {
  //   String data = widget.harvestTicket.idTicket +
  //       "," +
  //       widget.harvestTicket.ascendFarmerCode +
  //       "," +
  //       widget.harvestTicket.quantity.toString() +
  //       "," +
  //       widget.harvestTicket.weight.toString();
  //   setState(() {
  //     uncompressed = EncryptData().encryptData(data);
  //     _records.add(RecordEditor("Plain/Text", uncompressed));
  //   });
  //   _write(context);
  // }

  void doGenerateQR() {
    if (userTargetController.text.isNotEmpty) {
      Navigator.pop(context);
      setState(() {
        uncompressed = widget.harvestTicket.idTicket +
            "," +
            widget.harvestTicket.ascendFarmerCode +
            "," +
            widget.harvestTicket.quantity.toString() +
            "," +
            widget.harvestTicket.weight.toString() +
            "," +
            userTargetController.text;
        compress(uncompressed);
      });
    } else {
      Toast.show("Tujuan Belum Ada", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void doTransferTicket() async {
    if (userTarget != null) {
      loadingDialog(context);
      TransferHarvestingTicketBody transferBody =
          TransferHarvestingTicketBody();
      HarvestingTicket harvestingTicket = HarvestingTicket();
      harvestingTicket = this.widget.harvestTicket;
      harvestingTicket.userTargetId = userTarget.id;
      List<HarvestingTicket> listHarvest = [];
      listHarvest.add(harvestingTicket);
      transferBody.harvestingTicket = listHarvest;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('token');
      final String userBaseUrl = prefs.getString('baseUrl');
      TransferRepository(userBaseUrl).doTransferTicket(transferBody, userToken,
          onSuccessTransferCallback, onErrorTransferCallback);
    } else {
      Toast.show("Tujuan Belum Ada", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  onSuccessTransferCallback(TransferResponse transferResponse) {
    Navigator.pop(context);
    Navigator.pop(context);
    setState(() {
      this.harvestTicket.transferred = "true";
    });
    Toast.show("Berhasil terkirim", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  onErrorTransferCallback(response) {
    Toast.show(response.toString(), context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }
}
