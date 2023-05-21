import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/database_local/database_collection_point.dart';
import 'package:e_trace_app/database_local/database_delivery_order.dart';
import 'package:e_trace_app/database_local/database_entity.dart';
import 'package:e_trace_app/database_local/database_harvest_ticket.dart';
import 'package:e_trace_app/database_local/database_helper.dart';
import 'package:e_trace_app/model/collection_point.dart';
import 'package:e_trace_app/model/delivery_order.dart';
import 'package:e_trace_app/model/farmers.dart';
import 'package:e_trace_app/model/harvesting_ticket.dart';
import 'package:e_trace_app/model/upload_collection_point.dart';
import 'package:e_trace_app/model/upload_collection_response.dart';
import 'package:e_trace_app/model/upload_delivery_order.dart';
import 'package:e_trace_app/model/upload_delivery_response.dart';
import 'package:e_trace_app/model/upload_harvest_response.dart';
import 'package:e_trace_app/model/upload_harvest_ticket.dart';
import 'package:e_trace_app/screen/home/counter_notifier.dart';
import 'package:e_trace_app/screen/home/sync_data_background.dart';
import 'package:e_trace_app/screen/home/upload_repository.dart';
import 'package:e_trace_app/screen/sync/tonnage_farmer_repository.dart';
import 'package:e_trace_app/utils/storage_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toast/toast.dart';

class UploadData {
  BuildContext context;

  UploadData(this.context);

  DatabaseHelper dbHelper = DatabaseHelper();
  DatabaseHarvestTicket dbHarvest = DatabaseHarvestTicket();
  DatabaseCollectionPoint dbCollection = DatabaseCollectionPoint();
  DatabaseDeliveryOrder dbDelivery = DatabaseDeliveryOrder();
  List<HarvestingTicket> harvestTicketList = [];
  List<HarvestingTicket> harvestTicketListCollection = [];
  List<HarvestingTicket> harvestTicketListDelivery = [];
  List<CollectionPoint> collectionPointList = [];
  List<DeliveryOrder> deliveryOrderList = [];

  onInitialUpload() {
    final Future<Database> dbFutureHarvest = dbHelper.initDb();
    dbFutureHarvest.then((database) {
      Future<List<HarvestingTicket>> harvestTicketListFuture =
          dbHarvest.getHarvestTicketListUnUploaded();
      harvestTicketListFuture.then((harvestTicketList) {
        if (harvestTicketList.isNotEmpty) {
          this.harvestTicketList = harvestTicketList;
          UploadHarvestTicket uploadHarvestTicket = UploadHarvestTicket();
          uploadHarvestTicket.harvestingTicket = harvestTicketList;
          doUploadHarvestTicketToServer(uploadHarvestTicket);
        } else {
          uploadCollectionPoint();
        }
      });
    });
  }

  doUploadHarvestTicketToServer(UploadHarvestTicket uploadHarvestTicket) async {
    String userToken = await StorageManager.readData('token');
    UploadRepository(APIEndpoint.BASE_URL).doUploadHarvestTicket(
        userToken,
        uploadHarvestTicket,
        onSuccessHarvestTicketUpload,
        onErrorHarvestTicketUpload);
  }

  onSuccessHarvestTicketUpload(UploadHarvestResponse uploadHarvestResponse) {
    for (int i = 0;
        i < uploadHarvestResponse.data!.harvestingTicket!.length;
        i++) {
      dbHarvest.updateHarvestTicketUploaded(
          uploadHarvestResponse.data!.harvestingTicket![i]);
    }
    print("Upload Harvest Ticket Success");
    context.read<CounterNotifier>().getCountUnUploadedHarvestTicket();
    Toast.show("Upload Tiket Panen Berhasil", duration: 3, gravity: 0);
    uploadCollectionPoint();
  }

  uploadCollectionPoint() {
    final Future<Database> dbFutureCollection = dbHelper.initDb();
    dbFutureCollection.then((database) {
      Future<List<CollectionPoint>> collectionPointListFuture =
          dbCollection.getCollectionPointListUnUploaded();
      collectionPointListFuture.then((collectionPointList) {
        if (collectionPointList.isNotEmpty) {
          this.collectionPointList = collectionPointList;
          UploadCollectionPoint uploadCollectionPoint = UploadCollectionPoint();
          for (int i = 0; i < collectionPointList.length; i++) {
            Future<List<HarvestingTicket>> harvestingTicketListFuture =
                dbHarvest
                    .getHarvestTicketListCollection(collectionPointList[i]);
            harvestingTicketListFuture.then((harvestingTicketList) {
              collectionPointList[i].harvestingTicket = harvestingTicketList;
              this.harvestTicketListCollection = harvestingTicketList;
              if (i == collectionPointList.length - 1) {
                uploadCollectionPoint.collectionPoint = collectionPointList;
                doUploadCollectionPointToServer(uploadCollectionPoint);
              }
            });
          }
        } else {
          uploadDeliveryOrder();
        }
      });
    });
  }

  onErrorHarvestTicketUpload(response) {
    Toast.show(response.toString(), duration: 3, gravity: 0);
    Navigator.pop(context);
    print(response);
  }

  doUploadCollectionPointToServer(
      UploadCollectionPoint uploadCollectionPoint) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userBaseUrl = prefs.getString('baseUrl');
    String? userToken = prefs.getString('token');
    UploadRepository(userBaseUrl!).doUploadCollectionPoint(
        userToken!,
        uploadCollectionPoint,
        onSuccessCollectionPointUpload,
        onErrorCollectionPointUpload);
  }

  onSuccessCollectionPointUpload(
      UploadCollectionResponse uploadCollectionResponse) {
    for (int i = 0;
        i < uploadCollectionResponse.data!.collectionPoint!.length;
        i++) {
      dbCollection.updateCollectionPointUploaded(
          uploadCollectionResponse.data!.collectionPoint![i]);
    }
    print("Upload Collection Point Success");
    context.read<CounterNotifier>().getCountUnUploadedCollectionPoint();
    Toast.show("Upload Titik Kumpul Berhasil", duration: 3, gravity: 0);
    uploadDeliveryOrder();
  }

  uploadDeliveryOrder() {
    final Future<Database> dbFutureDelivery = dbHelper.initDb();
    dbFutureDelivery.then((database) {
      Future<List<DeliveryOrder>> deliveryOrderListFuture =
          dbDelivery.getDeliveryOrderListUnUploaded();
      deliveryOrderListFuture.then((deliveryOrderList) {
        if (deliveryOrderList.isNotEmpty) {
          this.deliveryOrderList = deliveryOrderList;
          UploadDeliveryOrder uploadDeliveryOrder = UploadDeliveryOrder();
          for (int i = 0; i < deliveryOrderList.length; i++) {
            Future<List<HarvestingTicket>> harvestingTicketListFuture =
                dbHarvest.getHarvestTicketListDelivery(deliveryOrderList[i]);
            harvestingTicketListFuture.then((harvestingTicketList) {
              deliveryOrderList[i].harvestingTicket = harvestingTicketList;
              this.harvestTicketListDelivery = harvestingTicketList;
              if (i == deliveryOrderList.length - 1) {
                uploadDeliveryOrder.deliveryOrder = deliveryOrderList;
                doUploadDeliveryOrderToServer(uploadDeliveryOrder);
              }
            });
          }
        } else if (harvestTicketList.isEmpty &&
            collectionPointList.isEmpty &&
            deliveryOrderList.isEmpty) {
          Toast.show("Tidak ada data yang harus diupload",
              duration: 3, gravity: 0);
          Navigator.pop(context);
          Navigator.pop(context);
          SyncDataBackground().getDataFarmer();
          getDataTonnageFarmer();
        } else {
          Navigator.pop(context);
          Navigator.pop(context);
          SyncDataBackground().getDataFarmer();
          getDataTonnageFarmer();
        }
      });
    });
  }

  getDataTonnageFarmer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? lastSync = prefs.getString('lastSync');
    final String? userToken = prefs.getString('token');
    final String? userBaseUrl = prefs.getString('baseUrl');
    TonnageFarmerRepository(userBaseUrl!).doSyncFarmerTonnage(
        userToken!, lastSync!, onSuccessSyncFarmer, onErrorSyncFarmer);
  }

  onSuccessSyncFarmer(List<Farmers> farmers) {
    for (int i = 0; i < farmers.length; i++) {
      updateFarmer(farmers[i]);
    }
  }

  Future<int> updateFarmer(Farmers object) async {
    Database? db = await DatabaseHelper().database;
    int count = await db!.update(TABLE_FARMER, object.toJson(),
        where: '$FARMER_ID_OBJECT=?', whereArgs: [object.idFarmer]);
    return count;
  }

  onErrorSyncFarmer(response) {}

  onErrorCollectionPointUpload(response) {
    Toast.show(response.toString(), duration: 3, gravity: 0);
    Navigator.pop(context);
    print(response);
  }

  doUploadDeliveryOrderToServer(UploadDeliveryOrder uploadDeliveryOrder) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userBaseUrl = prefs.getString('baseUrl');
    String? userToken = prefs.getString('token');
    UploadRepository(userBaseUrl!).doUploadDeliveryOrder(
        userToken!,
        uploadDeliveryOrder,
        onSuccessDeliveryOrderUpload,
        onErrorDeliveryOrderUpload);
  }

  onSuccessDeliveryOrderUpload(UploadDeliveryResponse uploadDeliveryResponse) {
    print("Upload Delivery Success");
    for (int i = 0;
        i < uploadDeliveryResponse.data!.deliveryOrder!.length;
        i++) {
      dbDelivery.updateDeliveryOrderUploaded(
          uploadDeliveryResponse.data!.deliveryOrder![i]);
    }
    context.read<CounterNotifier>().getCountUnUploadedDeliveryOrder();
    Navigator.pop(context);
    Navigator.pop(context);
    Toast.show("Upload Surat Pengantar Berhasil", duration: 3, gravity: 0);
    SyncDataBackground().getDataFarmer();
  }

  onErrorDeliveryOrderUpload(response) {
    Toast.show("Upload Delivery Gagal", duration: 3, gravity: 0);
    Navigator.pop(context);
    print(response);
  }
}
