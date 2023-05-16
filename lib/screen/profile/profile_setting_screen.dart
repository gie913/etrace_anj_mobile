import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/base/ui/palette.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/database_local/database_collection_point.dart';
import 'package:e_trace_app/database_local/database_delivery_order.dart';
import 'package:e_trace_app/database_local/database_entity.dart';
import 'package:e_trace_app/database_local/database_harvest_ticket.dart';
import 'package:e_trace_app/database_local/database_helper.dart';
import 'package:e_trace_app/model/collection_point.dart';
import 'package:e_trace_app/model/delivery_order.dart';
import 'package:e_trace_app/model/harvesting_ticket.dart';
import 'package:e_trace_app/model/log_out_response.dart';
import 'package:e_trace_app/model/upload_collection_point.dart';
import 'package:e_trace_app/model/upload_collection_response.dart';
import 'package:e_trace_app/model/upload_delivery_order.dart';
import 'package:e_trace_app/model/upload_delivery_response.dart';
import 'package:e_trace_app/model/upload_harvest_response.dart';
import 'package:e_trace_app/model/upload_harvest_ticket.dart';
import 'package:e_trace_app/screen/change_password/change_password.dart';
import 'package:e_trace_app/screen/home/counter_notifier.dart';
import 'package:e_trace_app/screen/home/upload_repository.dart';
import 'package:e_trace_app/screen/login/login_screen.dart';
import 'package:e_trace_app/utils/theme_manager.dart';
import 'package:e_trace_app/widget/loading_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toast/toast.dart';

import 'logout_repository.dart';

class ProfileSettingScreen extends StatefulWidget {
  @override
  _ProfileSettingScreenState createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {

  DatabaseHelper dbHelper = DatabaseHelper();
  DatabaseHarvestTicket dbHarvest = DatabaseHarvestTicket();
  DatabaseCollectionPoint dbCollection = DatabaseCollectionPoint();
  DatabaseDeliveryOrder dbDelivery = DatabaseDeliveryOrder();
  List<HarvestingTicket> harvestTicketList = [];
  List<HarvestingTicket> harvestTicketListCollection = [];
  List<HarvestingTicket> harvestTicketListDelivery = [];
  List<CollectionPoint> collectionPointList = [];
  List<DeliveryOrder> deliveryOrderList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, theme, child) => Scaffold(
        appBar: AppBar(
          title: Center(child: Text(PROFILE_SETTING)),
        ),
        body: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Mode Gelap", style: text14Bold),
                      Flexible(
                        child: Switch(
                          activeColor: primaryColor,
                          value: theme.status ?? true,
                          onChanged: (value) {
                            if (value != null) {
                              value ? theme.setDarkMode() : theme.setLightMode();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChangePasswordScreen()));
                },
                child: Container(
                  padding: EdgeInsets.only(left: 6, right: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(CHANGE_PASSWORD, style: text14Bold),
                        Icon(Icons.edit_sharp)
                      ],
                    ),
                  ),
                ),
              ),
              Divider(),
              InkWell(
                onTap: () {
                  showLogOutDialog(context);
                },
                child: Container(
                  padding: EdgeInsets.only(left: 6, right: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(LOG_OUT, style: text14Bold),
                        Icon(Icons.exit_to_app)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void doLogoutUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userToken = prefs.getString('token');
    final String userBaseUrl = prefs.getString('baseUrl');
    LogOutRepository(userBaseUrl)
        .doGetLogOut(userToken, onSuccessLogOutCallback, onErrorLogOutCallback);
  }

  onSuccessLogOutCallback(LogOutResponse logOutResponse) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('session');
    prefs.remove('lastSync');
    prefs.remove('baseUrl');
    prefs.remove('harvesting_ticket');
    prefs.remove('collection_point');
    prefs.remove('delivery_order');
    Database db = await DatabaseHelper().database;
    await db.delete(TABLE_FARMER);
    await db.delete(TABLE_SUPPLIER);
    await db.delete(TABLE_AGENT);
    await db.delete(TABLE_PRICE);
    String stringTopics = prefs.getString("topics");
    String replacedString = stringTopics.replaceAll("[", "");
    String replacedString2 = replacedString.replaceAll("]", "");
    List<String> listTopics = replacedString2.split(", ");
    print(listTopics);
    for(int i = 0; i < listTopics.length; i++) {
      String topics = listTopics[i].replaceAll("/topics/", "");
      print(topics);
      FirebaseMessaging.instance.unsubscribeFromTopic(topics);
      print("unsubscribed: ${listTopics[i]}");
    }
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  onErrorLogOutCallback(response) {
    openWarningDialogLogOut(context, response);
  }

  openWarningDialogLogOut(BuildContext context, String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Text("Log Out Gagal"),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                  child: Text(
                    OK,
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  })
            ],
          );
        }).then((val) {
      Navigator.pop(context);
    });
  }

  showLogOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LOG_OUT),
          content: Text(LOG_OUT_DIALOG),
          actions: [
            TextButton(
              child: Text(YES,
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.pop(context);
                onInitialCheckTransaction();
              },
            ),
            TextButton(
              child: Text(NO,
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  onInitialCheckTransaction() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('username');
    DatabaseHarvestTicket().checkHarvestTicketNoTransaction(user).then((value) {
      if(value == true) {
        Toast.show("Ada tiket panen belum selesai transaksi", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      } else {
        DatabaseCollectionPoint().checkCollectionPointNoTransaction(user).then((value) {
          if(value == true) {
            Toast.show("Ada titik kumpul belum selesai transaksi", context,
                duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          } else {
            DatabaseDeliveryOrder().checkCollectionPointNoTransaction(user).then((value) {
              if(value == true) {
                Toast.show("Ada surat pengantar belum selesai transaksi", context,
                    duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
              } else {
                onInitialUpload();
              }
            });
          }
        });
      }
    });
  }

  onInitialUpload() {
    loadingDialog(context);
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
        } else{
          uploadCollectionPoint();
        }
      });
    });
  }

  doUploadHarvestTicketToServer(UploadHarvestTicket uploadHarvestTicket) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userBaseUrl = prefs.getString('baseUrl');
    final String userToken = prefs.getString('token');
    UploadRepository(userBaseUrl).doUploadHarvestTicket(
        userToken,
        uploadHarvestTicket,
        onSuccessHarvestTicketUpload,
        onErrorHarvestTicketUpload);
  }

  onSuccessHarvestTicketUpload(UploadHarvestResponse uploadHarvestResponse) {
    context.read<CounterNotifier>().getCountUnUploadedHarvestTicket();
    for (int i = 0;
    i < uploadHarvestResponse.data.harvestingTicket.length;
    i++) {
      dbHarvest.updateHarvestTicketUploaded(
          uploadHarvestResponse.data.harvestingTicket[i]);
    }
    print("Upload Harvest Ticket Success");
    Toast.show("Upload Tiket Panen Berhasil", context,
        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
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
              if (i == collectionPointList.length-1) {
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
    Navigator.pop(context);
    Toast.show("Upload Tiket Panen Gagal", context,
        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    print(response);
  }

  doUploadCollectionPointToServer(
      UploadCollectionPoint uploadCollectionPoint) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userBaseUrl = prefs.getString('baseUrl');
    final String userToken = prefs.getString('token');
    UploadRepository(userBaseUrl).doUploadCollectionPoint(
        userToken,
        uploadCollectionPoint,
        onSuccessCollectionPointUpload,
        onErrorCollectionPointUpload);
  }

  onSuccessCollectionPointUpload(
      UploadCollectionResponse uploadCollectionResponse) {
    context.read<CounterNotifier>().getCountUnUploadedCollectionPoint();
    for (int i = 0;
    i < uploadCollectionResponse.data.collectionPoint.length;
    i++) {
      dbCollection.updateCollectionPointUploaded(
          uploadCollectionResponse.data.collectionPoint[i]);
    }
    print("Upload Collection Point Success");
    Toast.show("Upload Titik Kumpul Berhasil", context,
        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
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
              if (i == deliveryOrderList.length-1) {
                uploadDeliveryOrder.deliveryOrder = deliveryOrderList;
                doUploadDeliveryOrderToServer(uploadDeliveryOrder);
              }
            });
          }
        } else if (harvestTicketList.isEmpty && collectionPointList.isEmpty && deliveryOrderList.isEmpty) {
          Toast.show("Tidak ada data yang harus diupload", context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          doLogoutUser();
        } else {
          doLogoutUser();
        }
      });
    });
  }

  onErrorCollectionPointUpload(response) {
    Toast.show("Upload Titik Kumpul Gagal", context,
        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    Navigator.pop(context);
    print(response);
  }

  doUploadDeliveryOrderToServer(UploadDeliveryOrder uploadDeliveryOrder) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userBaseUrl = prefs.getString('baseUrl');
    final String userToken = prefs.getString('token');
    UploadRepository(userBaseUrl).doUploadDeliveryOrder(
        userToken,
        uploadDeliveryOrder,
        onSuccessDeliveryOrderUpload,
        onErrorDeliveryOrderUpload);
  }

  onSuccessDeliveryOrderUpload(UploadDeliveryResponse uploadDeliveryResponse) {
    context.read<CounterNotifier>().getCountUnUploadedDeliveryOrder();
    print("Upload Delivery Success");
    for (int i = 0; i < uploadDeliveryResponse.data.deliveryOrder.length; i++) {
      dbDelivery.updateDeliveryOrderUploaded(
          uploadDeliveryResponse.data.deliveryOrder[i]);
    }
    Toast.show("Upload Surat Pengantar Berhasil", context,
        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    doLogoutUser();
  }

  onErrorDeliveryOrderUpload(response) {
    Toast.show("Upload Delivery Gagal", context,
        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    Navigator.pop(context);
    print(response);
  }
}
