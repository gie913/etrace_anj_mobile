import 'package:e_trace_app/database_local/database_entity.dart';
import 'package:e_trace_app/model/collection_point.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

class DatabaseCollectionPoint {
  Future<List<Map<String, dynamic>>> selectCollectionPoint(String user) async {
    Database? db = await DatabaseHelper().database;
    var mapList = await db!.rawQuery(
        "SELECT * FROM $TABLE_COLLECTION_POINT where $COLLECTION_CREATED_BY=? ORDER BY $CP_TRANSFERRED DESC, strftime('%y-%M-%d %H:%m', $DATE_COLLECTION) DESC",
        [user]);
    return mapList;
  }

  Future<List<Map<String, dynamic>>> selectCollectionPointForDelivery(
      String user) async {
    Database? db = await DatabaseHelper().database;
    var mapList = await db!.query(TABLE_COLLECTION_POINT,
        where:
            "$COLLECTION_CREATED_BY=? and $ID_DELIVERY_ORDER_CP is null and $CP_TRANSFERRED=?",
        whereArgs: [user, "false"],
        orderBy: CP_TRANSFERRED);
    return mapList;
  }

  Future<int> insertCollectionPoint(CollectionPoint object) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString('username');
    object.createdBy = user!;
    Database? db = await DatabaseHelper().database;
    int count = await db!.insert(TABLE_COLLECTION_POINT, object.toJson());
    return count;
  }

  Future<int> selectCollectionPointCountUnUpload() async {
    Database? db = await DatabaseHelper().database;
    var mapList = await db!.query(TABLE_COLLECTION_POINT,
        where: "$CP_UPLOADED=?", whereArgs: ["false"]);
    int count = mapList.length;
    return count;
  }

  Future<List<Map<String, dynamic>>> selectCollectionPointUnUploaded(
      String user) async {
    Database? db = await DatabaseHelper().database;
    var mapList = await db!.query(TABLE_COLLECTION_POINT,
        where: "$CP_UPLOADED=?", whereArgs: ["false"], orderBy: CP_TRANSFERRED);
    return mapList;
  }

  Future<int> updateCollectionPointDeliveryDelete(
      String idDeliveryOrder) async {
    Database? db = await DatabaseHelper().database;
    int count = await db!.rawUpdate(
        'UPDATE $TABLE_COLLECTION_POINT SET $ID_DELIVERY_ORDER_CP = ? WHERE $ID_DELIVERY_ORDER_CP = ?',
        [null, idDeliveryOrder]);
    return count;
  }

  Future<int> updateCollectionPointDeliverySave(
      String idCollection, String idDeliveryOrder) async {
    Database? db = await DatabaseHelper().database;
    int count = await db!.rawUpdate(
        'UPDATE $TABLE_COLLECTION_POINT SET $ID_DELIVERY_ORDER_CP = ? WHERE $ID_COLLECTION = ?',
        [idDeliveryOrder, idCollection]);
    return count;
  }

  Future<int> updateCollectionPointDeliveryTransfer(
      String idDeliveryOrder) async {
    Database? db = await DatabaseHelper().database;
    int count = await db!.rawUpdate(
        'UPDATE $TABLE_COLLECTION_POINT SET $CP_TRANSFERRED = ? WHERE $ID_DELIVERY_ORDER_CP = ?',
        ["true", idDeliveryOrder]);
    return count;
  }

  Future<int> updateCollectionPoint(CollectionPoint object) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString('username');
    object.createdBy = user!;
    Database? db = await DatabaseHelper().database;
    int count = await db!.update(TABLE_COLLECTION_POINT, object.toJson(),
        where: '$ID_COLLECTION=?', whereArgs: [object.idCollection]);
    return count;
  }

  Future<int> deleteCollectionPoint(CollectionPoint object) async {
    Database? db = await DatabaseHelper().database;
    int count = await db!.delete(TABLE_COLLECTION_POINT,
        where: '$ID_COLLECTION=?', whereArgs: [object.idCollection]);
    return count;
  }

  Future<int> deleteCollectionPointOneMonthAgo(String dateCollection) async {
    Database? db = await DatabaseHelper().database;
    int count = await db!.rawDelete(
        'DELETE FROM $TABLE_COLLECTION_POINT WHERE $DATE_COLLECTION <= ? AND $CP_UPLOADED = ?',
        ['$dateCollection%', 'true']);
    return count;
  }

  Future<List<CollectionPoint>> getCollectionPointList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString('username');
    var collectionPointMapList = await selectCollectionPoint(user!);
    int count = collectionPointMapList.length;
    List<CollectionPoint> collectionPointList = [];
    for (int i = 0; i < count; i++) {
      collectionPointList
          .add(CollectionPoint.fromJson(collectionPointMapList[i]));
    }
    return collectionPointList;
  }

  Future<List<CollectionPoint>> getCollectionPointListForDelivery() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString('username');
    var collectionPointMapList = await selectCollectionPointForDelivery(user!);
    List<CollectionPoint> collectionPointList = [];
    for (int i = 0; i < collectionPointMapList.length; i++) {
      collectionPointList
          .add(CollectionPoint.fromJson(collectionPointMapList[i]));
    }
    return collectionPointList;
  }

  Future<List<CollectionPoint>> getCollectionPointListUnUploaded() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString('username');
    var collectionPointMapList = await selectCollectionPointUnUploaded(user!);
    int count = collectionPointMapList.length;
    List<CollectionPoint> collectionPointList = [];
    for (int i = 0; i < count; i++) {
      collectionPointList
          .add(CollectionPoint.fromJson(collectionPointMapList[i]));
    }
    return collectionPointList;
  }

  Future<int> updateCollectionPointUploaded(String object) async {
    Database? db = await DatabaseHelper().database;
    int count = await db!.rawUpdate(
        'UPDATE $TABLE_COLLECTION_POINT SET $CP_UPLOADED =? WHERE $ID_COLLECTION = ?',
        ["true", object]);
    return count;
  }

  Future<bool> checkCollectionPointNoTransaction(String user) async {
    Database? db = await DatabaseHelper().database;
    bool transactionExist;
    var mapList = await db!.rawQuery(
        "SELECT * FROM $TABLE_COLLECTION_POINT where $COLLECTION_CREATED_BY=? and $CP_TRANSFERRED=?",
        [user, "false"]);
    if (mapList.isNotEmpty) {
      transactionExist = true;
    } else {
      transactionExist = false;
    }
    return transactionExist;
  }
}
