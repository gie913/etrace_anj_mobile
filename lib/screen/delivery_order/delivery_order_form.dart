import 'dart:async';
import 'dart:math';

import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/screen/harvest_ticket/harvest_ticket_form_new.dart';
import 'package:e_trace_app/database_local/database_collection_point.dart';
import 'package:e_trace_app/database_local/database_harvest_ticket.dart';
import 'package:e_trace_app/database_local/database_supplier.dart';
import 'package:e_trace_app/model/delivery_order.dart';
import 'package:e_trace_app/model/harvesting_ticket.dart';
import 'package:e_trace_app/model/suppliers.dart';
import 'package:e_trace_app/model/transfer_response.dart';
import 'package:e_trace_app/screen/delivery_order/search_collection_point_delivery.dart';
import 'package:e_trace_app/screen/delivery_order/search_supplier_screen.dart';
import 'package:e_trace_app/screen/harvest_ticket/harvest_ticket_form.dart';
import 'package:e_trace_app/screen/harvest_ticket/save_repository.dart';
import 'package:e_trace_app/screen/harvest_ticket/ticket_received_screen.dart';
import 'package:e_trace_app/screen/harvest_ticket/transfer_harvest_ticket.dart';
import 'package:e_trace_app/screen/home/counter_notifier.dart';
import 'package:e_trace_app/utils/auto_uppercase.dart';
import 'package:e_trace_app/utils/separator_thousand.dart';
import 'package:e_trace_app/utils/storage_manager.dart';
import 'package:e_trace_app/utils/time_utils.dart';
import 'package:e_trace_app/widget/back_from_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'search_harvest_ticket_delivery.dart';

class DeliveryOrderForm extends StatefulWidget {
  final DeliveryOrder deliveryOrder;

  DeliveryOrderForm({this.deliveryOrder});

  @override
  DeliveryOrderFormState createState() =>
      DeliveryOrderFormState(this.deliveryOrder);
}

class DeliveryOrderFormState extends State<DeliveryOrderForm> with SingleTickerProviderStateMixin{
  String idDelivery, dateDelivery, gpsLocation;
  String record = "", receivedVia;
  bool loading, validatePlatNumber = false, validateDriver = false;

  DeliveryOrderFormState(this.deliveryOrder);

  Suppliers supplierObject;
  DeliveryOrder deliveryOrder;
  Position position;
  String companyName, gpsLat, gpsLong, username;
  TextEditingController platNumberController = TextEditingController();
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController driverController = TextEditingController();
  var noteController = TextEditingController();
  TabController tabController;
  List<HarvestingTicket> harvestTicketList = [];
  HarvestingTicket harvestTicket;
  int totalJanjang = 0;
  double totalWeight = 0;
  DateTime now = DateTime.now();

  @override
  void initState() {
    generateIDDelivery();
    generateDateDelivery();
    tabController = TabController(length: 2, vsync: this);
    if (deliveryOrder != null) {
      platNumberController.text = deliveryOrder.platNumber;
      cardNumberController.text = deliveryOrder.cardNumber;
      driverController.text = deliveryOrder.driverName;
      noteController.text = deliveryOrder.note;
      getHarvestTicketDeliveryOrderList();
      getSupplierByID(deliveryOrder);
    }
    getLocation();
    super.initState();
  }

  getHarvestTicketDeliveryOrderList() async {
    List<HarvestingTicket> list = await DatabaseHarvestTicket()
        .getHarvestTicketListDelivery(widget.deliveryOrder);
    if (list.isNotEmpty) {
      for (int i = 0; i < list.length; i++) {
        this.totalWeight = roundDouble(totalWeight + list[i].weight, 2);
        this.totalJanjang = totalJanjang + list[i].quantity;
      }
    }
    setState(() {
      this.harvestTicketList = list;
    });
  }

  generateIDDelivery() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    companyName = prefs.getString("userPT");
    username = prefs.getString("username");
    if (deliveryOrder != null) {
      idDelivery = deliveryOrder.idDelivery;
    } else {
      NumberFormat formatter = new NumberFormat("0000");
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String number =
      formatter.format(int.parse(prefs.getString('userSequence')));
      setState(() {
        companyName = prefs.getString("userPT");
        idDelivery = "D" + TimeUtils.getIDOnTime(now) + number;
      });
    }
  }

  generateDateDelivery() {
    setState(() {
      if (deliveryOrder != null) {
        dateDelivery = deliveryOrder.dateDelivery;
      } else {
        dateDelivery = TimeUtils.getTime(now).toString();
      }
    });
  }

  void getSupplierByID(DeliveryOrder deliveryOrder) async {
    Suppliers suppliers =
    await DatabaseSupplier().selectSupplierByID(deliveryOrder);
    setState(() {
      this.supplierObject = suppliers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => onWillPopForm(context),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(TITLE_DELIVERY_ORDER_FORM),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: TabBar(
                controller: tabController,
                tabs: [
                  Tab(text: "Surat Pengantar TBS"),
                  Tab(text: "List Tiket Panen")
                ],
              ),
            ),
          ),
          body: TabBarView(
            controller: tabController,
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
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            height: 5,
                            margin: EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.blue,
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
                                  )),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    ID_DELIVERY_ORDER_FORM,
                                    style: text16Bold,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 6.0, bottom: 10.0),
                                    child: Text(
                                      "$idDelivery",
                                      style: text16Bold,
                                    ),
                                  )
                                ],
                              ),
                              Divider(),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DATE_FORM,
                                    style: text14Bold,
                                  ),
                                  Text(dateDelivery)
                                ],
                              ),
                              Divider(),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(GPS_LOCATION_FORM, style: text14Bold),
                                  loading
                                      ? SizedBox(
                                    height: 10.0,
                                    width: 10.0,
                                    child: new CircularProgressIndicator(
                                      value: null,
                                      strokeWidth: 1.0,
                                    ),
                                  )
                                      : Text("$gpsLat,$gpsLong", overflow: TextOverflow.ellipsis)
                                ],
                              ),
                              Divider(),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Pabrik", style: text14Bold),
                                  Text(
                                    "$companyName",
                                    overflow: TextOverflow.ellipsis,
                                  )
                                ],
                              ),
                              Divider(),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total Jumlah Janjang",
                                    style: text14Bold,
                                  ),
                                  Text("$totalJanjang")
                                ],
                              ),
                              Divider(),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total Berat Janjang",
                                    style: text14Bold,
                                  ),
                                  Text("${formatThousandSeparator(totalWeight.round())}")
                                ],
                              ),
                              Divider(),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    SUPPLIER,
                                    style: text14Bold,
                                  ),
                                  Container(
                                      child: ElevatedButton(
                                          style: ButtonStyle(),
                                          onPressed: () async {
                                            Suppliers supplierNameTemp =
                                            await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        SearchSupplierScreen()));
                                            setState(() {
                                              if (supplierNameTemp == null) {
                                                supplierObject = supplierObject;
                                              } else {
                                                supplierObject =
                                                    supplierNameTemp;
                                              }
                                            });
                                          },
                                          child: Icon(
                                            supplierObject != null
                                                ? Icons.edit
                                                : Icons.add,
                                            color: Colors.white,
                                          ))),
                                ],
                              ),
                              supplierObject != null
                                  ? Table(
                                border: TableBorder.all(),
                                children: [
                                  TableRow(children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("Kode Supplier",
                                          textAlign: TextAlign.center),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Nama',
                                          textAlign: TextAlign.center),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          "${supplierObject.ascendSupplierCode}",
                                          textAlign: TextAlign.center),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          "${supplierObject.name}",
                                          textAlign: TextAlign.center),
                                    ),
                                  ]),
                                ],
                              )
                                  : Container(),
                              Divider(),
                              Padding(
                                padding: const EdgeInsets.only(top: 0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DRIVER,
                                      style: text14Bold,
                                    ),
                                    Flexible(
                                      child: Container(
                                        width: 160,
                                        child: TextField(
                                          textCapitalization:
                                          TextCapitalization.words,
                                          onChanged: (value) {
                                            value != null
                                                ? validateDriver = false
                                                : validateDriver = true;
                                          },
                                          controller: driverController,
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            errorText: validateDriver
                                                ? 'Belum Terisi'
                                                : null,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                              borderSide: BorderSide(width: 1),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(),
                              Padding(
                                padding: const EdgeInsets.only(top: 0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Plat Nomor (*Wajib diisi)",
                                        style: text14Bold),
                                    Flexible(
                                      child: Container(
                                        width: 160,
                                        child: TextField(
                                          textCapitalization:
                                          TextCapitalization.characters,
                                          onChanged: (value) {
                                            value != null
                                                ? validatePlatNumber = false
                                                : validatePlatNumber = true;
                                          },
                                          inputFormatters: [
                                            FilteringTextInputFormatter.deny(
                                                RegExp('[ ]')),
                                            UpperCaseTextFormatter(),
                                          ],
                                          controller: platNumberController,
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            errorText: validatePlatNumber
                                                ? 'Belum Terisi'
                                                : null,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                              borderSide: BorderSide(width: 1),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Divider(),
                              // Padding(
                              //   padding: const EdgeInsets.only(top: 0),
                              //   child: Row(
                              //     mainAxisAlignment:
                              //     MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       Text(CARD_NUMBER, style: text14Bold),
                              //       Flexible(
                              //         child: Container(
                              //           width: 160,
                              //           height: 50,
                              //           child: TextField(
                              //             inputFormatters: [
                              //               FilteringTextInputFormatter.deny(
                              //                   RegExp('[ ]')),
                              //               UpperCaseTextFormatter(),
                              //             ],
                              //             controller: cardNumberController,
                              //             textAlign: TextAlign.center,
                              //             decoration: InputDecoration(
                              //               border: OutlineInputBorder(
                              //                 borderRadius: BorderRadius.all(
                              //                     Radius.circular(10)),
                              //                 borderSide: BorderSide(width: 1),
                              //               ),
                              //             ),
                              //           ),
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              Divider(),
                              Padding(
                                padding: const EdgeInsets.only(),
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
                                padding:
                                const EdgeInsets.only(top: 10, bottom: 60),
                                child: _saveButton(),
                              )
                            ],
                          ),
                        ],
                      ),
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
                              Text(
                                "Total Jumlah Janjang",
                                style: text14Bold,
                              ),
                              Text("$totalJanjang")
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total Berat Janjang", style: text14Bold),
                              Text(
                                "${formatThousandSeparator(totalWeight.round())}",
                              )
                            ],
                          ),
                          Column(
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
                              Padding(
                                padding: const EdgeInsets.only(),
                                child: OutlinedButton(
                                  onPressed: () async {
                                    HarvestingTicket harvestingTicket = await Navigator.push(context,
                                        MaterialPageRoute(builder: (BuildContext context) {
                                          return HarvestTicketFormNew();
                                        }));
                                    if(harvestingTicket != null) {
                                      setState(() {
                                        harvestTicketList.add(harvestingTicket);
                                        this.totalJanjang = totalJanjang + harvestingTicket.quantity;
                                        this.totalWeight = totalWeight + roundDouble(harvestingTicket.weight, 2);
                                      });
                                    }
                                  },
                                  child: Container(
                                    child: Text(
                                      "Buat Tiket Panen Baru",
                                      style: buttonStyle16,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Flexible(child: containerList()),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  showTransferDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
        title: Center(child: Text("Pilih Tiket Melalui")),
        content: Container(
          height: 300,
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
                      receivedVia = null;
                    });
                    navigateToSearchCollectionPoint();
                  },
                  child: Row(
                    children: [
                      Text(
                        "List Titik Kumpul",
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
                    onTap: () async {
                      HarvestingTicket result =
                      await Navigator.push(context, MaterialPageRoute(
                          builder: (BuildContext context) {
                            return HarvestTicketForm(
                                harvestTicket: harvestTicketList[index]);
                          }));
                      if (result != null) {
                        if (deliveryOrder == null) {
                          setState(() {
                            harvestTicketList.removeAt(index);
                            harvestTicketList.insert(index, result);
                            totalJanjang = 0;
                            totalWeight = 0;
                            for (int i = 0;
                            i < harvestTicketList.length;
                            i++) {
                              totalJanjang +=
                                  harvestTicketList[i].quantity;
                              totalWeight += harvestTicketList[i].weight;
                            }
                          });
                        } else {
                          if (harvestTicketList[index].idDeliveryOrderTicket == "null") {
                            setState(() {
                              harvestTicketList.removeAt(index);
                              harvestTicketList.insert(index, result);
                              totalJanjang = 0;
                              totalWeight = 0;
                              for (int i = 0;
                              i < harvestTicketList.length;
                              i++) {
                                totalJanjang +=
                                    harvestTicketList[i].quantity;
                                totalWeight += harvestTicketList[i].weight;
                              }
                            });
                          } else {
                            setState(() {
                              harvestTicketList.removeAt(index);
                              harvestTicketList.insert(index, result);
                              totalJanjang = 0;
                              totalWeight = 0;
                              for (int i = 0;
                              i < harvestTicketList.length;
                              i++) {
                                totalJanjang +=
                                    harvestTicketList[i].quantity;
                                totalWeight += harvestTicketList[i].weight;
                              }
                            });
                            DatabaseHarvestTicket()
                                .updateHarvestTicket(result);
                          }
                        }
                      }
                    },
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
                    title: Text(harvestTicketList[index].idTicket),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Tanggal: ${harvestTicketList[index].dateTicket}"),
                            Text(
                                "Janjang/Berat(Kg): ${harvestTicketList[index].quantity}/${formatThousandSeparator(harvestTicketList[index].weight.round())}"),
                            Text(
                                "Kode Areal: ${harvestTicketList[index].ascendFarmerCode}"),
                            Text(
                                "TK: ${harvestTicketList[index].idCollectionTicket ?? "-"}"),
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

  Future _scan() async {
    await Permission.camera.request();
    String barcode = await scanner.scan();
    if (barcode == null) {
      print('nothing return.');
    } else {
      splitQRCodeHarvestTicket(barcode);
    }
  }

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
        setState(() {
          HarvestingTicket harvestTicket = HarvestingTicket();
          harvestTicket.idTicket = value1;
          harvestTicket.ascendFarmerCode = value2;
          harvestTicket.quantity = int.parse(value3);
          harvestTicket.weight = double.parse(value4);
          if (value5 == username) {
            if (contains(harvestTicket) == true) {
              Toast.show("Ticket Sudah Ada", context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
            } else {
              checkExistTicket(harvestTicket);
            }
          } else {
            Toast.show("Anda bukan tujuan kepemilikan data ini", context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
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
          harvestTicket.quantity = int.parse(value3);
          harvestTicket.weight = double.parse(value4);
          if (contains(harvestTicket) == true) {
            Toast.show("Ticket Sudah Ada", context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
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
          harvestTicket.quantity = int.parse(value3);
          harvestTicket.weight = double.parse(value4);
          harvestTicket.idCollectionTicket = value5;
          if (value6 == username) {
            if (contains(harvestTicket) == true) {
              Toast.show("Ticket Sudah Ada", context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
            } else {
              checkExistTicket(harvestTicket);
            }
          } else {
            Toast.show("Anda bukan tujuan kepemilikan data ini", context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          }
        });
      } else if (splitTicket.length == 8) {
        Toast.show("Kartu Berisi Delivery Order", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }
    }
  }

  double roundDouble(double value, int places) {
    double mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  bool contains(HarvestingTicket object) {
    for (int i = 0; i < harvestTicketList.length; i++) {
      if (harvestTicketList[i].idTicket == object.idTicket) return true;
    }
    return false;
  }

  void removeList(int index) {
    if (deliveryOrder == null) {
      int totalJanjangTemp = totalJanjang - harvestTicketList[index].quantity;
      double totalWeightTemp = totalWeight - harvestTicketList[index].weight;
      setState(() {
        this.totalJanjang = totalJanjangTemp;
        this.totalWeight = roundDouble(totalWeightTemp, 2);
        harvestTicketList.remove(harvestTicketList[index]);
        this.harvestTicketList = harvestTicketList;
      });
    } else {
      int totalJanjangTemp = totalJanjang - harvestTicketList[index].quantity;
      double totalWeightTemp = totalWeight - harvestTicketList[index].weight;
      setState(() {
        this.totalJanjang = totalJanjangTemp;
        this.totalWeight = roundDouble(totalWeightTemp, 2);
        harvestTicketList.remove(harvestTicketList[index]);
        this.harvestTicketList = harvestTicketList;
        DatabaseHarvestTicket()
            .updateHarvestTicketDeliveryDelete(deliveryOrder.idDelivery);
      });
    }
  }

  getLocation() async {
    loading = true;
    if (deliveryOrder != null) {
      gpsLat = deliveryOrder.gpsLat;
      gpsLong = deliveryOrder.gpsLong;
      loading = false;
    } else {
      try {
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high)
            .timeout(const Duration(seconds: 10));
        setState(() {
          gpsLat = position.latitude.toString();
          gpsLong = position.longitude.toString();
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

  void addHarvestTicket(HarvestingTicket object) async {
    DatabaseHarvestTicket dbHarvest = DatabaseHarvestTicket();
    object.createdBy = "other";
    int result = await dbHarvest.insertHarvestTicketFromOther(object);
    print(result);
  }

  void addHarvestTicketNew(HarvestingTicket object) async {
    DatabaseHarvestTicket dbHarvest = DatabaseHarvestTicket();
    int result = await dbHarvest.insertHarvestTicketFromOther(object);
    print(result);
  }

  void updateHarvestTicket(HarvestingTicket object) async {
    DatabaseHarvestTicket dbHarvest = DatabaseHarvestTicket();
    int result = await dbHarvest.updateHarvestTicket(object);
    print("$result Update Harvest Ticket from Delivery");
  }

  void updateCollectionPoint(String idCollection, String idDelivery) async {
    DatabaseCollectionPoint dbCollection = DatabaseCollectionPoint();
    int result = await dbCollection.updateCollectionPointDeliverySave(
        idCollection, idDelivery);
    print("$result Update Collection Point from Delivery");
  }

  addDataToDatabase(BuildContext context) async {
    context.read<CounterNotifier>().getCountUnUploadedDeliveryOrder();
    for (int i = 0; i < harvestTicketList.length; i++) {
      String year =
          "20" + harvestTicketList[i].idTicket.substring(1, 3).toString();
      String month = harvestTicketList[i].idTicket.substring(3, 5);
      String day = harvestTicketList[i].idTicket.substring(5, 7);
      String hour = harvestTicketList[i].idTicket.substring(7, 9);
      String minute = harvestTicketList[i].idTicket.substring(9, 11);
      harvestTicketList[i].dateTicket =
          year + "-" + month + "-" + day + " " + hour + ":" + minute;
      harvestTicketList[i].idDeliveryOrderTicket = this.idDelivery;
      harvestTicketList[i].receivedVia = receivedVia;
      harvestTicketList[i].idCollectionTicketOld =
          harvestTicketList[i].idCollectionTicket;
      harvestTicketList[i].uploaded = "false";
      harvestTicketList[i].transferred = "false";
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String user = prefs.getString('username');
      if(harvestTicketList[i].createdBy == "") {
        harvestTicketList[i].createdBy = user;
        addHarvestTicketNew(harvestTicketList[i]);
      }
      if (harvestTicketList[i].createdBy == user) {
        updateHarvestTicket(harvestTicketList[i]);
        if (harvestTicketList[i].idCollectionTicket != null) {
          updateCollectionPoint(
              harvestTicketList[i].idCollectionTicket, idDelivery);
        }
      } else if (harvestTicketList[i].mFarmerID == null &&
          harvestTicketList[i].createdBy == "other") {
        updateHarvestTicket(harvestTicketList[i]);
        if (harvestTicketList[i].idCollectionTicket != null) {
          updateCollectionPoint(
              harvestTicketList[i].idCollectionTicket, idDelivery);
        }
      } else if (harvestTicketList[i].createdBy == null) {
        updateCollectionPoint(
            harvestTicketList[i].idCollectionTicket, idDelivery);
        addHarvestTicket(harvestTicketList[i]);
      } else {
        updateHarvestTicket(harvestTicketList[i]);
        updateCollectionPoint(
            harvestTicketList[i].idCollectionTicket, idDelivery);
      }
    }
    if (deliveryOrder == null) {
      deliveryOrder = DeliveryOrder(
          idDelivery: idDelivery,
          dateDelivery: dateDelivery,
          gpsLong: gpsLong ?? null,
          gpsLat: gpsLat ?? null,
          supplierID: supplierObject.idSupplier.toString(),
          ascentSupplierID: supplierObject.ascendSupplierId.toString(),
          ascentSupplierCode: supplierObject.ascendSupplierCode.toString(),
          driverName: driverController.text,
          uploaded: "false",
          totalQuantity: totalJanjang,
          totalWeight: totalWeight,
          createdBy: username,
          transferred: "false",
          note: noteController.text,
          platNumber: platNumberController.text,
          cardNumber: cardNumberController.text,
          supplierName: supplierObject.name,
          image: "");
    } else {
      deliveryOrder.idDelivery = idDelivery;
      deliveryOrder.dateDelivery = dateDelivery;
      deliveryOrder.gpsLong = gpsLong;
      deliveryOrder.gpsLat = gpsLat;
      deliveryOrder.createdBy = deliveryOrder.createdBy;
      deliveryOrder.supplierID = supplierObject.idSupplier;
      deliveryOrder.ascentSupplierCode = supplierObject.ascendSupplierCode;
      deliveryOrder.ascentSupplierID = supplierObject.ascendSupplierId;
      deliveryOrder.driverName = driverController.text;
      deliveryOrder.totalQuantity = totalJanjang;
      deliveryOrder.uploaded = "false";
      deliveryOrder.totalWeight = totalWeight;
      deliveryOrder.platNumber = platNumberController.text;
      deliveryOrder.cardNumber = cardNumberController.text;
      deliveryOrder.supplierName = supplierObject.name;
      deliveryOrder.note = noteController.text;
      deliveryOrder.image = "";
    }
    doSaveTransferTicket();
    Navigator.pop(context, deliveryOrder);
  }

  Widget _saveButton() {
    return OutlinedButton(
      onPressed: () {
        if (harvestTicketList.isEmpty) {
          Toast.show("Belum memasukkan tiket panen", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
        } else if (supplierObject == null) {
          Toast.show("Supplier Belum Terisi", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        } else if (driverController.text.isEmpty) {
          setState(() {
            validateDriver = true;
          });
        } else if (platNumberController.text.isEmpty) {
          setState(() {
            validatePlatNumber = true;
          });
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

  Widget _inputHarvestTicketButton() {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          tabController.animateTo(1);
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

  void navigateToSearchTicket() async {
    List<HarvestingTicket> harvestTicketTemp = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => SearchHarvestTicketDelivery()));
    if (harvestTicketTemp != null) {
      for (int i = 0; i < harvestTicketTemp.length; i++) {
        if (contains(harvestTicketTemp[i]) == true) {
          Toast.show("Ticket Sudah Ada", context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          harvestTicketTemp.remove(harvestTicketTemp);
        } else {
          setState(() {
            harvestTicketList.add(harvestTicketTemp[i]);
            totalJanjang = totalJanjang + harvestTicketTemp[i].quantity;
            totalWeight =
                totalWeight + roundDouble(harvestTicketTemp[i].weight, 2);
          });
        }
      }
    }
  }

  void checkExistTicket(HarvestingTicket harvestingTicket) async {
    bool exist = await DatabaseHarvestTicket()
        .checkHarvestTicketExist(harvestingTicket.idTicket);
    if (exist == true) {
      Toast.show("Ticket Sudah Ada", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    } else {
      setState(() {
        String year =
            "20" + harvestingTicket.idTicket.substring(1, 3).toString();
        String month = harvestingTicket.idTicket.substring(3, 5);
        String day = harvestingTicket.idTicket.substring(5, 7);
        String hour = harvestingTicket.idTicket.substring(7, 9);
        String minute = harvestingTicket.idTicket.substring(9, 11);
        harvestingTicket.dateTicket =
            year + "-" + month + "-" + day + " " + hour + ":" + minute;
        this.totalJanjang = totalJanjang + harvestingTicket.quantity;
        this.totalWeight = totalWeight + roundDouble(harvestingTicket.weight, 2);
        harvestTicketList.add(harvestingTicket);
      });
    }
  }

  void navigateToSearchCollectionPoint() async {
    List<HarvestingTicket> harvestTicketTemp = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => SearchCollectionDelivery()));
    if (harvestTicketTemp != null) {
      for (int i = 0; i < harvestTicketTemp.length; i++) {
        if (contains(harvestTicketTemp[i]) == true) {
          Toast.show("Ticket Sudah Ada", context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          harvestTicketTemp.remove(harvestTicketTemp[i]);
        } else {
          setState(() {
            harvestTicketList.add(harvestTicketTemp[i]);
            totalJanjang = totalJanjang + harvestTicketTemp[i].quantity;
            totalWeight =
                totalWeight + roundDouble(harvestTicketTemp[i].weight, 2);
          });
        }
      }
    }
  }
  //
  // void _startScanning() {
  //   showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         title: Center(
  //             child: Text(
  //               "Tempel Kartu NFC",
  //               style: TextStyle(color: Colors.black),
  //             )),
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
  //                 child: Text(
  //                   "Untuk memasukkan data",
  //                   style: TextStyle(color: Colors.black),
  //                 ),
  //               ),
  //               OutlinedButton(
  //                 onPressed: () {
  //                   _stopScanning();
  //                   Navigator.pop(context);
  //                 },
  //                 child: Container(
  //                   width: MediaQuery.of(context).size.width,
  //                   padding: EdgeInsets.all(10),
  //                   child: Center(child: Text("Selesai", style: buttonStyle16)),
  //                 ),
  //               )
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
  //         Toast.show("Kartu tidak terisi", context,
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
  //
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
      content: Text("Anda ingin menghapus data?"),
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

  void navigateToReceivedTicket() async {
    List<HarvestingTicket> harvestTicketTemp = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => TicketReceivedScreen()));
    if (harvestTicketTemp != null) {
      setState(() {
        print(harvestTicketTemp.length);
        for (int i = 0; i < harvestTicketTemp.length; i++) {
          harvestTicketList.add(harvestTicketTemp[i]);
          totalJanjang = totalJanjang + harvestTicketTemp[i].quantity;
          totalWeight = totalWeight + harvestTicketTemp[i].weight;
        }
      });
    }
  }

  void doSaveTransferTicket() async {
    List<HarvestingTicket> listHarvest = [];
    TransferHarvestingTicketBody transferBody = TransferHarvestingTicketBody();
    for (int i = 0; i < harvestTicketList.length; i++) {
      HarvestingTicket harvestingTicket = HarvestingTicket();
      harvestingTicket.idTicket = harvestTicketList[i].idTicket;
      harvestingTicket.ascendFarmerCode = harvestTicketList[i].ascendFarmerCode;
      harvestingTicket.weight = harvestTicketList[i].weight;
      harvestingTicket.quantity = harvestTicketList[i].quantity.toInt();
      harvestingTicket.idCollectionTicket =
          harvestTicketList[i].idCollectionTicket;
      listHarvest.add(harvestingTicket);
    }
    transferBody.harvestingTicket = listHarvest;
    String userToken = await StorageManager.readData('token');
    SaveTransferRepository(APIEndpoint.BASE_URL).doSaveTransferTicket(transferBody,
        userToken, onSuccessTransferCallback, onErrorTransferCallback);
  }

  onSuccessTransferCallback(TransferResponse transferResponse) {
    print("Berhasil menandai");
  }

  onErrorTransferCallback(response) {
    print("Gagal Menandai");
  }
}
