import 'dart:async';
import 'dart:typed_data';

import 'package:e_trace_app/model/harvesting_ticket.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:e_trace_app/database_local/database_supplier.dart';
import 'package:e_trace_app/database_local/database_farmer.dart';
import 'package:e_trace_app/model/suppliers.dart';
import 'package:e_trace_app/model/farmers.dart';

class ReadDataNotifier extends ChangeNotifier {
  // StreamSubscription<NDEFMessage> _streamSubscription;
  List<HarvestingTicket> _listHarvestTicket = [];
  Uint8List _bytes = Uint8List(0);
  List<HarvestingTicket> _listHarvestTicketDO = [];
  String? _idCollection, _idDeliveryOrder, _record;
  int? _totalQuantity, _totalWeight;
  Suppliers? _suppliersObject;

  Farmers? _farmerObject;

  int? get totalQuantity => _totalQuantity;

  int? get totalWeight => _totalWeight;

  // StreamSubscription<NDEFMessage> get streamSubscription => _streamSubscription;

  List<HarvestingTicket> get listHarvestTicket => _listHarvestTicket;

  Uint8List get bytes => _bytes;

  List<HarvestingTicket> get listHarvestTicketDO => _listHarvestTicketDO;

  String? get idCollection => _idCollection;

  Suppliers? get suppliersObject => _suppliersObject;

  Farmers? get farmerObject => _farmerObject;

  String? get idDeliveryOrder => _idDeliveryOrder;

  String? get record => _record;

  List<Farmers> _listFarmerObject = [];

  List<Farmers> get listFarmerObject => _listFarmerObject;

  onInitScan() {
    _listHarvestTicket = [];
    _listHarvestTicketDO = [];
  }

  splitQRCodeHarvestTicket(String harvestTicket) async {
    _listHarvestTicketDO = [];
    _listHarvestTicket = [];
    if (harvestTicket.substring(0, 1) == "D") {
      final splitDelivery = harvestTicket.split("[");
      final valueDO = splitDelivery[0];
      final splitDO = valueDO.split(",");
      final valueID = splitDO[0];
      final valueSupplier = splitDO[1];
      final valueDriver = splitDO[2];
      final valueNumber = splitDO[3];
      final valueTicket = splitDelivery[1];
      final splitTicket = valueTicket.split("#");
      for (int i = 0; i < splitTicket.length; i++) {
        final splitTicketHarvest = splitTicket[i].split(",");
        final Map<int, String> values = {
          for (int i = 0; i < splitTicketHarvest.length; i++)
            i: splitTicketHarvest[i]
        };
        final value1 = values[0];
        final value2 = values[1];
        final value3 = values[2];
        HarvestingTicket harvestTicketNew = HarvestingTicket();
        harvestTicketNew.idTicket = valueID;
        harvestTicketNew.idCollectionTicket = valueSupplier;
        harvestTicketNew.idDeliveryOrderTicket = valueDriver;
        harvestTicketNew.dateTicket = valueNumber;
        harvestTicketNew.ascendFarmerCode = value1;
        harvestTicketNew.quantity = int.parse(value2!);
        harvestTicketNew.weight =
            double.parse(value3!.substring(0, value3.length - 1));
        getSupplierByID(valueSupplier);
        getFarmerByID(value1!);
        _listHarvestTicketDO.add(harvestTicketNew);
      }
    } else {
      final splitCollection = harvestTicket.split("#");
      for (int i = 0; i < splitCollection.length; i++) {
        print(splitCollection[i]);
        final splitTicket = splitCollection[i].split(",");
        print(splitTicket.length);
        if (splitTicket.length == 4) {
          final Map<int, String> values = {
            for (int i = 0; i < splitTicket.length; i++) i: splitTicket[i]
          };
          final value1 = values[0];
          final value2 = values[1];
          final value3 = values[2];
          final value4 = values[3];
          HarvestingTicket harvestTicket = HarvestingTicket();
          harvestTicket.idTicket = value1;
          harvestTicket.ascendFarmerCode = value2;
          harvestTicket.quantity = int.parse(value3!);
          harvestTicket.weight = double.parse(value4!);
          _listHarvestTicket.add(harvestTicket);
        } else if (splitTicket.length == 5) {
          final Map<int, String> values = {
            for (int i = 0; i < splitTicket.length; i++) i: splitTicket[i]
          };
          final value1 = values[0];
          final value2 = values[1];
          final value3 = values[2];
          final value4 = values[3];
          HarvestingTicket harvestTicket = HarvestingTicket();
          harvestTicket.idTicket = value1;
          harvestTicket.ascendFarmerCode = value2;
          harvestTicket.quantity = int.parse(value3!);
          harvestTicket.weight = double.parse(value4!);
          _listHarvestTicket.add(harvestTicket);
        } else if (splitTicket.length == 6) {
          final Map<int, String> values = {
            for (int i = 0; i < splitTicket.length; i++) i: splitTicket[i]
          };
          final value1 = values[0];
          final value2 = values[1];
          final value3 = values[2];
          final value4 = values[3];
          final value5 = values[4];
          HarvestingTicket harvestTicket = HarvestingTicket();
          harvestTicket.idTicket = value1;
          harvestTicket.ascendFarmerCode = value2;
          harvestTicket.quantity = int.parse(value3!);
          harvestTicket.weight = double.parse(value4!);
          harvestTicket.idCollectionTicket = value5;
          _listHarvestTicket.add(harvestTicket);
        }
      }
    }

    notifyListeners();
  }

  void getSupplierByID(String supplierCode) async {
    Suppliers suppliers =
        await DatabaseSupplier().selectSupplierByIDString(supplierCode);
    _suppliersObject = suppliers;
    notifyListeners();
  }

  void getFarmerByID(String farmerCode) async {
    Farmers farmers = await DatabaseFarmer().selectFarmerByIDString(farmerCode);
    _farmerObject = farmers;
    _listFarmerObject.add(farmers);
    notifyListeners();
  }

  // void startScanning(BuildContext context) {
  //   showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         title: Center(child: Text("Tempel Kartu NFC", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold))),
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
  //                 child: Text("Untuk memasukkan data", style: TextStyle(color: Colors.black, fontSize: 14)),
  //               ),
  //               OutlinedButton(
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                   stopScanning();
  //                 },
  //                 child: Container(
  //                   width: MediaQuery.of(context).size.width,
  //                   padding: EdgeInsets.all(10),
  //                   child: Center(
  //                       child: Text(
  //                         "Selesai",
  //                         style: buttonStyle16,
  //                       )),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  //   _streamSubscription = NFC
  //       .readNDEF(alertMessage: "Custom message with readNDEF#alertMessage")
  //       .listen((NDEFMessage message) {
  //     if (message.isEmpty) {
  //       Toast.show("Kartu tidak terisi", context,
  //           duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  //       return;
  //     }
  //     for (NDEFRecord record in message.records) {
  //       _record = EncryptData().decryptData(record.payload);
  //       splitQRCodeHarvestTicket(_record);
  //     }
  //   }, onError: (error) {
  //     _streamSubscription = null;
  //     if (error is NFCUserCanceledSessionException) {
  //       print("user canceled");
  //     } else if (error is NFCSessionTimeoutException) {
  //       print("session timed out");
  //     } else {
  //       print("error: $error");
  //     }
  //   }, onDone: () {
  //     _streamSubscription = null;
  //   });
  // }
  //
  // void stopScanning() {
  //   _streamSubscription?.cancel();
  //   _streamSubscription = null;
  // }
  //
  // @override
  // void dispose() {
  //   super.dispose();
  //   _streamSubscription.cancel();
  // }
  //
  // void toggleScan(BuildContext context) {
  //   if (_streamSubscription == null) {
  //     startScanning(context);
  //   } else {
  //     stopScanning();
  //   }
  // }

  Future scan() async {
    await Permission.camera.request();
    String? barcode = await scanner.scan();
    if (barcode == null) {
      print('nothing return.');
    } else {
      splitQRCodeHarvestTicket(barcode);
    }
  }
}
