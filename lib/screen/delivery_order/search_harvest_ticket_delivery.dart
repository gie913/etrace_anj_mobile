import 'dart:async';

import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/database_local/database_harvest_ticket.dart';
import 'package:e_trace_app/database_local/database_helper.dart';
import 'package:e_trace_app/model/harvesting_ticket.dart';
import 'package:e_trace_app/screen/harvest_ticket/harvest_ticket_form.dart';
import 'package:e_trace_app/utils/separator_thousand.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class SearchHarvestTicketDelivery extends StatefulWidget {
  @override
  SearchHarvestTicketDeliveryState createState() =>
      SearchHarvestTicketDeliveryState();
}

class SearchHarvestTicketDeliveryState
    extends State<SearchHarvestTicketDelivery> {
  DatabaseHelper dbHelper = DatabaseHelper();
  DatabaseHarvestTicket dbHarvest = DatabaseHarvestTicket();
  List<HarvestingTicket> harvestTicketList = [];
  List<HarvestingTicket> harvestTicketListChecked = [];
  String? farmerName, farmerAddress, farmerNumber;
  List<bool>? _isChecked;

  @override
  void initState() {
    updateListView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        body: Column(
          children: [
            Container(
              width: 200,
              margin: EdgeInsets.all(10),
              child: OutlinedButton(
                onPressed: () async {
                  var result = await Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return HarvestTicketForm();
                  }));
                  if (result != null) {
                    addHarvestTicket(result);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Buat Tiket Panen Baru",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Flexible(
              child: harvestTicketList.length != 0
                  ? createListView()
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Linecons.note,
                            size: 60,
                            color: Colors.orange,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Text(
                              "Belum ada tiket panen",
                              style: text16,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ));
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
                  value: _isChecked![index],
                  onChanged: (val) {
                    setState(
                      () {
                        _isChecked![index] = val!;
                        if (_isChecked![index]) {
                          harvestTicketListChecked
                              .add(harvestTicketList[index]);
                        } else {
                          harvestTicketListChecked
                              .remove(harvestTicketList[index]);
                        }
                      },
                    );
                  },
                  secondary: Icon(
                    Linecons.note,
                    size: 35,
                    color: Colors.orange,
                  ),
                  title: Text(
                    harvestTicketList[index].idTicket!,
                    style: text16Bold,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DATE_TICKET_TILE +
                            harvestTicketList[index].dateTicket!),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                              "Kode Areal: ${harvestTicketList[index].ascendFarmerCode}"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                              "Jumlah/Berat(Kg): ${harvestTicketList[index].quantity} / ${formatThousandSeparator(harvestTicketList[index].weight.round())}"),
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
          dbHarvest.getHarvestTicketListForDelivery();
      harvestTicketListFuture.then((harvestTicketList) {
        setState(() {
          this.harvestTicketList = harvestTicketList;
          _isChecked = List<bool>.filled(harvestTicketList.length, false);
        });
      });
    });
  }

  void addHarvestTicket(HarvestingTicket object) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString('username');
    object.createdBy = user;
    int result = await dbHarvest.insertHarvestTicket(object);
    if (result > 0) {
      updateListView();
    }
  }
}
