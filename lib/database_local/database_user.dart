import 'dart:convert';

import 'package:e_trace_app/database_local/database_helper.dart';
import 'package:e_trace_app/model/user.dart';
import 'package:sqflite/sqflite.dart';

import 'database_entity.dart';

class DatabaseUser {

  void getUser(onSuccess, onError) async {
    var userList = await selectUser();
    var priceJson = json.decode(json.encode(userList.last));
    User user = User.fromJson(priceJson);
    onSuccess(user);
  }

  Future<List<Map<String, dynamic>>> selectUser() async {
    Database db = await DatabaseHelper().database;
    var mapList = await db.query(TABLE_USER);
    return mapList;
  }
}