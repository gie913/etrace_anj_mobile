import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:e_trace_app/base/api/api_configuration.dart';
import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/model/sync_farmer_response.dart';
import 'package:e_trace_app/utils/storage_manager.dart';
import 'package:http/io_client.dart';

class FarmerRepository {
  String baseUrl;
  IOClient ioClient;

  FarmerRepository(String baseUrl) {
    this.baseUrl = baseUrl;
    HttpClient httpClient = new HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
    this.ioClient = new IOClient(httpClient);
  }

  void doSyncFarmer(String token, String lastSync, onSuccess, onError) async {
    String timeLastSync;
    if (lastSync == null) {
      timeLastSync = "";
    } else {
      timeLastSync = "/?last_updated_at=$lastSync";
    }
    try {
      var url = baseUrl + APIEndpoint.SYNC_DATA_FARMER + timeLastSync;
      var uri = Uri.parse(url);
      var response = await ioClient.get(
        uri,
        headers: APIConfiguration(baseUrl).getDefaultHeaderWithToken(token),
      );
      log('url : $url');
      log('response : ${json.decode(response.body)}');
      SyncFarmerResponse apiResponse =
          SyncFarmerResponse.fromJson(json.decode(response.body));
      if (apiResponse.success == true) {
        StorageManager.saveData("abw", apiResponse.data.abw);
        StorageManager.saveData(
            "useMaxTonnage", apiResponse.data.useMaxTonnage);
        onSuccess(apiResponse.data.farmers);
      } else {
        onError(apiResponse.message);
      }
    } catch (exception) {
      log('error exception at ${baseUrl + APIEndpoint.SYNC_DATA_FARMER + timeLastSync} : $exception');
      onError(exception);
    }
  }
}
