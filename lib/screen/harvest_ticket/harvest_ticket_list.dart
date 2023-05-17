import 'dart:async';

import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/database_local/database_harvest_ticket.dart';
import 'package:e_trace_app/database_local/database_helper.dart';
import 'package:e_trace_app/model/harvesting_ticket.dart';
import 'package:e_trace_app/screen/harvest_ticket/harvest_ticket_detail.dart';
import 'package:e_trace_app/screen/harvest_ticket/harvest_ticket_form.dart';
import 'package:e_trace_app/screen/harvest_ticket/harvest_ticket_tranfer_batch.dart';
import 'package:e_trace_app/model/farmers.dart';
import 'package:e_trace_app/screen/home/counter_notifier.dart';
import 'package:e_trace_app/database_local/database_farmer.dart';
import 'package:e_trace_app/utils/separator_thousand.dart';
import 'package:flutter/material.dart';
import 'package:e_trace_app/widget/loading_widget.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toast/toast.dart';

class HarvestTicketScreen extends StatefulWidget {
  @override
  HarvestTicketScreenState createState() => HarvestTicketScreenState();
}

class HarvestTicketScreenState extends State<HarvestTicketScreen> {
  DatabaseHelper dbHelper = DatabaseHelper();
  DatabaseHarvestTicket dbHarvest = DatabaseHarvestTicket();
  TextEditingController typeTicketController = TextEditingController();
  List<HarvestingTicket> harvestTicketList = [];
  List<HarvestingTicket> harvestTicketListSearch = [];
  String farmerName, farmerAddress, farmerNumber;
  bool isLoading;

  @override
  void initState() {
    updateListView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(HARVEST_TICKET),
        actions: [
          InkWell(
            onTap: () async {
              if (harvestTicketList.isEmpty) {
                Toast.show("Belum Ada Tiket Panen", context,
                    duration: Toast.LENGTH_SHORT, gravity: Toast.TOP);
              } else {
                bool result = await Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return HarvestTicketTransferBatch();
                }));
                if (result) {
                  updateListView();
                }
              }
            },
            child: Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Icon(Icons.send_outlined)),
          ),
          InkWell(
            onTap: () async {
              var contact = await navigateToEntryForm(context, null);
              if (contact != null) addHarvestTicket(contact);
            },
            child: Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Icon(Typicons.doc_add)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Container(
                child: ListTile(
                  leading: Icon(Icons.search),
                  title: TextField(
                    controller: typeTicketController,
                    decoration: InputDecoration(
                        hintText: SEARCH, border: InputBorder.none),
                    onChanged: onSearchTextChanged,
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () {
                      typeTicketController.clear();
                      onSearchTextChanged('');
                    },
                  ),
                ),
              ),
            ),
          ),
          Text("Jumlah Tiket Panen: ${harvestTicketList.length}"),
          Divider(),
          isLoading
              ? loadingWidget()
              : harvestTicketList.length != 0
                  ? Flexible(
                      child: harvestTicketListSearch.length != 0 ||
                              typeTicketController.text.isNotEmpty
                          ? createListViewSearch()
                          : createListView())
                  : Flexible(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Linecons.note, size: 60, color: Colors.orange),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child:
                                  Text("Belum ada tiket panen", style: text16),
                            ),
                          ],
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Future<HarvestingTicket> navigateToDetail(
      BuildContext context, HarvestingTicket contact) async {
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return HarvestTicketDetail(harvestTicket: contact);
    }));
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

  onSearchTextChanged(String text) async {
    harvestTicketListSearch.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    harvestTicketList.forEach((collectionDetail) {
      if (collectionDetail.dateTicket
              .toLowerCase()
              .contains(text.toLowerCase()) ||
          collectionDetail.ascendFarmerCode
              .toString()
              .toLowerCase()
              .contains(text.toLowerCase()) ||
          collectionDetail.idTicket
              .toString()
              .toLowerCase()
              .contains(text.toLowerCase()) ||
          collectionDetail.farmerName
              .toString()
              .toLowerCase()
              .contains(text.toLowerCase()))
        harvestTicketListSearch.add(collectionDetail);
    });
    setState(() {});
  }

  ListView createListView() {
    return ListView.builder(
      itemCount: harvestTicketList.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Linecons.note, color: Colors.orange, size: 40),
                  trailing: Column(
                    children: [
                      harvestTicketList[index].transferred == "true" ||
                              harvestTicketList[index].idCollectionTicket !=
                                  null ||
                              harvestTicketList[index].idDeliveryOrderTicket !=
                                  null
                          ? Container(width: 0)
                          : GestureDetector(
                              onTap: () {
                                showDeleteDialog(
                                    context, harvestTicketList[index]);
                              },
                              child: Column(children: [
                                Icon(Linecons.trash),
                              ]),
                            ),
                      (harvestTicketList[index].transferred != "true")
                          ? Container(width: 0)
                          : Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text("transfer ✓",
                                  style: TextStyle(color: Colors.green)),
                            )
                    ],
                  ),
                  title: Text(harvestTicketList[index].idTicket,
                      style: text16Bold),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DATE_TICKET_TILE +
                            harvestTicketList[index].dateTicket),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text("Kode Areal: " +
                              "${harvestTicketList[index].ascendFarmerCode}"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text("Petani: " +
                              "${harvestTicketList[index].farmerName}"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text("Janjang/Berat(Kg): " +
                              "${harvestTicketList[index].quantity}/${formatThousandSeparator(harvestTicketList[index].weight.round())}"),
                        ),
                      ],
                    ),
                  ),
                  onTap: () async {
                    var contact = await navigateToDetail(
                        context, harvestTicketList[index]);
                    if (contact != null) editHarvestTicket(contact);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String> getFarmerByID(HarvestingTicket harvestTicket) async {
    String farmerName;
    Farmers farmers = await DatabaseFarmer().selectFarmerByID(harvestTicket);
    farmerName = farmers.fullname;
    return farmerName;
  }

  String getFarmerName(HarvestingTicket harvestingTicket) {
    String farmerName;
    getFarmerByID(harvestingTicket).then((value) => {
          setState(() {
            farmerName = value;
          })
        });
    return farmerName;
  }

  ListView createListViewSearch() {
    return ListView.builder(
      itemCount: harvestTicketListSearch.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Linecons.note,
                    size: 40,
                    color: Colors.orange,
                  ),
                  trailing: Column(
                    children: [
                      harvestTicketListSearch[index].transferred == "true" ||
                              harvestTicketListSearch[index]
                                      .idCollectionTicket !=
                                  null ||
                              harvestTicketListSearch[index]
                                      .idDeliveryOrderTicket !=
                                  null
                          ? Container(width: 0)
                          : GestureDetector(
                              onTap: () {
                                showDeleteDialog(
                                    context, harvestTicketListSearch[index]);
                              },
                              child: Column(children: [
                                Icon(Linecons.trash),
                              ]),
                            ),
                      (harvestTicketListSearch[index].transferred != "true")
                          ? Container(width: 0)
                          : Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text("transfer ✓",
                                  style: TextStyle(color: Colors.green)),
                            )
                    ],
                  ),
                  title: Text(
                    harvestTicketListSearch[index].idTicket,
                    style: text16Bold,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DATE_TICKET_TILE +
                            harvestTicketListSearch[index].dateTicket),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text("Kode Areal: " +
                              "${harvestTicketListSearch[index].ascendFarmerCode}"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text("Petani: " +
                              "${harvestTicketListSearch[index].farmerName}"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text("Janjang/Berat(Kg): " +
                              "${harvestTicketListSearch[index].quantity}/${formatThousandSeparator(harvestTicketList[index].weight.round())}"),
                        ),
                      ],
                    ),
                  ),
                  onTap: () async {
                    var contact = await navigateToDetail(
                        context, harvestTicketListSearch[index]);
                    if (contact != null) editHarvestTicket(contact);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String splitFarmer(String farmer) {
    final split = farmer.split(',');
    final Map<int, String> values = {
      for (int i = 0; i < split.length; i++) i: split[i]
    };
    final value1 = values[0];
    return value1;
  }

  showDeleteDialog(BuildContext context, HarvestingTicket object) {
    Widget cancelButton = TextButton(
      child: Text("Tidak", style: TextStyle(color: Colors.blue)),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Iya", style: TextStyle(color: Colors.red)),
      onPressed: () {
        deleteHarvestTicket(object);
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

  void addHarvestTicket(HarvestingTicket object) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('username');
    object.createdBy = user;
    int result = await dbHarvest.insertHarvestTicket(object);
    if (result > 0) {
      updateListView();
    }
  }

  void editHarvestTicket(HarvestingTicket object) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('username');
    object.createdBy = user;
    int result = await dbHarvest.updateHarvestTicket(object);
    if (result > 0) {
      updateListView();
    }
  }

  void deleteHarvestTicket(HarvestingTicket object) async {
    harvestTicketListSearch.remove(object);
    int result = await dbHarvest.deleteHarvestTicket(object);
    if (result > 0) {
      updateListView();
      // }
    }
  }

  void updateListView() {
    context.read<CounterNotifier>().getCountUnUploadedDeliveryOrder();
    context.read<CounterNotifier>().getCountUnUploadedHarvestTicket();
    context.read<CounterNotifier>().getCountUnUploadedCollectionPoint();
    final Future<Database> dbFuture = dbHelper.initDb();
    isLoading = true;
    dbFuture.then((database) {
      Future<List<HarvestingTicket>> harvestTicketListFuture =
          dbHarvest.getHarvestTicketList();
      harvestTicketListFuture.then((harvestTicketList) {
        setState(() {
          this.harvestTicketList = harvestTicketList.reversed.toList();
          this.isLoading = false;
        });
      });
    });
  }
}
