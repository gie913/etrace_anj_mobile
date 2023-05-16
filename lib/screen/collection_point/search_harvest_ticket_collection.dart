import 'dart:async';

import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/database_local/database_harvest_ticket.dart';
import 'package:e_trace_app/database_local/database_helper.dart';
import 'package:e_trace_app/model/harvesting_ticket.dart';
import 'package:e_trace_app/utils/separator_thousand.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:sqflite/sqflite.dart';

class SearchHarvestTicketCollection extends StatefulWidget {
  @override
  SearchHarvestTicketCollectionState createState() => SearchHarvestTicketCollectionState();
}

class SearchHarvestTicketCollectionState extends State<SearchHarvestTicketCollection> {
  DatabaseHelper dbHelper = DatabaseHelper();
  DatabaseHarvestTicket dbHarvest = DatabaseHarvestTicket();
  List<HarvestingTicket> harvestTicketList = [];
  List<HarvestingTicket> harvestTicketListChecked = [];
  String farmerName, farmerAddress, farmerNumber;
  List<bool> _isChecked;

  @override
  void initState() {
    updateListView();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (harvestTicketList == null) {
      harvestTicketList = [];
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("List Tiket Panen"),
        actions: [
          InkWell(
            onTap: () {
              Navigator.pop(context, harvestTicketListChecked);
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Icon(Icons.add_box_rounded),
            ),
          )
        ],
      ),
      body: harvestTicketList.length != 0
          ? createListView()
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Linecons.note, size: 60, color: Colors.orange),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text("Belum ada tiket panen"),
                  ),
                ],
              ),
            ),
    );
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
                CheckboxListTile(
                  value: _isChecked[index],
                  onChanged: (val) {
                    setState(
                      () {
                        _isChecked[index] = val;
                        if (_isChecked[index]) {
                          harvestTicketListChecked
                              .add(harvestTicketList[index]);
                        } else {
                          harvestTicketListChecked
                              .remove(harvestTicketList[index]);
                        }
                      },
                    );
                  },
                  secondary:
                      Icon(Linecons.note, size: 35, color: Colors.orange),
                  title: Text(harvestTicketList[index].idTicket, style: text16Bold),
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
                          child: Text(
                              "Jumlah/Berat(KG): ${harvestTicketList[index].quantity}/${formatThousandSeparator(harvestTicketList[index].weight.round())}"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                              "Kode Areal: ${harvestTicketList[index].ascendFarmerCode}"),
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
      Future<List<HarvestingTicket>> harvestTicketListFuture =
          dbHarvest.getHarvestTicketListForCollection();
      harvestTicketListFuture.then((harvestTicketList) {
        setState(() {
          this.harvestTicketList = harvestTicketList;
          _isChecked = List<bool>.filled(harvestTicketList.length, false);
        });
      });
    });
  }
}
