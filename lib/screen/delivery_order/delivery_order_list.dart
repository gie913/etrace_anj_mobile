import 'dart:async';

import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/database_local/database_collection_point.dart';
import 'package:e_trace_app/database_local/database_delivery_order.dart';
import 'package:e_trace_app/database_local/database_harvest_ticket.dart';
import 'package:e_trace_app/database_local/database_helper.dart';
import 'package:e_trace_app/model/delivery_order.dart';
import 'package:e_trace_app/screen/home/counter_notifier.dart';
import 'package:e_trace_app/widget/loading_widget.dart';
import 'package:e_trace_app/widget/qr_code_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'delivery_order_detail.dart';
import 'delivery_order_form.dart';

class DeliveryOrderScreen extends StatefulWidget {
  @override
  DeliveryOrderScreenState createState() => DeliveryOrderScreenState();
}

class DeliveryOrderScreenState extends State<DeliveryOrderScreen> {
  DatabaseHelper dbHelper = DatabaseHelper();
  DatabaseDeliveryOrder dbDelivery = DatabaseDeliveryOrder();
  List<DeliveryOrder> deliveryOrderList = [];
  List<DeliveryOrder> deliveryOrderListSearch = [];
  TextEditingController deliveryController = TextEditingController();
  String farmerName, farmerAddress, farmerNumber;
  String message;
  bool loading;

  @override
  void initState() {
    updateListView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(DELIVERY_ORDER),
          actions: [
            InkWell(
              onTap: () async {
                var deliveryOrder = await navigateToEntryForm(context, null);
                if (deliveryOrder != null) addDeliveryOrder(deliveryOrder);
              },
              child: Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Icon(Typicons.doc_add),
              ),
            )
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
                      controller: deliveryController,
                      decoration: InputDecoration(
                          hintText: SEARCH, border: InputBorder.none),
                      onChanged: onSearchTextChanged,
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.cancel),
                      onPressed: () {
                        deliveryController.clear();
                        onSearchTextChanged('');
                      },
                    ),
                  ),
                ),
              ),
            ),
            Text("Jumlah Surat Pengantar: ${deliveryOrderList.length}"),
            Divider(),
            loading
                ? loadingWidget()
                : deliveryOrderList.length != 0
                    ? Flexible(
                        child: deliveryOrderListSearch.length != 0 ||
                                deliveryController.text.isNotEmpty
                            ? createListViewSearch()
                            : createListView())
                    : Flexible(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Linecons.truck,
                                size: 80,
                                color: Colors.blue,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Text(
                                  EMPTY_DELIVERY_ORDER,
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

  Future<DeliveryOrder> navigateToDetail(
      BuildContext context, DeliveryOrder deliveryOrder) async {
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return DeliveryOrderDetail(deliveryOrder: deliveryOrder);
    }));
    return result;
  }

  Future<DeliveryOrder> navigateToEntryForm(
      BuildContext context, DeliveryOrder deliveryOrder) async {
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return DeliveryOrderForm(deliveryOrder: deliveryOrder);
    }));
    return result;
  }

  Container createListView() {
    return Container(
      child: ListView.builder(
        itemCount: deliveryOrderList.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Linecons.truck,
                      size: 40,
                      color: Colors.blue,
                    ),
                    trailing: Column(
                      children: [
                        (deliveryOrderList[index].transferred == "true")
                            ? Container(width: 10)
                            : GestureDetector(
                                child: Icon(Linecons.trash),
                                onTap: () {
                                  showDeleteDialog(
                                      context, deliveryOrderList[index]);
                                },
                              ),
                        (deliveryOrderList[index].transferred == "true")
                            ? Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text(
                                  "transfer ✓",
                                  style: TextStyle(color: Colors.green),
                                ),
                              )
                            : Container(width: 0)
                      ],
                    ),
                    title: Text(
                      deliveryOrderList[index].idDelivery,
                      style: text16Bold,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(DATE_TICKET_TILE +
                              deliveryOrderList[index].dateDelivery.toString()),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Supplier: ${deliveryOrderList[index].ascentSupplierCode}",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text("Nama Supplier: " +
                                "${deliveryOrderList[index].supplierName}"),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Supir: " +
                                  "${deliveryOrderList[index].driverName}",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () async {
                      var contact = await navigateToDetail(
                          context, deliveryOrderList[index]);
                      if (contact != null) editDeliveryOrder(contact);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Container createListViewSearch() {
    return Container(
      child: ListView.builder(
        itemCount: deliveryOrderListSearch.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Linecons.truck,
                      size: 40,
                      color: Colors.blue,
                    ),
                    trailing: Column(
                      children: [
                        (deliveryOrderListSearch[index].transferred == "true")
                            ? Container(width: 10)
                            : GestureDetector(
                          child: Icon(Linecons.trash),
                          onTap: () {
                            showDeleteDialog(
                                context, deliveryOrderListSearch[index]);
                          },
                        ),
                        (deliveryOrderListSearch[index].transferred == "true")
                            ? Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            "transfer ✓",
                            style: TextStyle(color: Colors.green),
                          ),
                        )
                            : Container(width: 0)
                      ],
                    ),
                    title: Text(
                      deliveryOrderListSearch[index].idDelivery,
                      style: text16Bold,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(DATE_TICKET_TILE +
                              deliveryOrderListSearch[index]
                                  .dateDelivery
                                  .toString()),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text("Supplier: " +
                                "${deliveryOrderListSearch[index].ascentSupplierCode}"),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text("Nama Supplier: " +
                                "${deliveryOrderListSearch[index].supplierName}"),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Supir: " +
                                  "${deliveryOrderListSearch[index].driverName}",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () async {
                      var contact = await navigateToDetail(
                          context, deliveryOrderListSearch[index]);
                      if (contact != null) editDeliveryOrder(contact);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  showQRCodeDialog(BuildContext context, String message) {
    AlertDialog alert = AlertDialog(
        title: Center(child: Text(YOUR_QRCODE)),
        content: QRCodeDialog(
          message: message,
        ));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showNFCDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
        title: Center(child: Text(TAP_NFC)),
        content: Container(
          height: 200,
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 150,
                  child: Image.asset("assets/tap-nfc.jpg"),
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

  showDeleteDialog(BuildContext context, DeliveryOrder object) {
    Widget cancelButton = TextButton(
      child: Text("Tidak", style: TextStyle(color: Colors.blue)),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Iya", style: TextStyle(color: Colors.red)),
      onPressed: () {
        deleteDeliveryOrder(object);
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

  void addDeliveryOrder(DeliveryOrder object) async {
    int result = await dbDelivery.insertDeliveryOrder(object);
    if (result > 0) {
      updateListView();
    }
  }

  void editDeliveryOrder(DeliveryOrder object) async {
    int result = await dbDelivery.updateDeliveryOrder(object);
    if (result > 0) {
      updateListView();
    }
  }

  void deleteDeliveryOrder(DeliveryOrder object) async {
    deliveryOrderListSearch.remove(object);
    int result = await dbDelivery.deleteDeliveryOrder(object);
    if (result > 0) {
      DatabaseHarvestTicket().updateHarvestTicketDeliveryDelete(object.idDelivery);
      DatabaseCollectionPoint()
          .updateCollectionPointDeliveryDelete(object.idDelivery);
      updateListView();
    }
  }

  onSearchTextChanged(String text) async {
    deliveryOrderListSearch.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    deliveryOrderList.forEach((collectionDetail) {
      if (collectionDetail.dateDelivery
              .toString()
              .toLowerCase()
              .contains(text.toLowerCase()) ||
          collectionDetail.ascentSupplierCode
              .toString()
              .toLowerCase()
              .contains(text.toLowerCase()) ||
          collectionDetail.idDelivery
              .toString()
              .toLowerCase()
              .contains(text.toLowerCase()) ||
          collectionDetail.supplierName
              .toString()
              .toLowerCase()
              .contains(text.toLowerCase()))
        deliveryOrderListSearch.add(collectionDetail);
    });
    setState(() {});
  }

  void updateListView() {
    loading = true;
    context.read<CounterNotifier>().getCountUnUploadedDeliveryOrder();
    context.read<CounterNotifier>().getCountUnUploadedHarvestTicket();
    context.read<CounterNotifier>().getCountUnUploadedCollectionPoint();
    final Future<Database> dbFuture = dbHelper.initDb();
    dbFuture.then((database) {
      Future<List<DeliveryOrder>> deliveryOrderListFuture =
          dbDelivery.getDeliveryOrderList();
      deliveryOrderListFuture.then((deliveryOrderList) {
        setState(() {
          this.deliveryOrderList = deliveryOrderList.reversed.toList();
          loading = false;
        });
      });
    });
  }
}
