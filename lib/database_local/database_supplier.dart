import 'dart:convert';
import 'package:e_trace_app/model/delivery_order.dart';
import 'package:e_trace_app/database_local/database_entity.dart';
import 'package:e_trace_app/model/suppliers.dart';
import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

class DatabaseSupplier {

  void getSupplierList(onSuccess, onError) async {
    var supplierMapList = await selectSupplier();
    int count = supplierMapList.length;
    for (var i = 0; i < count; i++) {
      var farmerJson = json.decode(json.encode(supplierMapList[i]));
      Suppliers suppliers = Suppliers.fromJson(farmerJson);
      onSuccess(suppliers);
    }
  }

  Future<List<Map<String, dynamic>>> selectSupplier() async {
    Database db = await DatabaseHelper().database;
    var mapList = await db.query(TABLE_SUPPLIER);
    print(mapList);
    return mapList;
  }

  Future<Suppliers> selectSupplierByID(DeliveryOrder object) async {
    Database db = await DatabaseHelper().database;
    Suppliers suppliers = new Suppliers();
    var mapList = await db.query(TABLE_SUPPLIER, where: '$ASCEND_SUPPLIER_CODE=?', whereArgs: [object.ascentSupplierCode]);
    for (int i = 0; i < mapList.length; i++) {
      suppliers = Suppliers.fromJson(mapList[i]);
      print(suppliers.name + suppliers.ascendSupplierCode);
    }
    return suppliers;
  }

  Future<Suppliers> selectSupplierByIDString(String object) async {
    Database db = await DatabaseHelper().database;
    Suppliers suppliers = new Suppliers();
    var mapList = await db.query(TABLE_SUPPLIER, where: '$ASCEND_SUPPLIER_CODE=?', whereArgs: [object]);
    for (int i = 0; i < mapList.length; i++) {
      suppliers = Suppliers.fromJson(mapList[i]);
      print(suppliers.name + suppliers.ascendSupplierCode);
    }
    return suppliers;
  }
}
