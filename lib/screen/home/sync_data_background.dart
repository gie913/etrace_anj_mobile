import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/database_local/database_entity.dart';
import 'package:e_trace_app/database_local/database_helper.dart';
import 'package:e_trace_app/model/agents.dart';
import 'package:e_trace_app/model/farmers.dart';
import 'package:e_trace_app/model/suppliers.dart';
import 'package:e_trace_app/screen/sync/agent_repository.dart';
import 'package:e_trace_app/screen/sync/farmer_repository.dart';
import 'package:e_trace_app/screen/sync/supplier_repository.dart';
import 'package:e_trace_app/utils/storage_manager.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class SyncDataBackground {

  getDataFarmer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String lastSync = prefs.getString('lastSync');
    final String userToken = prefs.getString('token');
    final String userBaseUrl = prefs.getString('baseUrl');
    FarmerRepository(userBaseUrl).doSyncFarmer(
        userToken, lastSync, onSuccessSyncFarmer, onErrorSyncFarmer);
  }

  onSuccessSyncFarmer(List<Farmers> farmers) {
    for (int i = 0; i < farmers.length; i++) {
      insertFarmer(farmers[i]);
    }
    getDataAgent();
  }

  Future<int> insertFarmer(Farmers object) async {
    Database db = await DatabaseHelper().database;
    int count;
    var mapList = await db.query(TABLE_FARMER, where: '$FARMER_ID_OBJECT=?', whereArgs: [object.idFarmer]);
    if (mapList.isNotEmpty) {
      await db.update(TABLE_FARMER, object.toJson(), where: '$FARMER_ID_OBJECT=?', whereArgs: [object.idFarmer]);
    } else {
      count = await db.insert(TABLE_FARMER, object.toJson());
    }
    return count;
  }

  onErrorSyncFarmer(response) {}

  getDataAgent() async {
    final String lastSync = await StorageManager.readData('lastSync');
    final String userToken = await StorageManager.readData('token');
    AgentRepository(APIEndpoint.BASE_URL)
        .doSyncAgent(userToken, lastSync, onSuccessSyncAgent, onErrorSyncAgent);
  }

  onSuccessSyncAgent(List<Agents> agents) {
    for (int i = 0; i < agents.length; i++) {
      insertAgent(agents[i]);
    }
    getDataSupplier();
  }

  Future<int> insertAgent(Agents object) async {
    Database db = await DatabaseHelper().database;
    int count = await db.insert(TABLE_AGENT, object.toJson());
    return count;
  }

  onErrorSyncAgent(response) {}

  getDataSupplier() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String lastSync = prefs.getString('lastSync');
    final String userToken = prefs.getString('token');
    final String userBaseUrl = prefs.getString('baseUrl');
    SupplierRepository(userBaseUrl).doSyncSupplier(
        userToken, lastSync, onSuccessSyncSupplier, onErrorSyncSupplier);
  }

  onSuccessSyncSupplier(List<Suppliers> suppliers) {
    for (int i = 0; i < suppliers.length; i++) {
      insertSupplier(suppliers[i]);
    }
    setSession();
    String formattedDate =
        DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());
    setLastSync(formattedDate);
    setNotificationClicked();
  }

  setSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('session', 'true');
  }

  setLastSync(String lastSync) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastSync', lastSync);
  }

  Future<int> insertSupplier(Suppliers object) async {
    Database db = await DatabaseHelper().database;
    int count;
    var mapList = await db.query(TABLE_SUPPLIER, where: '$SUPPLIER_ID=?', whereArgs: [object.idSupplier]);
    if (mapList.isNotEmpty) {
      await db.update(TABLE_SUPPLIER, object.toJson(), where: '$SUPPLIER_ID=?', whereArgs: [object.idSupplier]);
    } else {
      count = await db.insert(TABLE_SUPPLIER, object.toJson());
    }
    return count;
  }

  onErrorSyncSupplier(response) {}


  setNotificationClicked() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('action');
    prefs.remove('title_notification');
    prefs.remove('message_notification');
    prefs.remove('url_notification');
    prefs.remove('clicked');
  }
}
