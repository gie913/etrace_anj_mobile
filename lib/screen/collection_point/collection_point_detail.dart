import 'dart:async';

import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/base/ui/palette.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/database_local/database_collection_point.dart';
import 'package:e_trace_app/database_local/database_harvest_ticket.dart';
import 'package:e_trace_app/database_local/database_helper.dart';
import 'package:e_trace_app/model/agents.dart';
import 'package:e_trace_app/model/collection_point.dart';
import 'package:e_trace_app/model/farmers.dart';
import 'package:e_trace_app/model/harvesting_ticket.dart';
import 'package:e_trace_app/model/transfer_response.dart';
import 'package:e_trace_app/model/user.dart';
import 'package:e_trace_app/screen/collection_point/collection_point_form.dart';
import 'package:e_trace_app/screen/harvest_ticket/send_harvest_ticket.dart';
import 'package:e_trace_app/screen/harvest_ticket/transfer_harvest_ticket.dart';
import 'package:e_trace_app/screen/harvest_ticket/transfer_repository.dart';
import 'package:e_trace_app/utils/separator_thousand.dart';
import 'package:e_trace_app/utils/time_utils.dart';
import 'package:e_trace_app/utils/window_manager.dart';
import 'package:e_trace_app/widget/loading_dialog.dart';
import 'package:e_trace_app/widget/qr_code_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:lzstring/lzstring.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toast/toast.dart';

class CollectionPointDetail extends StatefulWidget {
  final CollectionPoint collectionPoint;

  CollectionPointDetail({this.collectionPoint});

  @override
  CollectionPointDetailState createState() =>
      CollectionPointDetailState(this.collectionPoint);
}

class CollectionPointDetailState extends State<CollectionPointDetail> {
  CollectionPointDetailState(this.collectionPoint);

  CollectionPoint collectionPoint;
  DatabaseCollectionPoint dbCollection = DatabaseCollectionPoint();
  TextEditingController userTargetController = TextEditingController();
  DatabaseHelper dbHelper = DatabaseHelper();

  // List<RecordEditor> _records = [];
  // bool _hasClosedWriteDialog = false;
  User userTarget;
  Map<String, Farmers> mapFarmer = {};
  List<HarvestingTicket> listHarvestTicket = [];
  Position position;
  String compressed, agentName;
  int totalQuantity = 0;
  double totalWeight = 0.0, brightnessInit;
  String userCompany = "";
  Agents agentsObject;
  TextEditingController janjangSplitController = TextEditingController();
  String menuTransfer;
  final controller = PageController();

  @override
  void initState() {
    getHarvestTicketCollectionList();
    getAgentByID(widget.collectionPoint);
    super.initState();
  }

  Future<String> compress(String uncompressed) async {
    final result = await LZString.compress(uncompressed);
    setState(() {
      showQRCodeDialog(context, uncompressed);
    });
    return result;
  }

  //
  // void doSetNFC() {
  //   List<String> dataCollection = [];
  //   for (int i = 0; i < listHarvestTicket.length; i++) {
  //     String dataTicket = listHarvestTicket[i].idTicket +
  //         "," +
  //         listHarvestTicket[i].ascendFarmerCode +
  //         "," +
  //         listHarvestTicket[i].quantity.toString() +
  //         "," +
  //         listHarvestTicket[i].weight.toString() +
  //         "," +
  //         widget.collectionPoint.idCollection;
  //     dataCollection.add(dataTicket);
  //   }
  //   String messageList = dataCollection.join("#");
  //   setState(() {
  //     _records.add(RecordEditor("Plain/Text", messageList));
  //   });
  //   String messageEncrypt = EncryptData().encryptData(messageList);
  //   _write(context, messageEncrypt);
  // }
  //
  // void _write(BuildContext context, String messageList) async {
  //   List<NDEFRecord> records = _records.map((record) {
  //     return NDEFRecord.type(
  //       "Text",
  //       messageList,
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
  //               child: Text(
  //             "Tempel Kartu NFC",
  //             style: TextStyle(color: Colors.black),
  //           )),
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
  //                       child:
  //                           Center(child: Text(CANCEL, style: buttonStyle16)),
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
  //   NDEFTag result = await NFC.writeNDEF(message).first;
  //   if (result != null) {
  //     if (!_hasClosedWriteDialog) {
  //       Toast.show("Data Sudah Tersimpan", context,
  //           duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  //       setState(() {
  //         this.collectionPoint.transferred = "true";
  //         DatabaseHarvestTicket().updateHarvestTicketCollectionTransfer(this.collectionPoint.idCollection);
  //       });
  //       Navigator.pop(context, this.collectionPoint);
  //     }
  //   } else {
  //     Toast.show("Gagal Tersimpan", context,
  //         duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  //   }
  // }

  Future<CollectionPoint> navigateToEntryForm(
      BuildContext context, CollectionPoint contact) async {
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return CollectionPointForm(collectionPoint: contact);
    }));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, collectionPoint);
        return true;
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Detail Titik Kumpul TBS"),
            actions: [
              (collectionPoint.transferred == "true" ||
                      collectionPoint.deliveryCollection != null)
                  ? Container(width: 10)
                  : Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InkWell(
                          onTap: () async {
                            var contact = await navigateToEntryForm(
                                context, widget.collectionPoint);
                            if (contact != null) editCollectionPoint(contact);
                          },
                          child: Icon(Typicons.edit)),
                    ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: TabBar(
                tabs: [
                  Tab(text: "Detail"),
                  Tab(text: "Tiket Panen"),
                  Tab(text: "Kirim"),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              SingleChildScrollView(
                child: Card(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20.0),
                      ),
                    ),
                    height: MediaQuery.of(context).size.height * 0.9,
                    margin: EdgeInsets.only(left: 4, top: 4),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          height: 5,
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
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
                                      child: Icon(Linecons.inbox,
                                          size: 40, color: Colors.green),
                                    ),
                                    Container(
                                        child: Text(COLLECTION_POINT,
                                            style: text18Bold)),
                                  ],
                                )),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(ID_COLLECTION_POINT_FORM,
                                    style: text16Bold),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 6.0, bottom: 10.0),
                                  child: SelectableText(
                                      "${widget.collectionPoint.idCollection}",
                                      style: text16Bold),
                                )
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(DATE_FORM, style: text14Bold),
                                SelectableText(
                                    "${widget.collectionPoint.dateCollection}")
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(GPS_LOCATION_FORM, style: text14Bold),
                                Text(
                                    "${widget.collectionPoint.gpsLat ?? ""},${widget.collectionPoint.gpsLong ?? ""}",
                                    overflow: TextOverflow.ellipsis)
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total Jumlah Janjang",
                                  style: text14Bold,
                                ),
                                SelectableText("$totalQuantity")
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total Berat Janjang",
                                  style: text14Bold,
                                ),
                                SelectableText(
                                    "${formatThousandSeparator(totalWeight.round())}")
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(AGENT_NAME, style: text14Bold),
                                SelectableText(
                                    "${collectionPoint.ascendAgentCode}")
                              ],
                            ),
                            // Divider(),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Text(
                            //       CARD_NUMBER,
                            //       style: text14Bold,
                            //     ),
                            //     SelectableText(
                            //         "${widget.collectionPoint.cardNumber}")
                            //   ],
                            // ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Catatan",
                                  style: text14Bold,
                                ),
                                SelectableText("${widget.collectionPoint.note}")
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(0.0),
                  ),
                ),
                height: MediaQuery.of(context).size.height * 0.9,
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(18),
                      child: Column(
                        children: [
                          (collectionPoint.transferred == "true" ||
                                  collectionPoint.deliveryCollection != null ||
                                  collectionPoint.uploaded == "true")
                              ? Container(width: 10)
                              : Container(
                                  width: 200,
                                  margin: EdgeInsets.only(bottom: 20),
                                  child: OutlinedButton(
                                    onPressed: () {
                                      showSplitDialog(context);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: Icon(
                                              Typicons.flow_merge,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            "Split Titik Kumpul",
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  "Total Jumlah Janjang",
                                  style: text14Bold,
                                ),
                              ),
                              Text("$totalQuantity")
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total Berat Janjang (KG)",
                                style: text14Bold,
                              ),
                              Text(
                                  "${formatThousandSeparator(totalWeight.round())}")
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "Jumlah Tiket Panen",
                                  style: text14Bold,
                                ),
                              ),
                              Text("${listHarvestTicket.length}")
                            ],
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: ListView.builder(
                        itemCount: listHarvestTicket.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: Icon(Linecons.note,
                                        size: 30, color: Colors.orange),
                                    title: Text(
                                      "${listHarvestTicket[index].idTicket}",
                                      style: text16Bold,
                                    ),
                                    subtitle: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Tanggal: " +
                                            listHarvestTicket[index]
                                                .dateTicket),
                                        Text(
                                            "Kode Areal: ${listHarvestTicket[index].ascendFarmerCode}"),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Jumlah/Berat (Kg): " +
                                                "${listHarvestTicket[index].quantity}" +
                                                "/${formatThousandSeparator(listHarvestTicket[index].weight.round())}"),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(),
                  ),
                  height: MediaQuery.of(context).size.height * 0.9,
                  margin: EdgeInsets.only(right: 4, top: 4),
                  padding: EdgeInsets.all(20),
                  child: (collectionPoint.transferred == "true")
                      ? Center(child: Text("Titik Kumpul Sudah Ditransfer"))
                      : (collectionPoint.deliveryCollection != null)
                          ? Center(
                              child: Text(
                                  "Titik Kumpul Sudah Masuk Surat Pengantar"))
                          : Column(
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
                            ))
            ],
          ),
        ),
      ),
    );
  }

  showSplitDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Split Titik Kumpul"),
          content: Container(
            height: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    FilteringTextInputFormatter.deny(RegExp('[ ]')),
                  ],
                  keyboardType: TextInputType.number,
                  controller: janjangSplitController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                    hintText: "Jumlah janjang yang diambil",
                    filled: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Total janjang: $totalQuantity",
                    style: text14Bold,
                  ),
                ),
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
                  if (janjangSplitController.text.isNotEmpty) {
                    if (int.parse(janjangSplitController.text) >
                        totalQuantity) {
                      Toast.show("Melebihi Total Janjang", context,
                          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                    } else {
                      doSplitTicketPanen();
                    }
                  } else {
                    Toast.show("Belum Mengisi Jumlah Janjang", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  _generateQRCode() {
    if (userTargetController.text.isNotEmpty) {
      Navigator.pop(context);
      List<String> dataCollection = [];
      for (int i = 0; i < listHarvestTicket.length; i++) {
        String dataTicket = listHarvestTicket[i].idTicket +
            "," +
            listHarvestTicket[i].ascendFarmerCode +
            "," +
            listHarvestTicket[i].quantity.toString() +
            "," +
            listHarvestTicket[i].weight.toString() +
            "," +
            widget.collectionPoint.idCollection +
            "," +
            userTargetController.text;
        dataCollection.add(dataTicket);
      }
      String message = dataCollection.join("#");
      compress(message);
    } else {
      Toast.show("Tujuan Belum Ada", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  showQRCodeDialog(BuildContext context, String message) {
    secureScreen();
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Colors.white,
            title: Center(
                child: Text(
              "QRCode Titik Kumpul",
              style: TextStyle(color: Colors.black),
            )),
            content: Container(
              height: 290,
              child: Column(
                children: [
                  Text(
                    "${collectionPoint.idCollection}",
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  QRCodeDialog(message: message),
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(top: 20),
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Card(
                            color: primaryColor,
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                disableSecureScreen();
                              },
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Text(
                                        "  Batal  ",
                                        style: buttonStyle16,
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
                              },
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Selesai",
                                        style: buttonStyle16,
                                      ),
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

  void editCollectionPoint(CollectionPoint object) async {
    getAgentByID(object);
    int result = await dbCollection.updateCollectionPoint(object);
    if (result > 0) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = dbHelper.initDb();
    dbFuture.then((database) {
      Future<List<CollectionPoint>> collectionPointListFuture =
          dbCollection.getCollectionPointList();
      collectionPointListFuture.then((collectionPointList) {
        setState(() {
          getHarvestTicketCollectionList();
        });
      });
    });
  }

  getHarvestTicketCollectionList() async {
    setState(() {
      this.totalWeight = 0.0;
      this.totalQuantity = 0;
    });
    List<HarvestingTicket> list = await DatabaseHarvestTicket()
        .getHarvestTicketListCollection(widget.collectionPoint);
    if (list.isNotEmpty) {
      for (int i = 0; i < list.length; i++) {
        setState(() {
          this.totalWeight = this.totalWeight + list[i].weight;
          this.totalQuantity = this.totalQuantity + list[i].quantity;
        });
      }
      setState(() {
        this.listHarvestTicket = list;
      });
    }
  }

  bool contains(HarvestingTicket object) {
    for (int i = 0; i < listHarvestTicket.length; i++) {
      if (listHarvestTicket[i].idTicket == object.idTicket) {
        return true;
      }
    }
    return false;
  }

  getAgentByID(CollectionPoint collectionPoint) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      agentName = prefs.getString('name');
      userCompany = prefs.getString('userPT');
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
            height: 130,
            child: Column(
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
                          : _generateQRCode();
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

  doneQRDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pastikan Data Sudah Diterima'),
        content: Text('Data tidak bisa akan di transfer lagi'),
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
                  for (int i = 0; i < listHarvestTicket.length; i++) {
                    listHarvestTicket[i].transferred = "true";
                    updateHarvestTicket(listHarvestTicket[i]);
                  }
                  this.collectionPoint.transferred = "true";
                });
                Navigator.pop(context, collectionPoint);
                Navigator.pop(context, collectionPoint);
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

  void doTransferTicket() async {
    if (userTarget != null) {
      loadingDialog(context);
      List<HarvestingTicket> listHarvest = [];
      TransferHarvestingTicketBody transferBody =
          TransferHarvestingTicketBody();
      for (int i = 0; i < listHarvestTicket.length; i++) {
        HarvestingTicket harvestingTicket = HarvestingTicket();
        harvestingTicket = listHarvestTicket[i];
        harvestingTicket.userTargetId = userTarget.id;
        listHarvest.add(harvestingTicket);
      }
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
    setState(() {
      for (int i = 0; i < listHarvestTicket.length; i++) {
        listHarvestTicket[i].transferred = "true";
        updateHarvestTicket(listHarvestTicket[i]);
      }
      this.collectionPoint.transferred = "true";
    });
    Navigator.pop(context, collectionPoint);
    Navigator.pop(context, collectionPoint);
    Toast.show("Berhasil terkirim", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  void updateHarvestTicket(HarvestingTicket object) async {
    DatabaseHarvestTicket dbHarvest = DatabaseHarvestTicket();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('username');
    object.createdBy = user;
    int result = await dbHarvest.updateHarvestTicket(object);
    print(result);
  }

  onErrorTransferCallback(response) {
    Toast.show(response.toString(), context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  doSplitTicketPanen() {
    Navigator.pop(context);
    loadingDialog(context);
    int janjangSplit = int.parse(janjangSplitController.text);
    generateIDCollection().then((value) {
      int totalQuantityTemp = 0;
      double totalWeightTemp = 0;
      CollectionPoint collectionPoint = CollectionPoint();
      collectionPoint.idCollection = value;
      collectionPoint.dateCollection = generateDateTicket();
      collectionPoint.ascendAgentCode = this.collectionPoint.ascendAgentCode;
      collectionPoint.ascendAgentID = this.collectionPoint.ascendAgentID;
      collectionPoint.agentID = this.collectionPoint.agentID;
      collectionPoint.gpsLong = this.collectionPoint.gpsLong;
      collectionPoint.gpsLat = this.collectionPoint.gpsLat;
      collectionPoint.createdBy = this.collectionPoint.createdBy;
      collectionPoint.transferred = "false";
      collectionPoint.uploaded = "false";
      collectionPoint.deliveryCollection = null;
      collectionPoint.note = this.collectionPoint.note;
      for (int i = 0; i < listHarvestTicket.length; i++) {
        HarvestingTicket harvestingTicket = HarvestingTicket();
        Timer(Duration(seconds: 3 + i), () {
          generateIDTicket().then((value) {
            harvestingTicket.idTicket = value;
            harvestingTicket.dateTicket = generateDateTicket();
            harvestingTicket.gpsLat = listHarvestTicket[i].gpsLat;
            harvestingTicket.gpsLong = listHarvestTicket[i].gpsLong;
            harvestingTicket.createdBy = listHarvestTicket[i].createdBy;
            harvestingTicket.ascendFarmerCode =
                listHarvestTicket[i].ascendFarmerCode;
            harvestingTicket.ascendFarmerID =
                listHarvestTicket[i].ascendFarmerID;
            harvestingTicket.uploaded = "false";
            harvestingTicket.transferred = "false";
            harvestingTicket.farmerName = listHarvestTicket[i].farmerName;
            harvestingTicket.mFarmerID = listHarvestTicket[i].mFarmerID;
            harvestingTicket.quantity = (listHarvestTicket[i].quantity -
                    (listHarvestTicket[i].quantity *
                            (janjangSplit / totalQuantity))
                        .round())
                .round();
            harvestingTicket.weight = (listHarvestTicket[i].weight -
                    (listHarvestTicket[i].weight *
                        (janjangSplit / totalQuantity)))
                .round();
            harvestingTicket.idDeliveryOrderTicket = null;
            harvestingTicket.idTicketOriginal = listHarvestTicket[i].idTicket;
            harvestingTicket.idCollectionTicket = collectionPoint.idCollection;
            harvestingTicket.nfcNumber = listHarvestTicket[i].nfcNumber;
            harvestingTicket.note = listHarvestTicket[i].note;
            harvestingTicket.idCollectionTicketOld =
                this.collectionPoint.idCollection;
            addHarvestTicket(harvestingTicket);
            totalWeightTemp = totalWeightTemp + harvestingTicket.weight;
            totalQuantityTemp = totalQuantityTemp + harvestingTicket.quantity;
            if (i == listHarvestTicket.length - 1) {
              collectionPoint.totalWeight = totalWeightTemp;
              collectionPoint.totalQuantity = totalQuantityTemp;
              collectionPoint.idCollectionOriginal =
                  this.collectionPoint.idCollection;
              addCollectionPoint(collectionPoint);
            }
          });
        });
      }
      Timer(Duration(seconds: 4), () {
        CollectionPoint collectionPoint2 = CollectionPoint();
        generateIDCollection().then((value) {
          int totalQuantityTemp2 = 0;
          double totalWeightTemp2 = 0;
          collectionPoint2.idCollection = value;
          collectionPoint2.dateCollection = generateDateTicket();
          collectionPoint2.ascendAgentCode =
              this.collectionPoint.ascendAgentCode;
          collectionPoint2.ascendAgentID = this.collectionPoint.ascendAgentID;
          collectionPoint2.agentID = this.collectionPoint.agentID;
          collectionPoint2.gpsLong = this.collectionPoint.gpsLong;
          collectionPoint2.gpsLat = this.collectionPoint.gpsLat;
          collectionPoint2.createdBy = this.collectionPoint.createdBy;
          collectionPoint2.transferred = "false";
          collectionPoint2.uploaded = "false";
          collectionPoint2.deliveryCollection = null;
          collectionPoint2.note = this.collectionPoint.note;
          for (int i = 0; i < listHarvestTicket.length; i++) {
            HarvestingTicket harvestingTicket2 = HarvestingTicket();
            Timer(Duration(seconds: 5 + i), () {
              generateIDTicket().then((value) {
                harvestingTicket2.idTicket = value;
                harvestingTicket2.dateTicket = generateDateTicket();
                harvestingTicket2.gpsLat = listHarvestTicket[i].gpsLat;
                harvestingTicket2.gpsLong = listHarvestTicket[i].gpsLong;
                harvestingTicket2.createdBy = listHarvestTicket[i].createdBy;
                harvestingTicket2.ascendFarmerCode =
                    listHarvestTicket[i].ascendFarmerCode;
                harvestingTicket2.uploaded = "false";
                harvestingTicket2.transferred = "false";
                harvestingTicket2.ascendFarmerID =
                    listHarvestTicket[i].ascendFarmerID;
                harvestingTicket2.idTicketOriginal =
                    listHarvestTicket[i].idTicket;
                harvestingTicket2.farmerName = listHarvestTicket[i].farmerName;
                harvestingTicket2.mFarmerID = listHarvestTicket[i].mFarmerID;
                harvestingTicket2.quantity = (listHarvestTicket[i].quantity *
                        (janjangSplit / totalQuantity))
                    .round();
                harvestingTicket2.weight = (listHarvestTicket[i].weight -
                        (listHarvestTicket[i].weight -
                            (listHarvestTicket[i].weight *
                                ((janjangSplit / totalQuantity)))))
                    .round();
                harvestingTicket2.idCollectionTicket =
                    collectionPoint2.idCollection;
                harvestingTicket2.idDeliveryOrderTicket = null;
                harvestingTicket2.idCollectionTicketOld =
                    this.collectionPoint.idCollection;
                harvestingTicket2.nfcNumber = listHarvestTicket[i].nfcNumber;
                harvestingTicket2.note = listHarvestTicket[i].note;
                addHarvestTicket(harvestingTicket2);
                totalWeightTemp2 = totalWeightTemp2 + harvestingTicket2.weight;
                totalQuantityTemp2 =
                    totalQuantityTemp2 + harvestingTicket2.quantity;
                if (i == listHarvestTicket.length - 1) {
                  collectionPoint2.totalWeight = totalWeightTemp2;
                  collectionPoint2.totalQuantity = totalQuantityTemp2;
                  collectionPoint2.idCollectionOriginal =
                      this.collectionPoint.idCollection;
                  addCollectionPoint(collectionPoint2);
                  Navigator.pop(context);
                }
              });
            });
          }
          this.collectionPoint.transferred = "true";
          DatabaseHarvestTicket().updateHarvestTicketCollectionPointSplit(
              this.collectionPoint.idCollection);
          editCollectionPoint(this.collectionPoint);
        });
      });
    });
  }

  void addHarvestTicket(HarvestingTicket object) async {
    DatabaseHarvestTicket dbHarvest = DatabaseHarvestTicket();
    int result = await dbHarvest.insertHarvestTicket(object);
    print(result);
  }

  void addCollectionPoint(CollectionPoint object) async {
    int result = await dbCollection.insertCollectionPoint(object);
    print(result);
  }

  Future<String> generateIDTicket() async {
    String idTicket;
    NumberFormat formatter = new NumberFormat("0000");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String number =
        formatter.format(int.parse(prefs.getString('userSequence')));
    idTicket = "T" + TimeUtils.getIDOnTime(DateTime.now()) + number;
    return idTicket;
  }

  Future<String> generateIDCollection() async {
    String idCollection;
    DateTime now = DateTime.now();
    NumberFormat formatter = new NumberFormat("0000");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String number =
        formatter.format(int.parse(prefs.getString('userSequence')));
    idCollection = "C" + TimeUtils.getIDOnTime(now) + number;
    return idCollection;
  }

  String generateDateTicket() {
    DateTime now = DateTime.now();
    String dateTicket = TimeUtils.getTime(now).toString();
    return dateTicket;
  }
}
