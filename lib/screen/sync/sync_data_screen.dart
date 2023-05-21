import 'package:e_trace_app/base/ui/palette.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/database_local/database_entity.dart';
import 'package:e_trace_app/database_local/database_farmer.dart';
import 'package:e_trace_app/database_local/database_farmer_transaction.dart';
import 'package:e_trace_app/database_local/database_helper.dart';
import 'package:e_trace_app/model/farmer_transaction.dart';
import 'package:e_trace_app/model/log_out_response.dart';
import 'package:e_trace_app/screen/login/login_screen.dart';
import 'package:e_trace_app/screen/main/main_screen.dart';
import 'package:e_trace_app/screen/profile/logout_repository.dart';
import 'package:e_trace_app/screen/sync/agent_repository.dart';
import 'package:e_trace_app/screen/sync/farmer_repository.dart';
import 'package:e_trace_app/screen/sync/farmer_transaction_repository.dart';
import 'package:e_trace_app/screen/sync/supplier_repository.dart';
import 'package:e_trace_app/model/farmers.dart';
import 'package:e_trace_app/model/agents.dart';
import 'package:e_trace_app/model/suppliers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class SyncDataScreen extends StatefulWidget {
  @override
  _SyncDataScreenState createState() => _SyncDataScreenState();
}

class _SyncDataScreenState extends State<SyncDataScreen> {
  var lastSync;

  @override
  void initState() {
    getDataFarmer();
    super.initState();
  }

  getDataFarmer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastSync = prefs.getString('lastSync');
    String? userToken = prefs.getString('token');
    String? userBaseUrl = prefs.getString('baseUrl');
    FarmerRepository(userBaseUrl!).doSyncFarmer(
        userToken!, lastSync, onSuccessSyncFarmer, onErrorSyncFarmer);
  }

  onSuccessSyncFarmer(List<Farmers> farmers) {
    for (int i = 0; i < farmers.length; i++) {
      insertFarmer(farmers[i]);
    }
    getDataAgent();
  }

  Future<int> insertFarmer(Farmers object) async {
    Database? db = await DatabaseHelper().database;
    int count = await db!.insert(TABLE_FARMER, object.toJson());
    return count;
  }

  onErrorSyncFarmer(response) {
    _openWarningDialog(response.toString());
  }

  getDataAgent() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastSync = prefs.getString('lastSync');
    String? userToken = prefs.getString('token');
    String? userBaseUrl = prefs.getString('baseUrl');
    AgentRepository(userBaseUrl!).doSyncAgent(
        userToken!, lastSync, onSuccessSyncAgent, onErrorSyncAgent);
  }

  onSuccessSyncAgent(List<Agents> agents) {
    for (int i = 0; i < agents.length; i++) {
      insertAgent(agents[i]);
    }
    getDataSupplier();
  }

  Future<int> insertAgent(Agents object) async {
    Database? db = await DatabaseHelper().database;
    int count = await db!.insert(TABLE_AGENT, object.toJson());
    return count;
  }

  onErrorSyncAgent(response) {
    _openWarningDialog(response.toString());
  }

  getDataSupplier() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastSync = prefs.getString('lastSync');
    String? userToken = prefs.getString('token');
    String? userBaseUrl = prefs.getString('baseUrl');
    SupplierRepository(userBaseUrl!).doSyncSupplier(
        userToken!, lastSync, onSuccessSyncSupplier, onErrorSyncSupplier);
  }

  onSuccessSyncSupplier(List<Suppliers> suppliers) {
    for (int i = 0; i < suppliers.length; i++) {
      insertSupplier(suppliers[i]);
    }
    getDataFarmerTransaction();
  }

  getDataFarmerTransaction() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString('token');
    String? userBaseUrl = prefs.getString('baseUrl');
    FarmerTransactionRepository(userBaseUrl!).doSyncFarmerTransaction(
        userToken!, onSuccessFarmerTransaction, onErrorFarmerTransaction);
  }

  onSuccessFarmerTransaction(FarmerTransactions farmerTransactions) {
    DatabaseFarmerTransaction().insertFarmerTransaction(farmerTransactions);
    DatabaseFarmer()
        .deleteFarmerBlacklist(farmerTransactions.data!.blacklistedFarmer!);
    setSession();
    setLastSync();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => MainScreen()));
  }

  onErrorFarmerTransaction(response) {
    _openWarningDialog(response.toString());
  }

  setSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('session', 'true');
  }

  setLastSync() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String formattedDate =
        DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());
    prefs.setString('lastSync', formattedDate);
  }

  Future<int> insertSupplier(Suppliers object) async {
    Database? db = await DatabaseHelper().database;
    int count = await db!.insert(TABLE_SUPPLIER, object.toJson());
    return count;
  }

  onErrorSyncSupplier(response) {
    _openWarningDialog(response.toString());
  }

  _openWarningDialog(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Text("Gagal melalukan sinkronisasi", style: text14Bold),
            content: Text(message, style: text14),
            actions: <Widget>[
              TextButton(
                child: Text(
                  "Ok",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  doLogoutUser();
                },
              ),
            ],
          );
        }).then((val) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: SizedBox(
              height: 50.0,
              width: 50.0,
              child: CircularProgressIndicator(
                backgroundColor: primaryColorDark,
                strokeWidth: 4.0,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 25.0),
            child: Center(
              child: Column(
                children: [
                  Text("Sinkronisasi data.."),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void doLogoutUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString('token');
    String? userBaseUrl = prefs.getString('baseUrl');
    LogOutRepository(userBaseUrl!).doGetLogOut(
        userToken!, onSuccessLogOutCallback, onErrorLogOutCallback);
  }

  onSuccessLogOutCallback(LogOutResponse logOutResponse) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  onErrorLogOutCallback(response) {
    print("Log Out Gagal");
  }
}
