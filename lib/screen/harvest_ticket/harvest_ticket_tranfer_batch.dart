import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/database_local/database_harvest_ticket.dart';
import 'package:e_trace_app/database_local/database_helper.dart';
import 'package:e_trace_app/model/harvesting_ticket.dart';
import 'package:e_trace_app/model/transfer_response.dart';
import 'package:e_trace_app/model/user.dart';
import 'package:e_trace_app/screen/harvest_ticket/send_harvest_ticket.dart';
import 'package:e_trace_app/screen/harvest_ticket/transfer_harvest_ticket.dart';
import 'package:e_trace_app/screen/harvest_ticket/transfer_repository.dart';
import 'package:e_trace_app/utils/separator_thousand.dart';
import 'package:e_trace_app/widget/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toast/toast.dart';

class HarvestTicketTransferBatch extends StatefulWidget {
  @override
  _HarvestTicketTransferBatchState createState() =>
      _HarvestTicketTransferBatchState();
}

class _HarvestTicketTransferBatchState
    extends State<HarvestTicketTransferBatch> {
  DatabaseHelper dbHelper = DatabaseHelper();
  DatabaseHarvestTicket dbHarvest = DatabaseHarvestTicket();
  List<HarvestingTicket> harvestTicketList = [];
  List<HarvestingTicket> harvestTicketListChecked = [];
  String? farmerName, farmerAddress, farmerNumber;
  List<bool>? _isChecked;
  User? userTarget;

  @override
  void initState() {
    updateListView();

    super.initState();
  }

  Future<bool> _willPopCallback() async {
    Navigator.pop(context, true);
    return true; // return true if the route to be popped
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        appBar: AppBar(
          title: Text("List Tiket Panen"),
          actions: [
            InkWell(
              onTap: () {
                transferDialog();
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Icon(Icons.send_outlined),
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
                  value: _isChecked![index],
                  onChanged: (val) {
                    setState(
                      () {
                        _isChecked![index] = val!;
                        if (_isChecked![index]) {
                          harvestTicketListChecked
                              .add(harvestTicketList[index]);
                          print(harvestTicketListChecked.length);
                        } else {
                          harvestTicketListChecked
                              .remove(harvestTicketList[index]);
                        }
                      },
                    );
                  },
                  secondary:
                      Icon(Linecons.note, size: 35, color: Colors.orange),
                  title: Text(harvestTicketList[index].idTicket!,
                      style: text16Bold),
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
                              "Jumlah/Berat(KG): ${harvestTicketList[index].quantity}/${formatThousandSeparator(harvestTicketList[index].weight.round())}"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                              "CP: ${harvestTicketList[index].idCollectionTicket}"),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Card(
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(userTarget == null
                              ? "Tujuan Pengiriman"
                              : "${userTarget!.name}"),
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
                                    builder: (context) => SendHarvestTicket()));
                            Navigator.pop(context);
                            setState(() {
                              userTarget = userTargetTemp;
                              transferDialog();
                            });
                          },
                          child: Container(
                            child: Icon(Icons.search),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton(
                    onPressed: () {
                      doTransferTicket();
                    },
                    child: Container(
                      child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text("Kirim", style: buttonStyle16)),
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

  void doTransferTicket() async {
    if (userTarget != null) {
      loadingDialog(context);
      List<HarvestingTicket> listHarvest = [];
      TransferHarvestingTicketBody transferBody =
          TransferHarvestingTicketBody();
      if (harvestTicketListChecked.isNotEmpty) {
        for (int i = 0; i < harvestTicketListChecked.length; i++) {
          HarvestingTicket harvestingTicket = HarvestingTicket();
          harvestingTicket = harvestTicketListChecked[i];
          harvestingTicket.quantity =
              harvestTicketListChecked[i].quantity!.toInt();
          harvestingTicket.userTargetId = userTarget!.id;
          listHarvest.add(harvestingTicket);
        }
        transferBody.harvestingTicket = listHarvest;
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? userToken = prefs.getString('token');
        final String? userBaseUrl = prefs.getString('baseUrl');
        TransferRepository(userBaseUrl!).doTransferTicket(transferBody,
            userToken!, onSuccessTransferCallback, onErrorTransferCallback);
      } else {
        Toast.show("Tujuan Belum Tiket Dipilih", duration: 3, gravity: 0);
      }
    } else {
      Toast.show("Tujuan Belum Ada", duration: 3, gravity: 0);
    }
  }

  onSuccessTransferCallback(TransferResponse transferResponse) {
    setState(() {
      for (int i = 0; i < harvestTicketListChecked.length; i++) {
        harvestTicketListChecked[i].transferred = "true";
        updateHarvestTicket(harvestTicketListChecked[i]);
      }
    });
    Navigator.pop(context);
    Navigator.pop(context);
    updateListView();
    Toast.show("Berhasil terkirim", duration: 3, gravity: 0);
  }

  void updateHarvestTicket(HarvestingTicket object) async {
    DatabaseHarvestTicket dbHarvest = DatabaseHarvestTicket();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString('username');
    object.createdBy = user;
    int result = await dbHarvest.updateHarvestTicket(object);
    print(result);
  }

  onErrorTransferCallback(response) {
    Toast.show(response.toString(), duration: 3, gravity: 0);
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
