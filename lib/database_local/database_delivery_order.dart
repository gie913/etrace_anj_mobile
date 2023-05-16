import 'package:e_trace_app/database_local/database_entity.dart';
import 'package:e_trace_app/model/delivery_order.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

class DatabaseDeliveryOrder {
  Future<List<Map<String, dynamic>>> selectDeliveryOrder(String user) async {
    Database db = await DatabaseHelper().database;
    var mapList = await db.rawQuery(
        "SELECT * FROM $TABLE_DELIVERY_ORDER where $DELIVERY_CREATED_BY=? ORDER BY $DO_TRANSFERRED DESC, strftime('%y-%M-%d %H:%m', $DATE_DELIVERY) DESC",
        [user]);
    return mapList;
  }

  Future<List<Map<String, dynamic>>> selectDeliveryOrderUnUpload(
      String user) async {
    Database db = await DatabaseHelper().database;
    var mapList = await db.query(TABLE_DELIVERY_ORDER,
        where: "$DO_UPLOADED=?", whereArgs: ["false"]);
    return mapList;
  }

  Future<int> selectDeliveryOrderCountUnUpload() async {
    Database db = await DatabaseHelper().database;
    var mapList = await db.query(TABLE_DELIVERY_ORDER,
        where: "$DO_UPLOADED=?", whereArgs: ["false"]);
    int count = mapList.length;
    return count;
  }

  Future<int> insertDeliveryOrder(DeliveryOrder object) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('username');
    object.createdBy = user;
    Database db = await DatabaseHelper().database;
    int count = await db.insert(TABLE_DELIVERY_ORDER, object.toJson());
    return count;
  }

  Future<int> updateDeliveryOrder(DeliveryOrder object) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('username');
    object.createdBy = user;
    Database db = await DatabaseHelper().database;
    int count = await db.update(TABLE_DELIVERY_ORDER, object.toJson(),
        where: '$ID_DELIVERY=?', whereArgs: [object.idDelivery]);
    return count;
  }

  Future<int> deleteDeliveryOrder(DeliveryOrder object) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('username');
    object.createdBy = user;
    Database db = await DatabaseHelper().database;
    int count = await db.delete(TABLE_DELIVERY_ORDER,
        where: '$ID_DELIVERY=?', whereArgs: [object.idDelivery]);
    return count;
  }

  Future<int> deleteDeliveryOrderOneMonthAgo(String dateDelivery) async {
    Database db = await DatabaseHelper().database;
    int count = await db.rawDelete(
        'DELETE FROM $TABLE_DELIVERY_ORDER WHERE $DATE_DELIVERY <= ? AND $DO_UPLOADED = ?',
        ['$dateDelivery%', 'true']);
    return count;
  }

  Future<List<DeliveryOrder>> getDeliveryOrderList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('username');
    var deliveryOrderMapList = await selectDeliveryOrder(user);
    int count = deliveryOrderMapList.length;
    List<DeliveryOrder> deliveryOrderList = [];
    for (int i = 0; i < count; i++) {
      deliveryOrderList.add(DeliveryOrder.fromJson(deliveryOrderMapList[i]));
    }
    return deliveryOrderList;
  }

  Future<List<DeliveryOrder>> getDeliveryOrderListUnUploaded() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('username');
    var deliveryOrderMapList = await selectDeliveryOrderUnUpload(user);
    int count = deliveryOrderMapList.length;
    List<DeliveryOrder> deliveryOrderList = [];
    for (int i = 0; i < count; i++) {
      deliveryOrderList.add(DeliveryOrder.fromJson(deliveryOrderMapList[i]));
    }
    return deliveryOrderList;
  }

  Future<int> updateDeliveryOrderUploaded(String object) async {
    Database db = await DatabaseHelper().database;
    int count = await db.rawUpdate(
        'UPDATE $TABLE_DELIVERY_ORDER SET $DO_UPLOADED =? WHERE $ID_DELIVERY = ?',
        ["true", object]);
    return count;
  }

  Future<bool> checkCollectionPointNoTransaction(String user) async {
    Database db = await DatabaseHelper().database;
    bool transactionExist;
    var mapList = await db.rawQuery(
        "SELECT * FROM $TABLE_DELIVERY_ORDER where $DELIVERY_CREATED_BY=? and $DO_TRANSFERRED=?",
        [user, "false"]);
    if (mapList.isNotEmpty) {
      transactionExist = true;
    } else {
      transactionExist = false;
    }
    return transactionExist;
  }
}
