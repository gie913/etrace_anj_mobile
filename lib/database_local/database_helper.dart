import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'database_entity.dart';

class DatabaseHelper {
  static DatabaseHelper _dbHelper;
  static Database _database;

  DatabaseHelper._createObject();

  factory DatabaseHelper() {
    if (_dbHelper == null) {
      _dbHelper = DatabaseHelper._createObject();
    }
    return _dbHelper;
  }

  Future<Database> initDb() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'db_traceability.db';
    var todoDatabase = openDatabase(path,
        version: 1, onCreate: _createDb, onUpgrade: _upgradeDb);
    return todoDatabase;
  }

  void _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $TABLE_HARVEST_TIKET(
        $ID_TICKET TEXT NOT NULL,
        $ID_COLLECTION_TICKET TEXT,
        $ID_COLLECTION_TICKET_OLD TEXT,
        $ID_DELIVERY_ORDER_TICKET TEXT,
        $ID_SPLIT_TICKET TEXT,
        $TP_TRANSFERRED TEXT,
        $TP_UPLOADED TEXT,
        $DATE_TICKET TEXT NOT NULL,
        $LONG_LOCATION_TP TEXT,
        $LAT_LOCATION_TP TEXT,
        $TP_RECEIVED_VIA TEXT,
        $TP_FARMER_NAME TEXT,
        $FARMER_ID TEXT,
        $ASCEND_FARMER_ID TEXT,
        $FARMER_ASCEND_CODE TEXT,
        $WEIGHT DOUBLE,
        $QUANTITY INT,
        $NOTE TEXT,
        $NFC_NUMBER_TICKET TEXT,
        $IMAGE TEXT,
        $COMPANY_ID_TICKET TEXT,
        $AGENT_ID_TICKET TEXT,
        $TICKET_TRANSFER_TARGET TEXT,
        $TICKET_CREATED_BY TEXT)
    ''');
    await db.execute('''
      CREATE TABLE $TABLE_COLLECTION_POINT(
        $ID_COLLECTION TEXT NOT NULL,
        $ID_DELIVERY_ORDER_CP TEXT,
        $DATE_COLLECTION TEXT NOT NULL,
        $ID_COLLECTION_POINT_ORIGINAL TEXT,
        $LONG_LOCATION_CP TEXT,
        $CP_TRANSFERRED TEXT,
        $CP_UPLOADED TEXT,
        $LAT_LOCATION_CP TEXT,
        $TOTAL_QUANTITY_CP INT,
        $TOTAL_WEIGHT_CP DOUBLE,
        $AGENT_ID_CP TEXT,
        $ASCEND_AGENT_ID TEXT,
        $ASCEND_AGENT_CODE TEXT,
        $NFC_NUMBER_CP TEXT,
        $NOTE_CP TEXT,
        $COMPANY_ID_CP TEXT,
        $COLLECTION_CREATED_BY TEXT)
    ''');
    await db.execute('''
      CREATE TABLE $TABLE_DELIVERY_ORDER (
        $ID_DELIVERY TEXT NOT NULL,
        $DATE_DELIVERY TEXT NOT NULL,
        $LONG_LOCATION_DO TEXT,
        $LAT_LOCATION_DO TEXT,
        $DO_TRANSFERRED TEXT,
        $DO_UPLOADED TEXT,
        $TOTAL_QUANTITY_DO INT,
        $TOTAL_WEIGHT_DO DOUBLE,
        $SUPPLIER_ID_DO TEXT,
        $DO_SUPPLIER_NAME TEXT,
        $ASCEND_SUPPLIER_ID TEXT,
        $ASCEND_SUPPLIER_CODE TEXT,
        $NFC_NUMBER_DO TEXT,
        $PLAT_NUMBER TEXT,
        $DRIVER_NAME TEXT,
        $DRIVER_ID TEXT,
        $NOTE_DO TEXT,
        $IMAGE_DO TEXT,
        $COMPANY_ID_DO TEXT,
        $DELIVERY_CREATED_BY TEXT)
    ''');
    await db.execute('''
      CREATE TABLE $TABLE_FARMER (
        $FARMER_NAME TEXT,
        $FARMER_ID_OBJECT TEXT,
        $FARMER_ASCEND_ID TEXT,
        $FARMER_ASCEND_CODE TEXT,
        $FARMER_ADDRESS TEXT,
        $FARMER_LAT TEXT,
        $FARMER_LONG TEXT,
        $FARMER_LARGE_AREA TEXT,
        $FARMER_YOP TEXT,
        $FARMER_LAND_STATUS TEXT,
        $FARMER_PHONE TEXT,
        $FARMER_COMPANY TEXT,
        $FARMER_SUPPLIER TEXT,
        $FARMER_AGENT TEXT)
    ''');
    await db.execute('''
      CREATE TABLE $TABLE_AGENT (
        $AGENT_NAME TEXT,
        $AGENT_ASCEND_ID TEXT,
        $AGENT_ASCEND_CODE TEXT,
        $AGENT_ADDRESS TEXT,
        $AGENT_OTHER_ADDRESS TEXT,
        $AGENT_LAT TEXT,
        $AGENT_LONG TEXT,
        $FARMER_YOP TEXT,
        $AGENT_PHONE TEXT,
        $AGENT_COMPANY TEXT)
    ''');
    await db.execute('''
      CREATE TABLE $TABLE_SUPPLIER (
        $SUPPLIER_ID TEXT,
        $SUPPLIER_NAME TEXT,
        $SUPPLIER_ASCEND_ID TEXT,
        $SUPPLIER_ASCEND_CODE TEXT,
        $SUPPLIER_ADDRESS TEXT,
        $SUPPLIER_OTHER_ADDRESS TEXT,
        $SUPPLIER_LAT TEXT,
        $SUPPLIER_LONG TEXT,
        $SUPPLIER_PHONE TEXT,
        $SUPPLIER_COMPANY TEXT)
    ''');
    await db.execute('''
      CREATE TABLE $TABLE_USER (
        $ID_USER TEXT,
        $NAME_USER TEXT,
        $EMAIL_USER TEXT,
        $ROLE_USER TEXT,
        $USERNAME_USER TEXT,
        $PASSWORD_USER TEXT,
        $ADDRESS TEXT,
        $GENDER TEXT,
        $TOKEN TEXT,
        $COMPANY_NAME TEXT,
        $COMPANY_ID_USER TEXT,
        $SEQUENCE_NUMBER INTEGER,
        $PHONE_NUMBER TEXT)
    ''');
    await db.execute('''
      CREATE TABLE $TABLE_PRICE (
        $ID_PRICE TEXT,
        $DAY_PRICE TEXT,
        $DATE_PRICE TEXT,
        $PRICE_MEDIUM TEXT,
        $PRICE_SMALL TEXT,
        $PRICE_LARGE TEXT,
        $MAIN_CURRENCY TEXT,
        $COMPANY_ID TEXT)
    ''');
    await db.execute('''
      CREATE TABLE $TABLE_COMPANY (
        $ID_COMPANY TEXT,
        $NAME_COMPANY TEXT,
        $ALIAS_COMPANY TEXT,
        $CODE_COMPANY TEXT)
    ''');
    await db.execute('''
      CREATE TABLE $TABLE_FARMER_TRANSACTION (
        $FARMER_ASCEND_CODE TEXT NOT NULL,
        $ASCENDFARMERNAME TEXT,
        $TRYEAR INT,
        $GROUPINGMONTHINYEAR DOUBLE,
        $MAXTONNAGEYEAR DOUBLE,
        $TRMONTH TEXT)
    ''');
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initDb();
    }
    return _database;
  }

  FutureOr<void> _upgradeDb(Database db, int oldVersion, int newVersion) {}
}
