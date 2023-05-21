import 'package:e_trace_app/database_local/database_helper.dart';
import 'package:e_trace_app/model/collection_point.dart';
import 'package:e_trace_app/model/delivery_order.dart';
import 'package:e_trace_app/model/harvesting_ticket.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'database_entity.dart';

class DatabaseHarvestTicket {
  Future<List<Map<String, dynamic>>> selectHarvestTicket(String user) async {
    Database? db = await DatabaseHelper().database;
    var mapList = await db!.rawQuery(
        "SELECT * FROM $TABLE_HARVEST_TIKET where $TICKET_CREATED_BY=? ORDER BY $TP_TRANSFERRED DESC, strftime('%y-%M-%d %H:%m', $DATE_TICKET) DESC",
        [user]);
    return mapList;
  }

  Future<bool> checkHarvestTicketNoTransaction(String user) async {
    Database? db = await DatabaseHelper().database;
    bool noTransactionExist;
    var mapList = await db!.rawQuery(
        "SELECT * FROM $TABLE_HARVEST_TIKET where $TICKET_CREATED_BY=? and $TP_TRANSFERRED=?",
        [user, "false"]);
    if (mapList.isNotEmpty) {
      noTransactionExist = true;
    } else {
      noTransactionExist = false;
    }
    return noTransactionExist;
  }

  Future<List<Map<String, dynamic>>> selectHarvestTicketUnUploaded(
      String user) async {
    Database? db = await DatabaseHelper().database;
    var mapList = await db!.query(TABLE_HARVEST_TIKET,
        where: "$TP_UPLOADED=?", whereArgs: ["false"], orderBy: TP_TRANSFERRED);
    return mapList;
  }

  Future<List<HarvestingTicket>> getHarvestTicketListCollection(
      CollectionPoint collectionPoint) async {
    var harvestTicketMapList =
        await selectHarvestTicketByCollection(collectionPoint);
    int count = harvestTicketMapList.length;
    List<HarvestingTicket> harvestTicketList = [];
    for (int i = 0; i < count; i++) {
      harvestTicketList.add(HarvestingTicket.fromJson(harvestTicketMapList[i]));
    }
    return harvestTicketList;
  }

  Future<int> selectHarvestTicketCountUnUpload() async {
    Database? db = await DatabaseHelper().database;
    var mapList = await db!.query(TABLE_HARVEST_TIKET,
        where: "$TP_UPLOADED=?", whereArgs: ["false"]);
    int count = mapList.length;
    return count;
  }

  Future<List<Map<String, dynamic>>> selectHarvestTicketByCollection(
      CollectionPoint collectionPoint) async {
    Database? db = await DatabaseHelper().database;
    var mapList = await db!.query(TABLE_HARVEST_TIKET,
        where: "$ID_COLLECTION_TICKET=?",
        whereArgs: [collectionPoint.idCollection]);
    print(mapList);
    return mapList;
  }

  Future<List<HarvestingTicket>> getHarvestTicketListDelivery(
      DeliveryOrder deliveryOrder) async {
    var harvestTicketMapList =
        await selectHarvestTicketByDelivery(deliveryOrder);
    int count = harvestTicketMapList.length;
    List<HarvestingTicket> harvestTicketList = [];
    for (int i = 0; i < count; i++) {
      harvestTicketList.add(HarvestingTicket.fromJson(harvestTicketMapList[i]));
    }
    return harvestTicketList;
  }

  Future<List<Map<String, dynamic>>> selectHarvestTicketByDelivery(
      DeliveryOrder deliveryOrder) async {
    Database? db = await DatabaseHelper().database;
    var list = await db!.query(TABLE_HARVEST_TIKET);
    print(list);
    var mapList = await db.query(TABLE_HARVEST_TIKET,
        where: "$ID_DELIVERY_ORDER_TICKET=?",
        whereArgs: [deliveryOrder.idDelivery]);
    return mapList;
  }

  Future<int> insertHarvestTicketFromOther(HarvestingTicket object) async {
    Database? db = await DatabaseHelper().database;
    int count = await db!.insert(TABLE_HARVEST_TIKET, object.toJson());
    return count;
  }

  Future<int> insertHarvestTicket(HarvestingTicket object) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString('username');
    object.createdBy = user!;
    Database? db = await DatabaseHelper().database;
    int count = await db!.insert(TABLE_HARVEST_TIKET, object.toJson());
    return count;
  }

  Future<int> updateHarvestTicket(HarvestingTicket object) async {
    Database? db = await DatabaseHelper().database;
    int count = await db!.update(TABLE_HARVEST_TIKET, object.toJson(),
        where: '$ID_TICKET=?', whereArgs: [object.idTicket]);
    return count;
  }

  Future<int> updateHarvestTicketUploaded(String object) async {
    Database? db = await DatabaseHelper().database;
    int count = await db!.rawUpdate(
        'UPDATE $TABLE_HARVEST_TIKET SET $TP_UPLOADED =? WHERE $ID_TICKET = ?',
        ["true", object]);
    return count;
  }

  Future<int> updateHarvestTicketCollection(String object) async {
    Database? db = await DatabaseHelper().database;
    int count = await db!.rawUpdate(
        'UPDATE $TABLE_HARVEST_TIKET SET $ID_COLLECTION_TICKET = ? WHERE $ID_COLLECTION_TICKET = ?',
        [null, '$object']);
    return count;
  }

  Future<int> updateHarvestTicketCollectionTransfer(String object) async {
    Database? db = await DatabaseHelper().database;
    int count = await db!.rawUpdate(
        'UPDATE $TABLE_HARVEST_TIKET SET $TP_TRANSFERRED = ? WHERE $ID_COLLECTION_TICKET = ?',
        ["true", '$object']);
    return count;
  }

  Future<int> updateHarvestTicketDeliveryDelete(String object) async {
    Database? db = await DatabaseHelper().database;
    int count = await db!.rawUpdate(
        'UPDATE $TABLE_HARVEST_TIKET SET $ID_DELIVERY_ORDER_TICKET =?, $ID_COLLECTION_TICKET=? WHERE $ID_DELIVERY_ORDER_TICKET = ?',
        [null, null, '$object']);
    return count;
  }

  Future<int> updateHarvestTicketDeliveryTransfer(String object) async {
    Database? db = await DatabaseHelper().database;
    int count = await db!.rawUpdate(
        'UPDATE $TABLE_HARVEST_TIKET SET $TP_TRANSFERRED =? WHERE $ID_DELIVERY_ORDER_TICKET = ?',
        ["true", '$object']);
    return count;
  }

  Future<int> updateHarvestTicketCollectionPointSplit(String object) async {
    Database? db = await DatabaseHelper().database;
    int count = await db!.rawUpdate(
        'UPDATE $TABLE_HARVEST_TIKET SET $TP_TRANSFERRED =? WHERE $ID_COLLECTION_TICKET = ?',
        ["true", '$object']);
    return count;
  }

  Future<bool> checkHarvestTicketExist(String object) async {
    Database? db = await DatabaseHelper().database;
    bool exist;
    var mapList = await db!.rawQuery(
        'SELECT * FROM $TABLE_HARVEST_TIKET WHERE $ID_TICKET=?', [object]);
    if (mapList.length == 0) {
      exist = false;
    } else {
      exist = true;
    }
    return exist;
  }

  Future<int> deleteHarvestTicket(HarvestingTicket object) async {
    Database? db = await DatabaseHelper().database;
    int count = await db!.delete(TABLE_HARVEST_TIKET,
        where: '$ID_TICKET=?', whereArgs: [object.idTicket]);
    return count;
  }

  Future<int> deleteHarvestTicketOneMonthAgo(String dateTicket) async {
    Database? db = await DatabaseHelper().database;
    int count = await db!.rawDelete(
        'DELETE FROM $TABLE_HARVEST_TIKET WHERE $DATE_TICKET <= ? AND $TP_UPLOADED = ?',
        ['$dateTicket%', 'true']);
    return count;
  }

  Future<List<HarvestingTicket>> getHarvestTicketList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString('username');
    var harvestTicketMapList = await selectHarvestTicket(user!);
    int count = harvestTicketMapList.length;
    List<HarvestingTicket> harvestTicketList = [];
    for (int i = 0; i < count; i++) {
      harvestTicketList.add(HarvestingTicket.fromJson(harvestTicketMapList[i]));
    }
    return harvestTicketList;
  }

  Future<List<HarvestingTicket>> getHarvestTicketListUnUploaded() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString('username');
    var harvestTicketMapList = await selectHarvestTicketUnUploaded(user!);
    int count = harvestTicketMapList.length;
    List<HarvestingTicket> harvestTicketList = [];
    for (int i = 0; i < count; i++) {
      harvestTicketList.add(HarvestingTicket.fromJson(harvestTicketMapList[i]));
    }
    return harvestTicketList;
  }

  Future<List<HarvestingTicket>> getHarvestTicketListForDelivery() async {
    var harvestTicketMapList = await selectHarvestTicketForDelivery();
    int count = harvestTicketMapList.length;
    List<HarvestingTicket> harvestTicketList = [];
    for (int i = 0; i < count; i++) {
      harvestTicketList.add(HarvestingTicket.fromJson(harvestTicketMapList[i]));
    }
    return harvestTicketList;
  }

  Future<List<HarvestingTicket>> getHarvestTicketListForCollection() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString('username');
    var harvestTicketMapList = await selectHarvestTicketForCollection(user!);
    int count = harvestTicketMapList.length;
    List<HarvestingTicket> harvestTicketList = [];
    for (int i = 0; i < count; i++) {
      harvestTicketList.add(HarvestingTicket.fromJson(harvestTicketMapList[i]));
    }
    return harvestTicketList;
  }

  Future<List<Map<String, dynamic>>> selectHarvestTicketForCollection(
      String user) async {
    Database? db = await DatabaseHelper().database;
    var mapList = await db!.query(TABLE_HARVEST_TIKET,
        where:
            "$ID_COLLECTION_TICKET is null and $TP_TRANSFERRED=? and $ID_DELIVERY_ORDER_TICKET is null and $TICKET_CREATED_BY=?",
        whereArgs: ["false", user],
        orderBy: TP_TRANSFERRED);
    return mapList;
  }

  Future<List<Map<String, dynamic>>> selectHarvestTicketForDelivery() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString('username');
    Database? db = await DatabaseHelper().database;
    var mapList = await db!.query(TABLE_HARVEST_TIKET,
        where:
            "$ID_DELIVERY_ORDER_TICKET is null and $ID_COLLECTION_TICKET is null and $TP_TRANSFERRED=? and $TICKET_CREATED_BY=?",
        whereArgs: ["false", user],
        orderBy: ID_COLLECTION_TICKET);
    return mapList;
  }
}
