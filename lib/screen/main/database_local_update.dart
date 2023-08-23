import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/database_local/database_entity.dart';
import 'package:e_trace_app/database_local/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseLocalUpdate {
  void addNewColumnOnVersion() async {
    if (APP_VERSION == "v.0.7.0") {
      Database db = await DatabaseHelper().database;
      try {
        await db.rawQuery(
            "ALTER TABLE $TABLE_HARVEST_TIKET ADD COLUMN $TP_RECEIVED_VIA TEXT;");
      } catch (e) {
        print("Column received via exist");
      }
      try {
        await db.rawQuery(
            "ALTER TABLE $TABLE_HARVEST_TIKET ADD COLUMN $TP_FARMER_NAME TEXT;");
      } catch (e) {
        print("Column farmer name exist");
      }
      try {
        await db.rawQuery(
            "ALTER TABLE $TABLE_DELIVERY_ORDER ADD COLUMN $DO_SUPPLIER_NAME TEXT;");
      } catch (e) {
        print("Column supplier name exist");
      }
    } else if (APP_VERSION == "v.1.2.4") {
      Database db = await DatabaseHelper().database;
      try {
        await db.rawQuery(
            "ALTER TABLE $TABLE_FARMER ADD COLUMN $FARMER_SUBDISTRICT TEXT;");
      } catch (e) {
        print("Column is exist");
      }
      try {
        await db.rawQuery(
            "ALTER TABLE $TABLE_FARMER ADD COLUMN $FARMER_MAX_BUNCH_YEAR INT;");
      } catch (e) {
        print("Column is exist");
      }
      try {
        await db.rawQuery(
            "ALTER TABLE $TABLE_FARMER ADD COLUMN $FARMER_MAX_TONNAGE_YEAR REAL;");
      } catch (e) {
        print("Column is exist");
      }
      try {
        await db.rawQuery(
            "ALTER TABLE $TABLE_FARMER ADD COLUMN $FARMER_MAX_KG_YEAR REAL;");
      } catch (e) {
        print("Column is exist");
      }
      try {
        await db.execute('''
      CREATE TABLE $TABLE_FARMER_TRANSACTION (
        $FARMER_ASCEND_CODE TEXT NOT NULL,
        $ASCENDFARMERNAME TEXT,
        $TRYEAR INT,
        $GROUPINGMONTHINYEAR DOUBLE,
        $MAXTONNAGEYEAR DOUBLE,
        $TRMONTH TEXT)
    ''');
      } catch (e) {
        print(e);
      }
    }
  }
}
