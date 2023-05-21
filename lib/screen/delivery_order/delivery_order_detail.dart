import 'dart:async';

import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/base/ui/palette.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/database_local/database_collection_point.dart';
import 'package:e_trace_app/database_local/database_delivery_order.dart';
import 'package:e_trace_app/database_local/database_harvest_ticket.dart';
import 'package:e_trace_app/database_local/database_helper.dart';
import 'package:e_trace_app/database_local/database_supplier.dart';
import 'package:e_trace_app/model/delivery_order.dart';
import 'package:e_trace_app/model/farmers.dart';
import 'package:e_trace_app/model/harvesting_ticket.dart';
import 'package:e_trace_app/model/suppliers.dart';
import 'package:e_trace_app/screen/delivery_order/qr_screen_delivery.dart';
import 'package:e_trace_app/utils/separator_thousand.dart';
import 'package:e_trace_app/widget/qr_code_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lzstring/lzstring.dart';
// import 'package:screen/screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'delivery_order_form.dart';

class DeliveryOrderDetail extends StatefulWidget {
  final DeliveryOrder? deliveryOrder;

  DeliveryOrderDetail({this.deliveryOrder});

  @override
  DeliveryOrderDetailState createState() => DeliveryOrderDetailState();
}

class DeliveryOrderDetailState extends State<DeliveryOrderDetail> {
  DatabaseHelper dbHelper = DatabaseHelper();
  DatabaseDeliveryOrder dbDelivery = DatabaseDeliveryOrder();

  List<HarvestingTicket> listHarvestTicket = [];
  TextEditingController userTargetController = TextEditingController();
  String? menuTransfer;

  // List<RecordEditor> _records = [];
  // bool _hasClosedWriteDialog = false;

  DeliveryOrder? deliveryOrder;
  Suppliers? suppliersObject;
  int totalQuantity = 0;
  double? totalWeight = 0.0, brightnessInit;
  List<Farmers> listFarmer = [];
  Position? position;
  String? message;
  String? compressed;
  String? company;
  String? username;

  final controller = PageController();

  @override
  void initState() {
    deliveryOrder = widget.deliveryOrder;
    getCompany();
    getHarvestTicketDeliveryOrderList();
    getSupplierByID(widget.deliveryOrder!);
    super.initState();
  }

  Future<String?> compress(String uncompressed) async {
    final result = await LZString.compressToBase64(uncompressed);
    print(result);
    DeliveryOrder deliveryOrderTemp = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => QRScreenDelivery(
                message: uncompressed,
                deliveryOrder: this.deliveryOrder!,
                listHarvestingTicket: listHarvestTicket)));
    setState(() {
      this.deliveryOrder = deliveryOrderTemp;
    });
    return result;
  }

  getCompany() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString('userPT');
    String? username = prefs.getString('username');
    // double? brightness = await Screen.brightness;
    setState(() {
      // this.brightnessInit = brightness;
      this.company = user;
      this.username = username;
    });
  }

  getHarvestTicketDeliveryOrderList() async {
    setState(() {
      this.totalWeight = 0;
      this.totalQuantity = 0;
    });
    List<HarvestingTicket> list = await DatabaseHarvestTicket()
        .getHarvestTicketListDelivery(widget.deliveryOrder!);
    if (list.isNotEmpty) {
      for (int i = 0; i < list.length; i++) {
        setState(() {
          this.totalWeight = (totalWeight! + list[i].weight).roundToDouble();
          this.totalQuantity = totalQuantity + list[i].quantity!;
        });
      }
      setState(() {
        this.listHarvestTicket = list;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, deliveryOrder);
        return true;
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            leading: InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: InkWell(
                    onTap: () {
                      Navigator.pop(context, deliveryOrder);
                    },
                    child: Icon(Icons.arrow_back)),
              ),
            ),
            title: Text("Detail Surat Pengantar TBS"),
            actions: [
              InkWell(
                onTap: () {},
                child: (deliveryOrder!.transferred == "true")
                    ? Container(width: 10)
                    : Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: InkWell(
                            onTap: () async {
                              var contact = await navigateToEntryForm(
                                  context, widget.deliveryOrder!);
                              editDeliveryOrder(contact);
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
                            color: Colors.blue,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Icon(
                                          Linecons.truck,
                                          size: 40,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      Container(
                                          child: Text(
                                        DELIVERY_ORDER,
                                        style: text18Bold,
                                      )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(ID_DELIVERY_ORDER_FORM, style: text16Bold),
                                Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                      "${widget.deliveryOrder!.idDelivery}",
                                      style: text16Bold),
                                )
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DATE_FORM, style: text14Bold),
                              Text("${widget.deliveryOrder!.dateDelivery}")
                            ],
                          ),
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Pabrik", style: text14Bold),
                            Text("$company")
                          ],
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(GPS_LOCATION_FORM, style: text14Bold),
                              Text(
                                  "${widget.deliveryOrder!.gpsLat ?? ""}, ${widget.deliveryOrder!.gpsLong ?? ""}",
                                  overflow: TextOverflow.ellipsis)
                            ],
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(SUPPLIER, style: text14Bold),
                              suppliersObject != null
                                  ? Text("${suppliersObject!.name}")
                                  : Container()
                            ],
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DRIVER, style: text14Bold),
                              Text("${widget.deliveryOrder!.driverName}")
                            ],
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(PLAT_NUMBER, style: text14Bold),
                              Text("${widget.deliveryOrder!.platNumber}")
                            ],
                          ),
                        ),
                        // Divider(),
                        // Padding(
                        //   padding: const EdgeInsets.only(top: 8.0),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     children: [
                        //       Text(CARD_NUMBER, style: text14Bold),
                        //       Text("${widget.deliveryOrder.cardNumber}")
                        //     ],
                        //   ),
                        // ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total Jumlah Janjang", style: text14Bold),
                              Text("$totalQuantity")
                            ],
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total Berat Janjang", style: text14Bold),
                              Text(
                                  "${formatThousandSeparator(totalWeight!.round())}")
                            ],
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Catatan", style: text14Bold),
                              Text("${widget.deliveryOrder!.note}")
                            ],
                          ),
                        ),
                        Divider(),
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
                margin: EdgeInsets.only(top: 4),
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(18),
                      child: Column(
                        children: [
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
                                  "${formatThousandSeparator(totalWeight!.round())}")
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
                                    leading: Icon(
                                      Linecons.note,
                                      size: 30,
                                      color: Colors.orange,
                                    ),
                                    title: Text(
                                        "${listHarvestTicket[index].idTicket}"),
                                    subtitle: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                "Kode Areal: ${listHarvestTicket[index].ascendFarmerCode}"),
                                            Text(
                                                "Tanggal: ${listHarvestTicket[index].dateTicket}"),
                                            Text(
                                                "Janjang/Berat(Kg): ${listHarvestTicket[index].quantity}/${formatThousandSeparator(listHarvestTicket[index].weight.round())}"),
                                            Text(
                                                "TK: ${listHarvestTicket[index].idCollectionTicket ?? "-"}"),
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
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          deliveryOrder!.transferred == "true"
                              ? Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    "Data sudah generate Kode QR",
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : Container(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  menuTransfer = "QRCode";
                                });
                                _generateQRCode();
                              },
                              child: Container(
                                height: 100,
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.qr_code_rounded,
                                        size: 30, color: Colors.white),
                                    Text(
                                      " Kode QR",
                                      style: buttonStyle22,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: OutlinedButton(
                      //     onPressed: () {
                      //       setState(() {
                      //         menuTransfer = "NFC";
                      //       });
                      //       doSetNFC();
                      //     },
                      //     child: Container(
                      //       height: 100,
                      //       width: MediaQuery.of(context).size.width,
                      //       padding: EdgeInsets.symmetric(vertical: 15),
                      //       child: Row(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         children: [
                      //           Icon(
                      //             Icons.nfc_rounded,
                      //             size: 30,
                      //             color: Colors.white,
                      //           ),
                      //           Text(
                      //             " NFC",
                      //             style: buttonStyle22,
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<DeliveryOrder> navigateToEntryForm(
      BuildContext context, DeliveryOrder deliveryOrder) async {
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return DeliveryOrderForm(deliveryOrder: deliveryOrder);
    }));
    return result;
  }

  void editDeliveryOrder(DeliveryOrder object) async {
    getSupplierByID(object);
    int result = await dbDelivery.updateDeliveryOrder(object);
    if (result > 0) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = dbHelper.initDb();
    dbFuture.then((database) {
      Future<List<DeliveryOrder>> collectionPointListFuture =
          dbDelivery.getDeliveryOrderList();
      collectionPointListFuture.then((collectionPointList) {
        setState(() {
          getHarvestTicketDeliveryOrderList();
        });
      });
    });
  }

  void getSupplierByID(DeliveryOrder deliveryOrder) async {
    Suppliers suppliers =
        await DatabaseSupplier().selectSupplierByID(deliveryOrder);
    setState(() {
      this.suppliersObject = suppliers;
    });
  }

  _generateQRCode() {
    List<String> dataCollection = [];
    String dataDeliveryOrder;
    dataDeliveryOrder = widget.deliveryOrder!.idDelivery! +
        "," +
        widget.deliveryOrder!.ascentSupplierCode! +
        "," +
        widget.deliveryOrder!.driverName! +
        "," +
        widget.deliveryOrder!.platNumber!;

    for (int i = 0; i < listHarvestTicket.length; i++) {
      String dataTicket = listHarvestTicket[i].ascendFarmerCode! +
          "," +
          listHarvestTicket[i].quantity.toString() +
          "," +
          listHarvestTicket[i].weight.toString();
      dataCollection.add(dataTicket);
    }
    String message = dataCollection.join("#");
    String dataTimbangan = dataDeliveryOrder + "[" + message + "]";
    print("this is data delivery : $dataTimbangan");
    compress(dataTimbangan);
  }

  // doSetNFC() {
  //   List<String> dataCollection = [];
  //   String dataDeliveryOrder;
  //   dataDeliveryOrder = widget.deliveryOrder.idDelivery +
  //       "," +
  //       widget.deliveryOrder.ascentSupplierCode +
  //       "," +
  //       widget.deliveryOrder.driverName +
  //       "," +
  //       widget.deliveryOrder.platNumber;
  //
  //   for (int i = 0; i < listHarvestTicket.length; i++) {
  //     String dataTicket = listHarvestTicket[i].ascendFarmerCode +
  //         "," +
  //         listHarvestTicket[i].quantity.toString() +
  //         "," +
  //         listHarvestTicket[i].weight.toString();
  //     dataCollection.add(dataTicket);
  //   }
  //   String message = dataCollection.join("#");
  //   String dataTimbangan = dataDeliveryOrder + "[" + message + "]";
  //   print("this is data delivery : $dataTimbangan");
  //   String encrypted = EncryptData().encryptData(dataTimbangan);
  //   print("this is data delivery: $dataTimbangan");
  //   print("this is encrypted: $encrypted");
  //   setState(() {
  //     _records.add(RecordEditor("Plain/Text", encrypted));
  //   });
  //   _write(context, encrypted);
  // }
  //
  // void _write(BuildContext context, String messageList) async {
  //   List<NDEFRecord> records = _records.map((record) {
  //     return NDEFRecord.type("PlainText", messageList);
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
  //                   child: Text("Untuk memasukkan data",
  //                       style: TextStyle(color: Colors.black)),
  //                 ),
  //                 OutlinedButton(
  //                   onPressed: () {
  //                     _hasClosedWriteDialog = true;
  //                     Navigator.pop(context);
  //                   },
  //                   child: Container(
  //                     width: MediaQuery.of(context).size.width,
  //                     padding: EdgeInsets.all(10),
  //                     child: Center(
  //                         child: Text(
  //                       CANCEL,
  //                       style: buttonStyle16,
  //                     )),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     );
  //   }
  //
  //   // Write to the first tag scanned
  //   NDEFTag result = await NFC.writeNDEF(message).first;
  //   if (result != null) {
  //     if (!_hasClosedWriteDialog) {
  //       Toast.show("Data Sudah Tersimpan", context,
  //           duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  //       setState(() {
  //         this.deliveryOrder.transferred = "true";
  //         DatabaseHarvestTicket().updateHarvestTicketDeliveryTransfer(
  //             this.deliveryOrder.idDelivery);
  //         DatabaseHarvestTicket().updateHarvestTicketDeliveryTransfer(
  //             this.deliveryOrder.idDelivery);
  //       });
  //       Navigator.pop(context, deliveryOrder);
  //     }
  //   } else {
  //     Toast.show("Gagal Tersimpan", context,
  //         duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  //   }
  // }

  showQRCodeDialog(BuildContext context, String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Colors.white,
            title: Center(
                child: Text("Kode QR SP TBS",
                    style: TextStyle(color: Colors.black))),
            content: Container(
              height: 350,
              child: Column(
                children: [
                  Text(
                    "${deliveryOrder!.idDelivery}",
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(
                    "$username",
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(
                    "Supplier: ${suppliersObject!.name}",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black),
                  ),
                  Divider(),
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
                                setState(() {
                                  // Screen.setBrightness(brightnessInit);
                                });
                              },
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Text("  Batal ", style: buttonStyle16),
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
                                  // Screen.setBrightness(brightnessInit);
                                });
                              },
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Text("Selesai", style: buttonStyle16),
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
                  this.deliveryOrder!.transferred = "true";
                  DatabaseHarvestTicket().updateHarvestTicketDeliveryTransfer(
                      this.deliveryOrder!.idDelivery!);
                  DatabaseCollectionPoint()
                      .updateCollectionPointDeliveryTransfer(
                          this.deliveryOrder!.idDelivery!);
                });
                Navigator.pop(context, deliveryOrder);
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

  void updateHarvestTicket(HarvestingTicket object) async {
    DatabaseHarvestTicket dbHarvest = DatabaseHarvestTicket();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString('username');
    object.createdBy = user;
    int result = await dbHarvest.updateHarvestTicket(object);
    print(result);
  }
}
