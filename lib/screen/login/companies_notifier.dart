import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/database_local/database_entity.dart';
import 'package:e_trace_app/database_local/database_helper.dart';
import 'package:e_trace_app/model/companies.dart';
import 'package:e_trace_app/screen/login/company_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toast/toast.dart';

class CompanyViewModel extends ChangeNotifier {
  String? serverUrl;

  List<DataCompanies> _myCompanies = [];

  String _myCompany = '';

  String get myCompany => _myCompany;

  List<DataCompanies> get myCompanies => _myCompanies;

  setCompany(String value) {
    _myCompany = value;
    notifyListeners();
  }

  doGetCompanyEvent(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userBaseUrl = prefs.getString('baseUrl');
    if (userBaseUrl != null) {
      CompanyRepository(userBaseUrl).doGetCompanies(
          context, _onSuccessLoginCallback, _onErrorLoginCallback);
    } else {
      Toast.show(SERVER_NOT_CONFIGURE, duration: 3, gravity: 2);
    }
  }

  _onSuccessLoginCallback(List<DataCompanies> data) async {
    for (int i = 0; i < data.length; i++) {
      insertCompanies(data[i]);
    }
    _myCompanies = data;
    notifyListeners();
  }

  Future<int> insertCompanies(DataCompanies object) async {
    Database? db = await DatabaseHelper().database;
    int count = await db!.insert(TABLE_COMPANY, object.toJson());
    return count;
  }

  _onErrorLoginCallback(BuildContext context, response) {}
}
