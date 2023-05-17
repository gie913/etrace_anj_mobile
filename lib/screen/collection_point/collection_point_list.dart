import 'dart:async';

import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/database_local/database_collection_point.dart';
import 'package:e_trace_app/database_local/database_harvest_ticket.dart';
import 'package:e_trace_app/database_local/database_helper.dart';
import 'package:e_trace_app/model/collection_point.dart';
import 'package:e_trace_app/screen/collection_point/collection_point_detail.dart';
import 'package:e_trace_app/screen/collection_point/collection_point_form.dart';
import 'package:e_trace_app/screen/home/counter_notifier.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:e_trace_app/widget/loading_widget.dart';

class CollectionPointScreen extends StatefulWidget {
  @override
  CollectionPointScreenState createState() => CollectionPointScreenState();
}

class CollectionPointScreenState extends State<CollectionPointScreen> {
  DatabaseHelper dbHelper = DatabaseHelper();
  DatabaseCollectionPoint dbCollection = DatabaseCollectionPoint();
  List<CollectionPoint> collectionPointList = [];
  List<CollectionPoint> collectionPointSearchResult = [];
  String farmerName, farmerAddress, farmerNumber;
  TextEditingController typeCollectionController = TextEditingController();
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
        title: Text(COLLECTION_POINT),
        actions: [
          InkWell(
            onTap: () async {
              var contact = await navigateToEntryForm(context, null);
              if (contact != null) addCollectionPoint(contact);
            },
            child: Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Icon(Typicons.doc_add)),
          )
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: Container(
              child: ListTile(
                leading: Icon(Icons.search),
                title: TextField(
                  controller: typeCollectionController,
                  decoration: InputDecoration(
                      hintText: SEARCH, border: InputBorder.none),
                  onChanged: onSearchTextChanged,
                ),
                trailing: IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    typeCollectionController.clear();
                    onSearchTextChanged('');
                  },
                ),
              ),
            ),
          ),
        ),
        Text("Jumlah Titik Kumpul: ${collectionPointList.length}"),
        Divider(),
        isLoading
            ? loadingWidget()
            : collectionPointList.length != 0
                ? Flexible(
                    child: collectionPointSearchResult.length != 0 ||
                            typeCollectionController.text.isNotEmpty
                        ? createListViewSearch()
                        : createListView())
                : Flexible(
                    child: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Linecons.inbox, color: Colors.green, size: 70),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Text("Belum ada Titik Kumpul TBS",
                                  style: text14),
                            ),
                          ]),
                    ),
                  ),
      ]),
    );
  }

  Future<CollectionPoint> navigateToDetail(
      BuildContext context, CollectionPoint contact) async {
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return CollectionPointDetail(collectionPoint: contact);
    }));
    return result;
  }

  Future<CollectionPoint> navigateToEntryForm(
      BuildContext context, CollectionPoint contact) async {
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return CollectionPointForm(collectionPoint: contact);
    }));
    return result;
  }

  onSearchTextChanged(String text) async {
    collectionPointSearchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    collectionPointList.forEach((collectionDetail) {
      if (collectionDetail.dateCollection
              .toLowerCase()
              .contains(text.toLowerCase()) ||
          collectionDetail.ascendAgentCode
              .toString()
              .toLowerCase()
              .contains(text.toLowerCase()) ||
          collectionDetail.idCollection
              .toString()
              .toLowerCase()
              .contains(text.toLowerCase()))
        collectionPointSearchResult.add(collectionDetail);
    });
    setState(() {});
  }

  ListView createListViewSearch() {
    return ListView.builder(
      itemCount: collectionPointSearchResult.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Linecons.inbox,
                    size: 40,
                    color: Colors.green,
                  ),
                  trailing: Column(
                    children: [
                      collectionPointSearchResult[index].transferred ==
                                  "true" ||
                              collectionPointSearchResult[index]
                                      .deliveryCollection !=
                                  null
                          ? Container(width: 0)
                          : GestureDetector(
                              onTap: () {
                                showDeleteDialog(context,
                                    collectionPointSearchResult[index]);
                              },
                              child: Column(children: [
                                Icon(Linecons.trash),
                              ]),
                            ),
                      (collectionPointSearchResult[index].transferred != "true")
                          ? Container(width: 0)
                          : Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text("transfer ✓",
                                  style: TextStyle(color: Colors.green)),
                            )
                    ],
                  ),
                  title: Text(
                    "${collectionPointSearchResult[index].idCollection}",
                    style: text16Bold,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DATE_TICKET_TILE +
                            collectionPointSearchResult[index].dateCollection),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text("Nama Agen: " +
                              "${collectionPointSearchResult[index].ascendAgentCode}"),
                        ),
                      ],
                    ),
                  ),
                  onTap: () async {
                    var contact = await navigateToDetail(
                        context, collectionPointSearchResult[index]);
                    if (contact != null) editCollectionPoint(contact);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ListView createListView() {
    return ListView.builder(
      itemCount: collectionPointList.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Linecons.inbox,
                    size: 40,
                    color: Colors.green,
                  ),
                  trailing: Column(
                    children: [
                      collectionPointList[index].transferred == "true" ||
                              collectionPointList[index].deliveryCollection !=
                                  null
                          ? Container(width: 0)
                          : GestureDetector(
                              onTap: () {
                                showDeleteDialog(
                                    context, collectionPointList[index]);
                              },
                              child: Column(children: [
                                Icon(Linecons.trash),
                              ]),
                            ),
                      (collectionPointList[index].transferred != "true")
                          ? Container(width: 0)
                          : Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text("transfer ✓",
                                  style: TextStyle(color: Colors.green)),
                            )
                    ],
                  ),
                  title: Text(
                    "${collectionPointList[index].idCollection}",
                    style: text16Bold,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DATE_TICKET_TILE +
                            collectionPointList[index].dateCollection),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text("Nama Agen: " +
                              "${collectionPointList[index].ascendAgentCode}"),
                        ),
                      ],
                    ),
                  ),
                  onTap: () async {
                    var contact = await navigateToDetail(
                        context, collectionPointList[index]);
                    if (contact != null) editCollectionPoint(contact);
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

  showDeleteDialog(BuildContext context, CollectionPoint object) {
    Widget cancelButton = TextButton(
      child: Text(NO, style: TextStyle(color: Colors.blue)),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text(YES, style: TextStyle(color: Colors.red)),
      onPressed: () {
        deleteCollectionPoint(object);
        Navigator.pop(context);
      },
    );
    AlertDialog alert = AlertDialog(
      content: Text("Anda ingin menghapus data?", style: text14),
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

  void addCollectionPoint(CollectionPoint object) async {
    int result = await dbCollection.insertCollectionPoint(object);
    if (result > 0) {
      updateListView();
    }
  }

  void editCollectionPoint(CollectionPoint object) async {
    int result = await dbCollection.updateCollectionPoint(object);
    if (result > 0) {
      updateListView();
    }
  }

  void deleteCollectionPoint(CollectionPoint object) async {
    int result = await dbCollection.deleteCollectionPoint(object);
    collectionPointSearchResult.remove(object);
    if (result > 0) {
      DatabaseHarvestTicket()
          .updateHarvestTicketCollection(object.idCollection);
      updateListView();
    }
  }

  void updateListView() {
    isLoading = true;
    context.read<CounterNotifier>().getCountUnUploadedDeliveryOrder();
    context.read<CounterNotifier>().getCountUnUploadedHarvestTicket();
    context.read<CounterNotifier>().getCountUnUploadedCollectionPoint();
    final Future<Database> dbFuture = dbHelper.initDb();
    dbFuture.then((database) {
      Future<List<CollectionPoint>> collectionPointListFuture =
          dbCollection.getCollectionPointList();
      collectionPointListFuture.then((collectionPointList) {
        setState(() {
          this.collectionPointList = collectionPointList.reversed.toList();
          this.isLoading = false;
        });
      });
    });
  }
}
