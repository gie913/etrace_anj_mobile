import 'package:e_trace_app/model/farmer_transaction.dart';
import 'package:e_trace_app/model/farmers.dart';
import 'package:sqflite/sqflite.dart';

import 'database_entity.dart';
import 'database_helper.dart';

class DatabaseFarmerTransaction {
  Future<int> insertFarmerTransaction(
      FarmerTransactions farmerTransactions) async {
    Database? db = await DatabaseHelper().database;
    int count = 0;
    for (int i = 0; i < farmerTransactions.data!.farmer!.length; i++) {
      int saved = await db!.insert(TABLE_FARMER_TRANSACTION,
          farmerTransactions.data!.farmer![i].toJson());
      count = count + saved;
    }
    return count;
  }

  Future<List<dynamic>> selectTRMonthByFarmer(Farmers farmer) async {
    Database? db = await DatabaseHelper().database;
    var map = await db!.rawQuery(
        'SELECT * from $TABLE_FARMER_TRANSACTION where $FARMER_ASCEND_CODE = ?',
        [farmer.ascendFarmerCode]);
    return map;
  }

  Future<Farmer> selectFarmerTransactionByFarmer(
      String farmerAscendCode) async {
    Database? db = await DatabaseHelper().database;
    var map = await db!.rawQuery(
        'SELECT * from $TABLE_FARMER_TRANSACTION where $FARMER_ASCEND_CODE = ?',
        [farmerAscendCode]);
    Farmer farmerTransactions = Farmer.fromJson(map[0]);
    return farmerTransactions;
  }

  Future<int> updateFarmerTransaction(Farmer object) async {
    Database? db = await DatabaseHelper().database;
    int count = await db!.update(TABLE_FARMER_TRANSACTION, object.toJson(),
        where: "$FARMER_ASCEND_CODE=?", whereArgs: [object.ascendFarmerCode]);
    return count;
  }

  Future<int> deleteInsertFarmerTransaction(
      FarmerTransactions farmerTransactions) async {
    Database? db = await DatabaseHelper().database;
    int countInsert = 0;
    for (int i = 0; i < farmerTransactions.data!.farmer!.length; i++) {
      int countDelete = await db!.delete(TABLE_FARMER_TRANSACTION,
          where: "$FARMER_ASCEND_CODE =? ",
          whereArgs: [farmerTransactions.data!.farmer![i].ascendFarmerCode]);
      if (countDelete != 0) {
        int saved = await db.insert(TABLE_FARMER_TRANSACTION,
            farmerTransactions.data!.farmer![i].toJson());
        countInsert = countInsert + saved;
      } else {
        int saved = await db.insert(TABLE_FARMER_TRANSACTION,
            farmerTransactions.data!.farmer![i].toJson());
        countInsert = countInsert + saved;
      }
    }
    return countInsert;
  }
}
