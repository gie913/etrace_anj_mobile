import 'dart:convert';

import 'package:e_trace_app/database_local/database_entity.dart';
import 'package:e_trace_app/model/farmers.dart';
import 'package:e_trace_app/model/harvesting_ticket.dart';
import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

class DatabaseFarmer {
  void getFarmerList(onSuccess, onError) async {
    var farmerMapList = await selectFarmer();
    int count = farmerMapList.length;
    for (var i = 0; i < count; i++) {
      var farmerJson = json.decode(json.encode(farmerMapList[i]));
      Farmers farmer = Farmers.fromJson(farmerJson);
      onSuccess(farmer);
    }
  }

  Future<List<Map<String, dynamic>>> selectFarmer() async {
    Database? db = await DatabaseHelper().database;
    var mapList = await db!.query(TABLE_FARMER);
    return mapList;
  }

  Future<int?> insertFarmer(Farmers object) async {
    Database? db = await DatabaseHelper().database;
    int? count;
    var mapList = await db!.query(TABLE_FARMER,
        where: '$FARMER_ID_OBJECT=?', whereArgs: [object.idFarmer]);
    if (mapList.isNotEmpty) {
      await db.update(TABLE_FARMER, object.toJson(),
          where: '$FARMER_ID_OBJECT=?', whereArgs: [object.idFarmer]);
    } else {
      count = await db.insert(TABLE_FARMER, object.toJson());
    }
    return count;
  }

  Future<int> updateFarmer(Farmers object) async {
    Database? db = await DatabaseHelper().database;
    int count = await db!.update(TABLE_FARMER, object.toJson(),
        where: "$FARMER_ID_OBJECT=?", whereArgs: [object.idFarmer]);
    return count;
  }

  Future<Farmers> selectFarmerByID(HarvestingTicket object) async {
    Database? db = await DatabaseHelper().database;
    Farmers farmers = new Farmers();
    var mapList = await db!.query(TABLE_FARMER,
        where: '$FARMER_ASCEND_CODE=?', whereArgs: [object.ascendFarmerCode]);
    for (int i = 0; i < mapList.length; i++) {
      farmers = Farmers.fromJson(mapList[i]);
    }
    return farmers;
  }

  Future<int> deleteFarmerBlacklist(List<String> farmerCode) async {
    int result = 0;
    Database? db = await DatabaseHelper().database;
    for (int i = 0; i < farmerCode.length; i++) {
      var deleted = await db!.delete(TABLE_FARMER,
          where: "$FARMER_ASCEND_CODE = ?", whereArgs: [farmerCode[i]]);
      result = result + deleted;
    }
    return result;
  }

  Future<Farmers> selectFarmerByIDString(String object) async {
    Database? db = await DatabaseHelper().database;
    Farmers farmers = new Farmers();
    var mapList = await db!.query(TABLE_FARMER,
        where: '$FARMER_ASCEND_CODE=?', whereArgs: [object]);
    for (int i = 0; i < mapList.length; i++) {
      farmers = Farmers.fromJson(mapList[i]);
    }
    return farmers;
  }

  Future<double> selectMaxTonnageYear(Farmers farmers) async {
    Database? db = await DatabaseHelper().database;
    Farmers farmers = new Farmers();
    double maxTonnage = 0.0;
    var mapList = await db!.query(TABLE_FARMER,
        where: '$FARMER_ID_OBJECT=?', whereArgs: [farmers.idFarmer]);
    if (mapList.isNotEmpty) {
      farmers = Farmers.fromJson(mapList[0]);
      maxTonnage = farmers.maxTonnageYear;
    }
    return maxTonnage;
  }

  Future<double> selectSumTonnageYear(Farmers farmers) async {
    Database? db = await DatabaseHelper().database;
    Farmers farmers = new Farmers();
    double sumTonnage = 0.0;
    var mapList = await db!.query(TABLE_FARMER,
        where: '$FARMER_ID_OBJECT=?', whereArgs: [farmers.idFarmer]);
    if (mapList.isNotEmpty) {
      farmers = Farmers.fromJson(mapList[0]);
      sumTonnage = farmers.maxTonnageYear;
    }
    return sumTonnage;
  }
}
