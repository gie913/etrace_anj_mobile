import 'dart:async';
import 'dart:math';

import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/database_local/database_agent.dart';
import 'package:e_trace_app/database_local/database_harvest_ticket.dart';
import 'package:e_trace_app/model/agents.dart';
import 'package:e_trace_app/model/collection_point.dart';
import 'package:e_trace_app/model/farmers.dart';
import 'package:e_trace_app/database_local/database_farmer.dart';
import 'package:e_trace_app/model/harvesting_ticket.dart';
import 'package:e_trace_app/model/transfer_response.dart';
import 'package:e_trace_app/screen/collection_point/search_harvest_ticket_collection.dart';
import 'package:e_trace_app/screen/harvest_ticket/save_repository.dart';
import 'package:e_trace_app/screen/harvest_ticket/ticket_received_screen.dart';
import 'package:e_trace_app/screen/harvest_ticket/transfer_harvest_ticket.dart';
import 'package:e_trace_app/screen/home/counter_notifier.dart';
import 'package:e_trace_app/utils/separator_thousand.dart';
import 'package:e_trace_app/utils/storage_manager.dart';
import 'package:e_trace_app/utils/time_utils.dart';
import 'package:e_trace_app/widget/back_from_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class CollectionPointForm extends StatefulWidget {
  final CollectionPoint? collectionPoint;

  CollectionPointForm({this.collectionPoint});

  @override
  CollectionPointFormState createState() => CollectionPointFormState();
}

class CollectionPointFormState extends State<CollectionPointForm>
    with SingleTickerProviderStateMixin {
  final controller = PageController();
  String? record = "", receivedVia;
  bool? loading;

  /*Collection Point Detail*/
  CollectionPoint? collectionPoint;
  Position? position;
  Agents? agentsObject;
  TextEditingController agenNameController = TextEditingController();
  TextEditingController cardNumberController = TextEditingController();
  var noteController = TextEditingController();

  String? idCollection, dateCollection, gpsLat, gpsLong, username, name, idUser;

  /*Harvest Ticket List*/
  List<HarvestingTicket> harvestTicketList = [];
  HarvestingTicket? harvestTicket;
  int totalJanjang = 0;
  double totalWeight = 0;
  DateTime now = DateTime.now();
  TabController? tabBarController;

  @override
  void initState() {
    collectionPoint = widget.collectionPoint;
    generateIDCollection();
    generateDateCollection();
    tabBarController = TabController(length: 2, vsync: this);
    agenNameController.text = collectionPoint!.agentID!;
    cardNumberController.text = collectionPoint!.cardNumber!;
    noteController.text = collectionPoint!.note!;
    getAgentByID(collectionPoint!);
    getHarvestTicketCollectionList();
    getLocation();
    super.initState();
  }

  generateDateCollection() {
    setState(() {
      if (collectionPoint != null) {
        dateCollection = collectionPoint!.dateCollection;
      } else {
        dateCollection = TimeUtils.getTime(now).toString();
      }
    });
  }

  getHarvestTicketCollectionList() async {
    List<HarvestingTicket> list = await DatabaseHarvestTicket()
        .getHarvestTicketListCollection(widget.collectionPoint!);
    if (list.isNotEmpty) {
      for (int i = 0; i < list.length; i++) {
        this.totalWeight = roundDouble(totalWeight + list[i].weight, 2);
        this.totalJanjang = totalJanjang + list[i].quantity!;
      }
    }
    setState(() {
      this.harvestTicketList = list;
    });
  }

  getAgentByID(CollectionPoint collectionPoint) async {
    Agents agents = await DatabaseAgent().getAgentByID(collectionPoint);
    setState(() {
      this.agentsObject = agents;
    });
  }

  generateIDCollection() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    name = prefs.getString("name");
    idUser = prefs.getString("idUser");
    if (collectionPoint != null) {
      idCollection = collectionPoint!.idCollection!;
    } else {
      NumberFormat formatter = new NumberFormat("0000");
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String number =
          formatter.format(int.parse(prefs.getString('userSequence')!));
      setState(() {
        this.idCollection = "C" + TimeUtils.getIDOnTime(now) + number;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => await onWillPopForm(context),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              title: Text(COLLECTION_POINT_TITLE),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight),
                child: TabBar(
                  controller: tabBarController,
                  tabs: [
                    Tab(text: "Titik Kumpul TBS"),
                    Tab(text: "List Tiket Panen")
                  ],
                ),
              ),
            ),
            body: TabBarView(
              controller: tabBarController,
              children: [
                SingleChildScrollView(
                  child: Card(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20.0),
                        ),
                      ),
                      height: MediaQuery.of(context).size.height * 0.87,
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
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
                          Container(
                              margin: EdgeInsets.only(bottom: 20),
                              alignment: Alignment.center,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Icon(
                                      Linecons.inbox,
                                      size: 40,
                                      color: Colors.green,
                                    ),
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
                              Text(ID_COLLECTION_POINT_FORM, style: text18Bold),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 6.0, bottom: 10.0),
                                child: Text("$idCollection", style: text16Bold),
                              )
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DATE_FORM, style: text14Bold),
                              Text("$dateCollection")
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(GPS_LOCATION_FORM, style: text14Bold),
                              loading!
                                  ? SizedBox(
                                      height: 10.0,
                                      width: 10.0,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.0,
                                      ),
                                    )
                                  : Container(
                                      padding: EdgeInsets.only(left: 20),
                                      child: Text(
                                        "$gpsLat,$gpsLong",
                                        overflow: TextOverflow.ellipsis,
                                      ))
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Agen", style: text14Bold),
                              Text("$name")
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total Jumlah Janjang", style: text14Bold),
                              Text("$totalJanjang")
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total Berat Janjang (Kg)",
                                  style: text14Bold),
                              Text(
                                  "${formatThousandSeparator(totalWeight.round())}")
                            ],
                          ),
                          // Divider(),
                          // Padding(
                          //   padding: const EdgeInsets.only(top: 0),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       Text(CARD_NUMBER, style: text14Bold),
                          //       Flexible(
                          //         child: Container(
                          //           width: 160,
                          //           height: 50,
                          //           child: TextField(
                          //               inputFormatters: [
                          //                 FilteringTextInputFormatter.deny(
                          //                     RegExp('[ ]')),
                          //               ],
                          //               controller: cardNumberController,
                          //               textAlign: TextAlign.center,
                          //               keyboardType: TextInputType.text,
                          //               decoration: InputDecoration(
                          //                 border: OutlineInputBorder(
                          //                   borderRadius: BorderRadius.all(
                          //                       Radius.circular(10)),
                          //                   borderSide: BorderSide(width: 1),
                          //                 ),
                          //               )),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.only(top: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Catatan", style: text14Bold),
                                Flexible(
                                  child: Container(
                                    width: 160,
                                    child: TextField(
                                        controller: noteController,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.text,
                                        maxLines: 3,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                            borderSide: BorderSide(width: 1),
                                          ),
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                          _inputHarvestTicketButton(),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: _saveButton(),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Card(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    margin: EdgeInsets.only(top: 4),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(18),
                          child: Column(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total Jumlah Janjang", style: text14Bold),
                                Text("$totalJanjang")
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total Berat Janjang (Kg)",
                                    style: text14Bold),
                                Text(
                                    "${formatThousandSeparator(totalWeight.round())}")
                              ],
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: OutlinedButton(
                                      onPressed: () {
                                        showTransferDialog(context);
                                      },
                                      child: Container(
                                        child: Text(
                                          "Tambahkan Tiket Panen",
                                          style: buttonStyle16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ])
                          ]),
                        ),
                        Flexible(child: containerList()),
                      ],
                    ),
                  ),
                )
              ],
            )),
      ),
    );
  }

  Widget containerList() {
    return Container(
      color: Colors.black12,
      child: harvestTicketList.length != 0
          ? ListView.builder(
              itemCount: harvestTicketList.length,
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
                          trailing: GestureDetector(
                            onTap: () {
                              showDeleteDialog(context, index);
                            },
                            child: Icon(Linecons.trash),
                          ),
                          title: Text(harvestTicketList[index].idTicket!),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Tanggal: " +
                                      harvestTicketList[index].dateTicket!),
                                  Text("Jumlah/Berat (Kg): " +
                                      harvestTicketList[index]
                                          .quantity
                                          .toString() +
                                      "/${formatThousandSeparator(harvestTicketList[index].weight.round())}"),
                                ],
                              ),
                              Text("Kode Areal: " +
                                  "${harvestTicketList[index].ascendFarmerCode}"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Linecons.note, size: 40, color: Colors.orange),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text("Belum ada tiket panen", style: text14),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _inputHarvestTicketButton() {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          tabBarController!.animateTo(1);
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        child: Text("Isi Tiket Panen", style: buttonStyle18),
      ),
    );
  }

  Future _scan() async {
    await Permission.camera.request();
    String? barcode = await scanner.scan();
    if (barcode == null) {
      print('nothing return.');
    } else {
      splitQRCodeHarvestTicket(barcode);
    }
  }

  // void _startScanning() async {
  //   showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         title: Center(
  //             child: Text("Tempel Kartu NFC",
  //                 style: TextStyle(color: Colors.black))),
  //         content: Container(
  //           height: 200,
  //           child: Column(
  //             children: [
  //               Center(
  //                 child: Container(
  //                   margin: EdgeInsets.only(bottom: 10),
  //                   width: 100,
  //                   child: Image.asset("assets/tap-nfc.jpg"),
  //                 ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: Text("Untuk memasukkan data",
  //                     style: TextStyle(color: Colors.black)),
  //               ),
  //               OutlinedButton(
  //                 onPressed: () {
  //                   _stopScanning();
  //                   Navigator.pop(context);
  //                 },
  //                 child: Container(
  //                   width: MediaQuery.of(context).size.width,
  //                   padding: EdgeInsets.all(10),
  //                   child: Center(
  //                       child: Text(
  //                     CANCEL,
  //                     style: buttonStyle16,
  //                   )),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  //   setState(() {
  //     _stream = NFC
  //         .readNDEF(alertMessage: "Custom message with readNDEF#alertMessage")
  //         .listen((NDEFMessage message) {
  //       if (message.isEmpty) {
  //         Toast.show("Tiket Sudah Ada", context,
  //             duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  //         return;
  //       }
  //       for (NDEFRecord record in message.records) {
  //         setState(() {
  //           String decrypted = EncryptData().decryptData(record.payload);
  //           this.record = decrypted;
  //           splitQRCodeHarvestTicket(decrypted);
  //           _stopScanning();
  //           Navigator.pop(context);
  //         });
  //       }
  //     }, onError: (error) {
  //       setState(() {
  //         _stream = null;
  //       });
  //       if (error is NFCUserCanceledSessionException) {
  //         print("user canceled");
  //       } else if (error is NFCSessionTimeoutException) {
  //         print("session timed out");
  //       } else {
  //         print("error: $error");
  //       }
  //     }, onDone: () {
  //       setState(() {
  //         _stream = null;
  //       });
  //     });
  //   });
  // }
  //
  // void _stopScanning() {
  //   _stream?.cancel();
  //   setState(() {
  //     _stream = null;
  //   });
  // }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _stream?.cancel();
  // }

  // void _toggleScan() {
  //   if (_stream == null) {
  //     _startScanning();
  //   } else {
  //     _stopScanning();
  //   }
  // }

  splitQRCodeHarvestTicket(String harvestTicket) async {
    final splitCollection = harvestTicket.split("#");
    for (int i = 0; i < splitCollection.length; i++) {
      print(splitCollection[i]);
      final splitTicket = splitCollection[i].split(",");
      print(splitTicket.length);
      if (splitTicket.length == 5) {
        final Map<int, String> values = {
          for (int i = 0; i < splitTicket.length; i++) i: splitTicket[i]
        };
        final value1 = values[0];
        final value2 = values[1];
        final value3 = values[2];
        final value4 = values[3];
        final value5 = values[4];
        print(value5);
        setState(() {
          HarvestingTicket harvestTicket = HarvestingTicket();
          harvestTicket.idTicket = value1;
          harvestTicket.ascendFarmerCode = value2;
          harvestTicket.quantity = int.parse(value3!);
          harvestTicket.weight = double.parse(value4!);
          if (value5 == username) {
            if (contains(harvestTicket) == true) {
              Toast.show("Ticket Sudah Ada", duration: 1, gravity: 0);
            } else {
              checkExistTicket(harvestTicket);
            }
          } else {
            Toast.show("Anda bukan tujuan kepemilikan data ini",
                duration: 1, gravity: 0);
          }
        });
      } else if (splitTicket.length == 4) {
        final Map<int, String> values = {
          for (int i = 0; i < splitTicket.length; i++) i: splitTicket[i]
        };
        final value1 = values[0];
        final value2 = values[1];
        final value3 = values[2];
        final value4 = values[3];
        setState(() {
          HarvestingTicket harvestTicket = HarvestingTicket();
          harvestTicket.idTicket = value1;
          harvestTicket.ascendFarmerCode = value2;
          harvestTicket.quantity = int.parse(value3!);
          harvestTicket.weight = double.parse(value4!);
          if (contains(harvestTicket) == true) {
            Toast.show("Ticket Sudah Ada", duration: 1, gravity: 0);
          } else {
            checkExistTicket(harvestTicket);
          }
        });
      } else if (splitTicket.length == 6) {
        final Map<int, String> values = {
          for (int i = 0; i < splitTicket.length; i++) i: splitTicket[i]
        };
        final value1 = values[0];
        final value2 = values[1];
        final value3 = values[2];
        final value4 = values[3];
        final value5 = values[4];
        final value6 = values[5];
        setState(() {
          HarvestingTicket harvestTicket = HarvestingTicket();
          harvestTicket.idTicket = value1;
          harvestTicket.ascendFarmerCode = value2;
          harvestTicket.quantity = int.parse(value3!);
          harvestTicket.weight = double.parse(value4!);
          harvestTicket.idCollectionTicket = value5;
          if (value6 == username) {
            if (contains(harvestTicket) == true) {
              Toast.show("Ticket Sudah Ada", duration: 1, gravity: 0);
            } else {
              checkExistTicket(harvestTicket);
            }
          } else {
            Toast.show("Anda bukan tujuan kepemilikan data ini",
                duration: 1, gravity: 0);
          }
        });
      } else if (splitTicket.length == 8) {
        Toast.show("Kartu Berisi Delivery Order", duration: 1, gravity: 0);
      }
    }
  }

  double roundDouble(double value, int places) {
    double? mod = pow(10.0, places) as double?;
    return ((value * mod!).round().toDouble() / mod);
  }

  bool contains(HarvestingTicket object) {
    for (int i = 0; i < this.harvestTicketList.length; i++) {
      if (this.harvestTicketList[i].idTicket == object.idTicket) {
        return true;
      }
    }
    return false;
  }

  void removeList(int index) {
    if (collectionPoint == null) {
      int totalJanjangTemp = totalJanjang - harvestTicketList[index].quantity!;
      double totalWeightTemp = totalWeight - harvestTicketList[index].weight;
      harvestTicketList.remove(harvestTicketList[index]);
      setState(() {
        this.totalJanjang = totalJanjangTemp;
        this.totalWeight = roundDouble(totalWeightTemp, 2);
        this.harvestTicketList = harvestTicketList;
      });
    } else {
      int totalJanjangTemp = totalJanjang - harvestTicketList[index].quantity!;
      double totalWeightTemp = totalWeight - harvestTicketList[index].weight;
      harvestTicketList.remove(harvestTicketList[index]);
      setState(() {
        this.totalJanjang = totalJanjangTemp;
        this.totalWeight = roundDouble(totalWeightTemp, 2);
        this.harvestTicketList = harvestTicketList;
      });
      DatabaseHarvestTicket()
          .updateHarvestTicketCollection(this.collectionPoint!.idCollection!);
    }
  }

  getLocation() async {
    loading = true;
    if (collectionPoint != null) {
      gpsLat = collectionPoint!.gpsLat;
      gpsLong = collectionPoint!.gpsLong;
      loading = false;
    } else {
      try {
        position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high)
            .timeout(const Duration(seconds: 10));
        setState(() {
          gpsLat = position!.latitude.toString();
          gpsLong = position!.longitude.toString();
        });
      } on TimeoutException catch (_) {
        setState(() {
          gpsLat = null;
          gpsLong = null;
        });
      }
      loading = false;
    }
  }

  showDeleteDialog(BuildContext context, int index) {
    Widget cancelButton = TextButton(
      child: Text(NO, style: TextStyle(color: Colors.blue)),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text(YES, style: TextStyle(color: Colors.red)),
      onPressed: () {
        removeList(index);
        Navigator.pop(context);
      },
    );
    AlertDialog alert = AlertDialog(
      content: Text(
        "Anda ingin menghapus data?",
        style: text14,
      ),
      actions: [
        continueButton,
        cancelButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  addDataToDatabase(BuildContext context) async {
    context.read<CounterNotifier>().getCountUnUploadedCollectionPoint();
    for (int i = 0; i < harvestTicketList.length; i++) {
      String year =
          "20" + harvestTicketList[i].idTicket!.substring(1, 3).toString();
      String month = harvestTicketList[i].idTicket!.substring(3, 5);
      String day = harvestTicketList[i].idTicket!.substring(5, 7);
      String hour = harvestTicketList[i].idTicket!.substring(7, 9);
      String minute = harvestTicketList[i].idTicket!.substring(9, 11);
      harvestTicketList[i].dateTicket =
          year + "-" + month + "-" + day + " " + hour + ":" + minute;
      if (harvestTicketList[i].idCollectionTicket == null) {
        harvestTicketList[i].idCollectionTicket = idCollection;
        harvestTicketList[i].idDeliveryOrderTicket = null;
      } else if (collectionPoint != null) {
        harvestTicketList[i].idCollectionTicketOld =
            harvestTicketList[i].idCollectionTicket;
        harvestTicketList[i].idCollectionTicket = idCollection;
        harvestTicketList[i].idDeliveryOrderTicket = null;
      } else {
        harvestTicketList[i].idCollectionTicket = idCollection;
        harvestTicketList[i].idDeliveryOrderTicket = null;
      }
      harvestTicketList[i].uploaded = "false";
      harvestTicketList[i].transferred = "false";
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? user = prefs.getString('username');
      if (harvestTicketList[i].createdBy == user) {
        updateHarvestTicket(harvestTicketList[i]);
      } else if (harvestTicketList[i].mFarmerID == null &&
          harvestTicketList[i].createdBy == "other") {
        updateHarvestTicket(harvestTicketList[i]);
      } else if (harvestTicketList[i].createdBy == null) {
        addHarvestTicket(harvestTicketList[i]);
      }
    }
    if (collectionPoint == null) {
      collectionPoint = CollectionPoint(
          idCollection: idCollection,
          dateCollection: dateCollection,
          gpsLong: gpsLong ?? null,
          gpsLat: gpsLat ?? null,
          deliveryCollection: null,
          uploaded: "false",
          createdBy: username,
          transferred: "false",
          totalQuantity: totalJanjang,
          totalWeight: totalWeight,
          agentID: idUser,
          ascendAgentCode: username,
          note: noteController.text,
          cardNumber: cardNumberController.text);
    } else {
      collectionPoint!.idCollection = idCollection;
      collectionPoint!.dateCollection = dateCollection;
      collectionPoint!.gpsLong = gpsLong;
      collectionPoint!.gpsLat = gpsLat;
      collectionPoint!.agentID = idUser;
      collectionPoint!.uploaded = "false";
      collectionPoint!.createdBy = collectionPoint!.createdBy;
      collectionPoint!.totalQuantity = totalJanjang;
      collectionPoint!.totalWeight = totalWeight;
      collectionPoint!.ascendAgentCode = username;
      collectionPoint!.cardNumber = cardNumberController.text;
      collectionPoint!.note = noteController.text;
    }
    doSaveTransferTicket();
    Navigator.pop(context, collectionPoint);
  }

  void addHarvestTicket(HarvestingTicket object) async {
    DatabaseHarvestTicket dbHarvest = DatabaseHarvestTicket();
    object.createdBy = "other";
    int result = await dbHarvest.insertHarvestTicketFromOther(object);
    print(result);
  }

  void updateHarvestTicket(HarvestingTicket object) async {
    DatabaseHarvestTicket dbHarvest = DatabaseHarvestTicket();
    int result = await dbHarvest.updateHarvestTicket(object);
    print(result);
  }

  showTransferDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
        title: Center(child: Text("Pilih Tiket Melalui")),
        content: Container(
          height: 230,
          child: Column(
            children: [
              Container(
                height: 60,
                margin: EdgeInsets.only(bottom: 10),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      receivedVia = "qr";
                    });
                    _scan();
                  },
                  child: Row(
                    children: [
                      Text(
                        "Kode QR",
                        style: buttonStyle16,
                      ),
                    ],
                  ),
                ),
              ),
              // Container(
              //   height: 60,
              //   margin: EdgeInsets.only(bottom: 10),
              //   child: OutlinedButton(
              //     onPressed: () {
              //       Navigator.pop(context);
              //       setState(() {
              //         receivedVia = "nfc";
              //       });
              //       _toggleScan();
              //     },
              //     child: Row(
              //       children: [
              //         Text("NFC", style: buttonStyle16),
              //       ],
              //     ),
              //   ),
              // ),
              Container(
                height: 60,
                margin: EdgeInsets.only(bottom: 10),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      receivedVia = null;
                    });
                    navigateToSearchTicket();
                  },
                  child: Row(
                    children: [
                      Text(
                        "List Tiket Panen",
                        style: buttonStyle16,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 60,
                margin: EdgeInsets.only(bottom: 10),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      receivedVia = "internet";
                    });
                    navigateToReceivedTicket();
                  },
                  child: Row(
                    children: [
                      Text(
                        "Internet",
                        style: buttonStyle16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget _saveButton() {
    return OutlinedButton(
      onPressed: () {
        if (harvestTicketList.isEmpty) {
          Toast.show("Belum memasukkan tiket panen", duration: 3, gravity: 1);
        } else {
          addDataToDatabase(context);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        child: Text(SAVE_BUTTON, style: buttonStyle18),
      ),
    );
  }

  void navigateToSearchTicket() async {
    List<HarvestingTicket> harvestTicketTemp = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SearchHarvestTicketCollection()));
    for (int i = 0; i < harvestTicketTemp.length; i++) {
      if (contains(harvestTicketTemp[i]) == true) {
        Toast.show("Ticket Sudah Ada", duration: 1, gravity: 0);
        setState(() {
          harvestTicketTemp.remove(harvestTicketTemp[i]);
          harvestTicketTemp = harvestTicketTemp;
        });
      } else {
        setState(() {
          harvestTicketList.add(harvestTicketTemp[i]);
          totalJanjang = totalJanjang + harvestTicketTemp[i].quantity!;
          totalWeight = totalWeight + harvestTicketTemp[i].weight;
        });
      }
    }
  }

  void navigateToReceivedTicket() async {
    List<HarvestingTicket> harvestTicketTemp = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => TicketReceivedScreen()));
    setState(() {
      for (int i = 0; i < harvestTicketTemp.length; i++) {
        harvestTicketList.add(harvestTicketTemp[i]);
        totalJanjang = totalJanjang + harvestTicketTemp[i].quantity!;
        totalWeight = totalWeight + harvestTicketTemp[i].weight;
      }
    });
  }

  void doSaveTransferTicket() async {
    List<HarvestingTicket> listHarvest = [];
    TransferHarvestingTicketBody transferBody = TransferHarvestingTicketBody();
    for (int i = 0; i < harvestTicketList.length; i++) {
      if (harvestTicketList[i].createdBy == "other") {
        HarvestingTicket harvestingTicket = HarvestingTicket();
        harvestingTicket.idTicket = harvestTicketList[i].idTicket;
        harvestingTicket.ascendFarmerCode =
            harvestTicketList[i].ascendFarmerCode;
        harvestingTicket.weight = harvestTicketList[i].weight;
        harvestingTicket.quantity = harvestTicketList[i].quantity!.toInt();
        harvestingTicket.idCollectionTicket =
            harvestTicketList[i].idCollectionTicket;
        listHarvest.add(harvestingTicket);
      }
    }
    transferBody.harvestingTicket = listHarvest;
    String userToken = await StorageManager.readData('token');
    SaveTransferRepository(APIEndpoint.BASE_URL).doSaveTransferTicket(
        transferBody,
        userToken,
        onSuccessTransferCallback,
        onErrorTransferCallback);
  }

  onSuccessTransferCallback(TransferResponse transferResponse) {
    print("Berhasil menandai");
  }

  onErrorTransferCallback(response) {
    print("Gagal Menandai");
  }

  void checkExistTicket(HarvestingTicket harvestingTicket) async {
    bool exist = await DatabaseHarvestTicket()
        .checkHarvestTicketExist(harvestingTicket.idTicket!);
    Farmers farmers = await DatabaseFarmer().selectFarmerByID(harvestingTicket);
    if (exist == true) {
      Toast.show("Ticket Sudah Ada", duration: 1, gravity: 0);
    } else {
      setState(() {
        String year =
            "20" + harvestingTicket.idTicket!.substring(1, 3).toString();
        String month = harvestingTicket.idTicket!.substring(3, 5);
        String day = harvestingTicket.idTicket!.substring(5, 7);
        String hour = harvestingTicket.idTicket!.substring(7, 9);
        String minute = harvestingTicket.idTicket!.substring(9, 11);
        harvestingTicket.dateTicket =
            year + "-" + month + "-" + day + " " + hour + ":" + minute;
        harvestingTicket.receivedVia = this.receivedVia;
        harvestingTicket.farmerName = farmers.fullname;
        harvestingTicket.mFarmerID = farmers.idFarmer;
        harvestingTicket.ascendFarmerID = farmers.ascendFarmerId;
        this.totalJanjang = totalJanjang + harvestingTicket.quantity!;
        this.totalWeight =
            totalWeight + roundDouble(harvestingTicket.weight, 2);
        harvestTicketList.add(harvestingTicket);
      });
    }
  }
}
