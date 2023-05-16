import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/database_local/database_entity.dart';
import 'package:e_trace_app/database_local/database_helper.dart';
import 'package:e_trace_app/model/data_price.dart';
import 'package:e_trace_app/model/login_response.dart';
import 'package:e_trace_app/model/user.dart';
import 'package:e_trace_app/screen/sync/sync_data_screen.dart';
import 'package:e_trace_app/widget/loading_dialog.dart';
import 'package:e_trace_app/widget/warning_dialog.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toast/toast.dart';

import 'login_repository.dart';

class LoginVieModel extends ChangeNotifier {
  String serverUrl;

  doLoginEvent(BuildContext context, String email, String password,
      String companyId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userBaseUrl = prefs.getString('baseUrl');
    String token = prefs.getString('token');
    print(token);
    if (userBaseUrl != null) {
      loadingDialog(context);
      LoginRepository(APIEndpoint.BASE_URL).doPostLogin(context, email, password,
          _onSuccessLoginCallback, _onErrorLoginCallback);
    } else {
      Toast.show(SERVER_NOT_CONFIGURE, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    }
  }

  _onSuccessLoginCallback(BuildContext context, Data data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', data.token);
    prefs.setString('userSequence', data.user.sequenceNumber.toString());
    prefs.setString('userPT', data.user.companyName);
    prefs.setString('name', data.user.name);
    prefs.setString('username', data.user.username);
    prefs.setString('idUser', data.user.id);
    await Permission.camera.request();
    await Permission.location.request();
    int result = await insertUser(data.user);
    if (result > 0) {
      for (int i = 0; i < data.access.length; i++) {
        prefs.setString('${data.access[i].mModuleId}', data.access[i].canCreate.toString());
      }
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SyncDataScreen()));
    }
  }

  Future<int> insertUser(User object) async {
    Database db = await DatabaseHelper().database;
    User user = User();
    user.id = object.id;
    user.name = object.name;
    user.email = object.email;
    user.mRoleId = object.mRoleId;
    user.username = object.username;
    user.address = object.address;
    user.companyName = object.companyName;
    user.mCompanyId = object.mCompanyId;
    user.sequenceNumber = object.sequenceNumber;
    user.phoneNumber = object.phoneNumber;
    int count = await db.insert(TABLE_USER, user.toJson());
    return count;
  }

  _onErrorLoginCallback(BuildContext context, response) {
    openWarningDialog(context, response);
  }

  // void doGetPrice() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final String userToken = prefs.getString('token');
  //   final String userBaseUrl = prefs.getString('baseUrl');
  //   PriceRepository(userBaseUrl)
  //       .doGetPrice(userToken, onSuccessPriceCallback, onErrorPriceCallback);
  // }
  //
  // onSuccessPriceCallback(PriceResponse priceResponse) {
  //   List<DataPrice> listData = [];
  //   listData = List.from(priceResponse.data.reversed);
  //   for (int i = 0; i < listData.length; i++) {
  //     insertPrice(listData[i]);
  //   }
  // }
  //
  // onErrorPriceCallback(response) {}

  Future<int> insertPrice(DataPrice object) async {
    DataPrice dataPrice = DataPrice();
    dataPrice.id = object.id;
    dataPrice.dayIna = object.dayIna;
    dataPrice.date = object.date;
    dataPrice.priceSmall = object.priceSmall;
    dataPrice.priceMedium = object.priceMedium;
    dataPrice.priceLarge = object.priceLarge;
    dataPrice.mainCurrency = object.mainCurrency;
    dataPrice.mCompanyId = object.mCompanyId;
    Database db = await DatabaseHelper().database;
    int count = await db.insert(TABLE_PRICE, dataPrice.toJson());
    return count;
  }
}
