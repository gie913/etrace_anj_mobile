import 'dart:async';

import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/database_local/database_collection_point.dart';
import 'package:e_trace_app/database_local/database_harvest_ticket.dart';
import 'package:e_trace_app/database_local/database_helper.dart';
import 'package:e_trace_app/model/collection_point.dart';
import 'package:e_trace_app/model/harvesting_ticket.dart';
import 'package:e_trace_app/utils/separator_thousand.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:sqflite/sqflite.dart';

class SearchCollectionDelivery extends StatefulWidget {
  @override
  SearchCollectionDeliveryState createState() =>
      SearchCollectionDeliveryState();
}

class SearchCollectionDeliveryState extends State<SearchCollectionDelivery> {
  DatabaseHelper dbHelper = DatabaseHelper();
  DatabaseCollectionPoint dbCollection = DatabaseCollectionPoint();
  DatabaseHarvestTicket dbHarvest = DatabaseHarvestTicket();
  int count = 0;
  List<CollectionPoint> collectionPointList = [];
  List<CollectionPoint> collectionPointListChecked = [];
  List<HarvestingTicket> harvestingTicketCollection = [];
  String farmerName, farmerAddress, farmerNumber;
  List<bool> _isChecked;

  @override
  void initState() {
    updateListView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("List Titik Kumpul"),
        actions: [
          InkWell(
            onTap: () {
              getTicketByCollection(collectionPointListChecked);
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Icon(Icons.add_box_rounded),
            ),
          )
        ],
      ),
      body: collectionPointList.length != 0
          ? createListView()
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Linecons.inbox,
                    size: 60,
                    color: Colors.green,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      "Belum ada collection point",
                      style: text16,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  ListView createListView() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                CheckboxListTile(
                  value: _isChecked[index],
                  onChanged: (val) {
                    setState(
                      () {
                        _isChecked[index] = val;
                        if (_isChecked[index]) {
                          collectionPointListChecked
                              .add(collectionPointList[index]);
                        } else {
                          collectionPointListChecked
                              .remove(collectionPointList[index]);
                        }
                      },
                    );
                  },
                  secondary: Icon(
                    Linecons.inbox,
                    size: 35,
                    color: Colors.green,
                  ),
                  title: Text(
                    collectionPointList[index].idCollection,
                    style: text16Bold,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tanggal: " +
                            collectionPointList[index].dateCollection),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                              "Janjang/Berat(Kg): ${collectionPointList[index].totalQuantity}/${formatThousandSeparator(collectionPointList[index].totalWeight.round())}"),
                        ),
                      ],
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

  void updateListView() {
    final Future<Database> dbFuture = dbHelper.initDb();
    dbFuture.then((database) {
      Future<List<CollectionPoint>> collectionPointListFuture =
          dbCollection.getCollectionPointListForDelivery();
      collectionPointListFuture.then((collectionPointList) {
        setState(() {
          this.collectionPointList = collectionPointList;
          this.count = collectionPointList.length;
          _isChecked = List<bool>.filled(count, false);
        });
      });
    });
  }

  void getTicketByCollection(List<CollectionPoint> listCollection) async {
    for (int i = 0; i < listCollection.length; i++) {
      List<HarvestingTicket> list = await DatabaseHarvestTicket()
          .getHarvestTicketListCollection(listCollection[i]);
      if (list.isNotEmpty) {
        for (int i = 0; i < list.length; i++) {
          harvestingTicketCollection.add(list[i]);
        }
      }
    }
    if (harvestingTicketCollection.isNotEmpty) {
      Navigator.pop(context, harvestingTicketCollection);
    }
  }
}
