import 'dart:async';
import 'dart:convert';

import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/database_local/database_farmer.dart';
import 'package:e_trace_app/database_local/database_farmer_transaction.dart';
import 'package:e_trace_app/model/farmer_transaction.dart';
import 'package:e_trace_app/model/farmers.dart';
import 'package:e_trace_app/model/harvesting_ticket.dart';
import 'package:e_trace_app/screen/harvest_ticket/search_farmer_screen.dart';
import 'package:e_trace_app/utils/storage_manager.dart';
import 'package:e_trace_app/utils/time_utils.dart';
import 'package:e_trace_app/widget/back_from_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class HarvestTicketFormNew extends StatefulWidget {
  final HarvestingTicket harvestTicket;

  HarvestTicketFormNew({this.harvestTicket});

  @override
  HarvestTicketFormNewState createState() =>
      HarvestTicketFormNewState(this.harvestTicket);
}

class HarvestTicketFormNewState extends State<HarvestTicketFormNew> {
  HarvestTicketFormNewState(this.harvestTicket);

  HarvestingTicket harvestTicket;

  Farmers farmerObject;
  bool _validate = false;

  var totalJanjangController = TextEditingController();
  var weightJanjangController = TextEditingController();
  var cardNumberController = TextEditingController();
  var noteController = TextEditingController();

  String idTicket, dateTicket, gpsLat, gpsLong, name;
  bool loading = false;
  Position position;

  @override
  void initState() {
    onInitialHarvestTicketForm(harvestTicket);
    super.initState();
  }

  onInitialHarvestTicketForm(HarvestingTicket harvestingTicket) {
    generateIDTicket(harvestingTicket);
    generateDateTicket(harvestingTicket);
    getLocation(harvestingTicket);
  }

  generateIDTicket(HarvestingTicket harvestingTicket) async {
    DateTime now = DateTime.now();
    if (harvestingTicket != null) {
      idTicket = harvestingTicket.idTicket;
    } else {
      NumberFormat formatter = new NumberFormat("0000");
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String number =
          formatter.format(int.parse(prefs.getString('userSequence')));
      setState(() {
        name = prefs.getString('username');
        idTicket = "T" + TimeUtils.getIDOnTime(now) + number;
      });
    }
  }

  generateDateTicket(HarvestingTicket harvestingTicket) {
    setState(() {
      DateTime now = DateTime.now();
      harvestingTicket != null
          ? dateTicket = harvestingTicket.dateTicket
          : dateTicket = TimeUtils.getTime(now).toString();
    });
  }

  getLocation(HarvestingTicket harvestingTicket) async {
    loading = true;
    if (harvestingTicket != null) {
      gpsLat = harvestingTicket.gpsLat;
      gpsLong = harvestingTicket.gpsLong;
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
          gpsLat = "";
          gpsLong = "";
        });
      }
      loading = false;
    }
  }

  void getFarmerByID(HarvestingTicket harvestTicket) async {
    Farmers farmers = await DatabaseFarmer().selectFarmerByID(harvestTicket);
    setState(() {
      this.farmerObject = farmers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => onWillPopForm(context),
      child: Scaffold(
        appBar: AppBar(title: Text(TITLE_HARVEST_TICKET_FORM)),
        body: SingleChildScrollView(
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
                        color: Colors.orange,
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            margin: EdgeInsets.only(bottom: 20),
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Icon(Linecons.note,
                                      size: 40, color: Colors.orange),
                                ),
                                Container(
                                    child: Text(HARVEST_TICKET,
                                        style: text18Bold)),
                              ],
                            )),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(ID_HARVEST_TICKET_FORM, style: text16Bold),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 6.0, bottom: 10.0),
                              child: Text("$idTicket", style: text16Bold),
                            )
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DATE_FORM, style: text14Bold),
                            Text("$dateTicket")
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(GPS_LOCATION_FORM, style: text14Bold),
                            loading
                                ? SizedBox(
                                    height: 10.0,
                                    width: 10.0,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 1.0),
                                  )
                                : Text("$gpsLat,$gpsLong",
                                    overflow: TextOverflow.ellipsis)
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Areal (*Wajib diisi)", style: text14Bold),
                            Container(
                              child: ElevatedButton(
                                onPressed: () async {
                                  Farmers farmerNameTemp = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SearchFarmerScreen()));
                                  setState(() {
                                    if (farmerNameTemp == null) {
                                      farmerObject = farmerObject;
                                    } else {
                                      farmerObject = farmerNameTemp;
                                    }
                                  });
                                },
                                child: Icon(
                                    farmerObject == null
                                        ? Icons.add
                                        : Icons.edit,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        farmerObject != null
                            ? Table(
                                border: TableBorder.all(),
                                children: [
                                  TableRow(children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("Kode Areal",
                                          textAlign: TextAlign.center),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Petani',
                                          textAlign: TextAlign.center),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Desa',
                                          textAlign: TextAlign.center),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          "${farmerObject.ascendFarmerCode}",
                                          textAlign: TextAlign.center),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("${farmerObject.fullname}",
                                          textAlign: TextAlign.center),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("${farmerObject.address}",
                                          textAlign: TextAlign.center),
                                    )
                                  ]),
                                ],
                              )
                            : Container(),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(QUANTITY, style: text14Bold),
                            Flexible(
                              child: Container(
                                width: 100,
                                child: Padding(
                                  padding: const EdgeInsets.only(),
                                  child: TextField(
                                    maxLength: 6,
                                    onChanged: (value) {
                                      value != null
                                          ? _validate = false
                                          : _validate = true;
                                    },
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9]')),
                                      FilteringTextInputFormatter.deny(
                                          RegExp('[ ]')),
                                    ],
                                    controller: totalJanjangController,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      errorText:
                                          _validate ? 'Belum Terisi' : null,
                                      counterText: "",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        borderSide: BorderSide(width: 1),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.only(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(WEIGHT_JANJANG, style: text14Bold),
                              Flexible(
                                child: Container(
                                  width: 100,
                                  child: TextField(
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9]')),
                                      FilteringTextInputFormatter.deny(
                                          RegExp('[ ]')),
                                    ],
                                    controller: weightJanjangController,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
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
                        //   padding: const EdgeInsets.only(),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     children: [
                        //       Text(CARD_NUMBER, style: text14Bold),
                        //       Flexible(
                        //         child: Container(
                        //           width: 160,
                        //           child: TextField(
                        //               inputFormatters: [
                        //                 FilteringTextInputFormatter.deny(
                        //                     RegExp('[ ]')),
                        //                 UpperCaseTextFormatter(),
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
                          padding: const EdgeInsets.only(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Catatan", style: text14Bold),
                              Flexible(
                                child: Container(
                                  width: 160,
                                  child: TextField(
                                      keyboardType: TextInputType.text,
                                      maxLines: 3,
                                      controller: noteController,
                                      textAlign: TextAlign.center,
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
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
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
      ),
    );
  }

  addDataToDatabase(BuildContext context) {
    if (harvestTicket == null) {
      double weightTemp;
      if (weightJanjangController.text.isNotEmpty) {
        weightTemp = double.parse(weightJanjangController.text);
      } else {
        weightTemp = 0.0;
      }
      harvestTicket = HarvestingTicket(
          idTicket: idTicket,
          dateTicket: dateTicket,
          gpsLong: gpsLong ?? null,
          gpsLat: gpsLat ?? null,
          mFarmerID: farmerObject.idFarmer,
          ascendFarmerID: farmerObject.ascendFarmerId,
          ascendFarmerCode: farmerObject.ascendFarmerCode,
          weight: weightTemp,
          idCollectionTicket: null,
          idDeliveryOrderTicket: null,
          uploaded: "false",
          transferred: "false",
          createdBy: "",
          note: noteController.text,
          quantity: int.parse(totalJanjangController.text),
          nfcNumber: cardNumberController.text,
          farmerName: farmerObject.fullname,
          image: "");
    } else {
      harvestTicket.idTicket = harvestTicket.idTicket;
      harvestTicket.dateTicket = harvestTicket.dateTicket;
      harvestTicket.gpsLat = harvestTicket.gpsLat;
      harvestTicket.gpsLong = harvestTicket.gpsLong;
      harvestTicket.mFarmerID = farmerObject.idFarmer;
      harvestTicket.ascendFarmerID = farmerObject.ascendFarmerId;
      harvestTicket.ascendFarmerCode = farmerObject.ascendFarmerCode;
      harvestTicket.quantity = int.parse(totalJanjangController.text);
      harvestTicket.weight = double.parse(weightJanjangController.text);
      harvestTicket.image = "";
      harvestTicket.farmerName = farmerObject.fullname;
      harvestTicket.note = noteController.text;
      harvestTicket.createdBy = harvestTicket.createdBy;
      harvestTicket.idCollectionTicket = harvestTicket.idCollectionTicket;
      harvestTicket.idCollectionTicketOld = harvestTicket.idCollectionTicketOld;
      harvestTicket.idTicketOriginal = harvestTicket.idTicketOriginal;
      harvestTicket.nfcNumber = cardNumberController.text;
    }
    Navigator.pop(context, harvestTicket);
  }

  Future<void> resetDataFarmerTransaction() async {
    int activeYear = await StorageManager.readData("activeYear");
    int yearNow = DateTime.now().year;
    var result =
        await DatabaseFarmerTransaction().selectTRMonthByFarmer(farmerObject);
    Farmer farmerData = Farmer.fromJson(result[0]);
    Farmer farmerDataUpdate = Farmer();

    if (activeYear != yearNow) {
      farmerDataUpdate.ascendFarmerCode = farmerData.ascendFarmerCode;
      farmerDataUpdate.ascendFarmerName = farmerData.ascendFarmerName;
      farmerDataUpdate.groupingMonth = farmerData.groupingMonth;
      farmerDataUpdate.maxTonnageYear = farmerData.maxTonnageYear;
      farmerDataUpdate.trMonth = '[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]';
      farmerDataUpdate.trYear = 0;
      setState(() {});
      await DatabaseFarmerTransaction()
          .updateFarmerTransaction(farmerDataUpdate);
    }
  }

  Future<bool> checkMaxTonnage(String janjang) async {
    await resetDataFarmerTransaction();
    double totalTonnagePeriode = 0;
    double abw = await StorageManager.readData("abw");
    int useMaxTonnage = await StorageManager.readData("useMaxTonnage");
    print('cek abw : $abw');
    print('cek useMaxTonnage : $useMaxTonnage');
    var result =
        await DatabaseFarmerTransaction().selectTRMonthByFarmer(farmerObject);
    if (result.isNotEmpty) {
      int month = DateTime.now().month;
      print('cek bulan ini bulan ke : $month');
      List<int> listIndex = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

      var newMe = jsonEncode(result[0]);
      Farmer farmer = Farmer.fromJson(jsonDecode(newMe));
      var list = jsonDecode(farmer.trMonth);
      print('cek tr_month :\n$list');

      final totalTonnageYear = farmer.trYear.toDouble() / 1000;
      print('cek transaksi tahun berjalan = $totalTonnageYear');

      var chunks = [];
      var chunksIndex = [];
      var chunkSize = farmer.groupingMonth.toInt();

      for (var i = 0; i < listIndex.length; i += chunkSize) {
        chunksIndex.add(listIndex.sublist(
            i,
            i + chunkSize > listIndex.length
                ? listIndex.length
                : i + chunkSize));
      }
      print('mapping periode bulan dalam satu tahun :\n$chunksIndex');

      for (var i = 0; i < list.length; i += chunkSize) {
        chunks.add(list.sublist(
            i, i + chunkSize > list.length ? list.length : i + chunkSize));
      }
      print('mapping periode tr_month :\n$chunks');

      for (int i = 0; i < chunksIndex.length; i++) {
        if (chunksIndex[i].contains(month)) {
          totalTonnagePeriode =
              double.parse(chunks[i].reduce((a, b) => a + b).toString());
          print('total tonage per periode ${i + 1} = $totalTonnagePeriode');
        }
      }

      var totalTonnagePeriodeSum =
          (((totalTonnagePeriode + (abw * int.parse(janjang))) / 1000));
      // var maxYear = farmer.maxTonnageYear / chunkSize;
      var maxTonnagePeriode = farmer.maxTonnageYear / chunks.length;
      print('max tonage per periode : $maxTonnagePeriode');
      print('total tonage per periode (Ton) $totalTonnagePeriodeSum');

      if (useMaxTonnage == 1) {
        if (totalTonnageYear < farmer.maxTonnageYear) {
          print('cek 1 : ${totalTonnageYear < farmer.maxTonnageYear}');
          if (totalTonnagePeriodeSum < maxTonnagePeriode) {
            print('cek 2 : ${totalTonnagePeriodeSum < maxTonnagePeriode}');
            return true;
          } else {
            print('cek 2 : ${totalTonnagePeriodeSum < maxTonnagePeriode}');
            return false;
          }
        } else {
          // update database local farmer transaction
          // double estimationKg = (abw * int.parse(janjang));
          // list[month - 1] = list[month - 1] + estimationKg.toInt();
          // farmer.trMonth = list.toString();
          // DatabaseFarmerTransaction().updateFarmerTransaction(farmer);
          // var resultUpdate = await DatabaseFarmerTransaction()
          //     .selectTRMonthByFarmer(farmerObject);
          // var newUpdate = jsonEncode(resultUpdate[0]);
          // Farmer farmerUpdate = Farmer.fromJson(jsonDecode(newUpdate));
          // var listUpdate = jsonDecode(farmerUpdate.trMonth);
          // print('cek tr_month update :\n$listUpdate');
          print('cek 1 : ${totalTonnageYear < farmer.maxTonnageYear}');
          return false;
        }
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Widget _saveButton() {
    return OutlinedButton(
      onPressed: () {
        if (farmerObject == null) {
          Toast.show("Areal Belum Terisi", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        } else if (totalJanjangController.text.isEmpty) {
          setState(() {
            _validate = true;
          });
        } else {
          checkMaxTonnage(totalJanjangController.text).then((value) {
            if (value) {
              addDataToDatabase(context);
            } else {
              openWarningDialog(context,
                  "Petani ${farmerObject.fullname} \nMelebihi batas kuota tonase tahunan \nMaksimal tonase petani ${farmerObject.maxTonnageYear} ton");
            }
          });
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

  openWarningDialog(BuildContext context, String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Text("Batas Kuota Tonase Tahunan"),
            content: Text(message),
            actions: <Widget>[
              new TextButton(
                  child: new Text(
                    OK,
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  })
            ],
          );
        });
  }
}
