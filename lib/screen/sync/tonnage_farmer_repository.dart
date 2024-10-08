
import 'dart:convert';
import 'dart:io';

import 'package:e_trace_app/base/api/api_configuration.dart';
import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/model/sync_farmer_response.dart';
import 'package:e_trace_app/utils/storage_manager.dart';
import 'package:http/io_client.dart';

class TonnageFarmerRepository {

  String baseUrl;
  IOClient ioClient;

  TonnageFarmerRepository(String baseUrl) {
    this.baseUrl = baseUrl;
    HttpClient httpClient = new HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);
    this.ioClient = new IOClient(httpClient);
  }

  void doSyncFarmerTonnage(String token, String lastSync, onSuccess, onError) async {
    try {
      var url = baseUrl + APIEndpoint.SYNC_DATA_TONNAGE_FARMER;
      var uri = Uri.parse(url);
      var response = await ioClient.get(
        uri,
        headers: APIConfiguration(baseUrl).getDefaultHeaderWithToken(token),
      );
      SyncFarmerResponse apiResponse =
      SyncFarmerResponse.fromJson(json.decode(response.body));
      if (apiResponse.success == true) {
        StorageManager.saveData("abw", apiResponse.data.abw);
        onSuccess(apiResponse.data.farmers);
      } else {
        onError(apiResponse.message);
      }
    } catch (exception) {
      onError(exception);
    }
  }
}