import 'dart:convert';

import 'package:e_trace_app/database_local/database_entity.dart';
import 'package:e_trace_app/model/data_price.dart';
import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

class DatabasePrice {

  void getPrice(onSuccess, onError) async {
    var priceList = await selectPrice();
    int count = priceList.length;
    for (var i = 0; i < count; i++) {
      var priceJson = json.decode(json.encode(priceList[i]));
      DataPrice price = DataPrice.fromJson(priceJson);
      onSuccess(price);
    }
  }

  Future<List<Map<String, dynamic>>> selectPrice() async {
    Database db = await DatabaseHelper().database;
    var mapList = await db.query(TABLE_PRICE);
    return mapList;
  }
}