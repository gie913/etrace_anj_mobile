import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cron/cron.dart';
import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/database_local/database_collection_point.dart';
import 'package:e_trace_app/database_local/database_delivery_order.dart';
import 'package:e_trace_app/database_local/database_entity.dart';
import 'package:e_trace_app/database_local/database_harvest_ticket.dart';
import 'package:e_trace_app/database_local/database_helper.dart';
import 'package:e_trace_app/model/check_version_response.dart';
import 'package:e_trace_app/model/farmers.dart';
import 'package:e_trace_app/model/log_out_response.dart';
import 'package:e_trace_app/model/notification.dart';
import 'package:e_trace_app/screen/home/check_version_repository.dart';
import 'package:e_trace_app/screen/home/sync_data_background.dart';
import 'package:e_trace_app/screen/login/login_screen.dart';
import 'package:e_trace_app/screen/main/set_version_repository.dart';
import 'package:e_trace_app/screen/profile/logout_repository.dart';
import 'package:e_trace_app/screen/sync/tonnage_farmer_repository.dart';
import 'package:e_trace_app/widget/dialog_exit.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/iconic_icons.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main_notifier.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  ConnectivityResult connectionStatus = ConnectivityResult.none;
  final Connectivity connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  AppUpdateInfo updateInfo;
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();
  bool flexibleUpdateAvailable = false;
  final scaffoldState = GlobalKey();
  final controllerTopic = TextEditingController();
  bool isSubscribed = false;
  String token = '';
  static int i = 0;

  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        updateInfo = info;
        print(updateInfo.toString());
        if (updateInfo.updateAvailable == true) {
          showSnack(updateInfo.toString());
        }
      });
    }).catchError((e) {
      showSnack(e.toString());
    });
  }

  checkConnection() async {
    initConnectivity();
    _connectivitySubscription =
        connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print('Could not check connectivity status $e');
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    if (result.name == "wifi") {
      getDataFarmer();
    }
  }

  void showSnack(String text) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Text("Update Aplikasi"),
            actions: <Widget>[
              TextButton(
                  child: Text(
                    "Update Nanti",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              TextButton(
                  child: Text(
                    "Update",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    InAppUpdate.performImmediateUpdate()
                        .catchError((e) => showSnackWarning(e.toString()));
                  })
            ],
            content: SelectableText(
                "Harap update aplikasi terbaru. Klik Tombol Update"),
          );
        });
  }

  void showSnackWarning(String text) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Text("Update Aplikasi"),
            actions: <Widget>[
              TextButton(
                  child: Text(
                    "Update Nanti",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              TextButton(
                  child: Text(
                    "Update",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    InAppUpdate.performImmediateUpdate()
                        .catchError((e) => showSnack(e.toString()));
                  })
            ],
            content: SelectableText("Terjadi kesalahan harap update ulang"),
          );
        });
  }

  void showDialogNotification(
      String title, String text, String action, String url) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Text(title),
            content: Text(text),
            actions: <Widget>[
              TextButton(
                  child: Text(
                    "Ok",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    if (action == "logout") {
                      doLogoutUser();
                    } else if (action == "update_data") {
                      SyncDataBackground().getDataFarmer();
                      Navigator.pop(context);
                    } else if (action == "redirect_page") {
                      Navigator.pop(context);
                      setNotificationClicked();
                      _launchURL(url);
                    } else {
                      setNotificationClicked();
                      Navigator.pop(context);
                    }
                  })
            ],
          );
        });
  }

  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

  @override
  void initState() {
    checkConnection();
    doGetVersion(context);
    doSetVersion();
    checkForUpdate();
    checkNotification();
    super.initState();
    firebaseConfig();
    cronStart();
  }

  cronStart() async {
    final cron = Cron()
      ..schedule(Schedule.parse('*/1 * * * *'), () {
        doDeleteDataOneMonthAgo();
        print(DateTime.now());
      });
    await Future.delayed(Duration(hours: 24));
    await cron.close();
  }

  checkNotification() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String action = prefs.getString('action');
    bool clicked = prefs.getBool('clicked');
    String titleNotification = prefs.getString('title_notification');
    String messageNotification = prefs.getString('message_notification');
    String urlNotification = prefs.getString('url_notification');
    if (clicked == false) {
      showDialogNotification(
          titleNotification, messageNotification, action, urlNotification);
    }
  }

  void firebaseConfig() async {
    FirebaseMessaging.onBackgroundMessage(_messageHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      if (i % 2 == 0) {
        print("message recieved");
        NotificationModel notif =
            NotificationModel.fromJson(json.decode(json.encode(event.data)));
        print(notif.action);
        showDialogNotification(event.notification.title,
            event.notification.body, notif.action, notif.toPage);
        setNotificationArrived(event.notification.title,
            event.notification.body, notif.action, notif.toPage);
      }
      i++;
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      NotificationModel notif =
          NotificationModel.fromJson(json.decode(json.encode(message.data)));
      print(notif.action);
      print('Message clicked!');
      showDialogNotification(message.notification.title,
          message.notification.title, notif.action, notif.toPage);
      setNotificationArrived(message.notification.title,
          message.notification.title, notif.action, notif.toPage);
    });
  }

  getDataFarmer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String lastSync = prefs.getString('lastSync');
    final String userToken = prefs.getString('token');
    final String userBaseUrl = prefs.getString('baseUrl');
    TonnageFarmerRepository(userBaseUrl).doSyncFarmerTonnage(
        userToken, lastSync, onSuccessSyncFarmer, onErrorSyncFarmer);
  }

  onSuccessSyncFarmer(List<Farmers> farmers) {
    for (int i = 0; i < farmers.length; i++) {
      updateFarmer(farmers[i]);
    }
  }

  Future<int> updateFarmer(Farmers object) async {
    Database db = await DatabaseHelper().database;
    int count = await db.update(TABLE_FARMER, object.toJson(),
        where: '$FARMER_ID_OBJECT=?', whereArgs: [object.idFarmer]);
    return count;
  }

  onErrorSyncFarmer(response) {}

  setNotificationArrived(
      String title, String text, String action, String url) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('action', action);
    prefs.setString('title_notification', title);
    prefs.setString('message_notification', text);
    prefs.setString('url_notification', url);
    prefs.setBool('clicked', false);
  }

  setNotificationClicked() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('action');
    prefs.remove('title_notification');
    prefs.remove('message_notification');
    prefs.remove('url_notification');
    prefs.remove('clicked');
  }

  void doDeleteDataOneMonthAgo() {
    var date = DateTime.now();
    var newDate = new DateTime(date.year, date.month - 1, date.day);
    String formattedDate = DateFormat('yyyy-MM-dd').format(newDate);
    print("this is date $formattedDate");
    DatabaseHarvestTicket().deleteHarvestTicketOneMonthAgo(formattedDate);
    DatabaseCollectionPoint().deleteCollectionPointOneMonthAgo(formattedDate);
    DatabaseDeliveryOrder().deleteDeliveryOrderOneMonthAgo(formattedDate);
  }

  doGetVersion(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userBaseUrl = prefs.getString('baseUrl');
    if (userBaseUrl != null) {
      CheckVersionRepository(userBaseUrl).doCheckVersion(
          context, _onSuccessLoginCallback, _onErrorLoginCallback);
    }
  }

  _onSuccessLoginCallback(CheckVersionResponse checkVersionResponse) async {
    List<String> listString = checkVersionResponse.data.topics.toList();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(
        "topics", checkVersionResponse.data.topics.toString());
    print(preferences.getString("topics"));
    print("this is list string $listString");
    for (int i = 0; i < listString.length; i++) {
      String topics = listString[i].replaceAll("/topics/", "");
      FirebaseMessaging.instance.subscribeToTopic(topics);
      print("Subscribed: ${listString[i]}");
    }
    print(checkVersionResponse.data);
    print("onSuccess Check Version");
  }

  _onErrorLoginCallback(response) {}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => onWillPop(context),
      child: Consumer<MainNotifier>(builder: (context, mainNotifier, child) {
        return Scaffold(
          key: scaffoldKey,
          body: Center(
              child: mainNotifier.widgetOption
                  .elementAt(mainNotifier.selectIndex)),
          bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: Colors.orange,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(FontAwesome5.home),
                label: HOME,
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesome.tags),
                label: PRICE_PLANT,
              ),
              BottomNavigationBarItem(
                icon: Icon(Iconic.user),
                label: PROFILE,
              ),
            ],
            currentIndex: mainNotifier.selectIndex,
            onTap: mainNotifier.onItemTapped,
          ),
        );
      }),
    );
  }

  void doSetVersion() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userToken = prefs.getString('token');
    final String userBaseUrl = prefs.getString('baseUrl');
    SetVersionRepository(userBaseUrl).doSetVersion(
        userToken, onSuccessProfileCallback, onErrorProfileCallback);
  }

  onSuccessProfileCallback(String response) {}

  onErrorProfileCallback(String response) {}

  void doLogoutUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userToken = prefs.getString('token');
    final String userBaseUrl = prefs.getString('baseUrl');
    LogOutRepository(userBaseUrl)
        .doGetLogOut(userToken, onSuccessLogOutCallback, onErrorLogOutCallback);
  }

  onSuccessLogOutCallback(LogOutResponse logOutResponse) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('baseUrl');
    prefs.remove('token');
    prefs.remove('session');
    prefs.remove('lastSync');
    prefs.remove('harvesting_ticket');
    prefs.remove('collection_point');
    prefs.remove('delivery_order');
    setNotificationClicked();
    Database db = await DatabaseHelper().database;
    await db.delete(TABLE_FARMER);
    await db.delete(TABLE_SUPPLIER);
    await db.delete(TABLE_AGENT);
    await db.delete(TABLE_PRICE);
    String stringTopics = prefs.getString("topics");
    String replacedString = stringTopics.replaceAll("[", "");
    String replacedString2 = replacedString.replaceAll("]", "");
    print(replacedString);
    print("replaced 2 " + replacedString2);
    List<String> listTopics = replacedString2.split(", ");
    print(listTopics);
    for (int i = 0; i < listTopics.length; i++) {
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
}

Future<void> _messageHandler(RemoteMessage message) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  NotificationModel notif =
      NotificationModel.fromJson(json.decode(json.encode(message.data)));
  prefs.setString('action', notif.action);
  prefs.setString('title_notification', message.notification.title);
  prefs.setString('message_notification', message.notification.body);
  prefs.setString('url_notification', notif.toPage);
  prefs.setBool('clicked', false);
}
