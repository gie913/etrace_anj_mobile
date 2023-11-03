import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:e_trace_app/base/api/api_configuration.dart';
import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/model/sync_supplier_response.dart';
import 'package:http/io_client.dart';

class SupplierRepository {
  String baseUrl;
  IOClient ioClient;

  SupplierRepository(String baseUrl) {
    this.baseUrl = baseUrl;
    HttpClient httpClient = new HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
    this.ioClient = new IOClient(httpClient);
  }

  void doSyncSupplier(String token, String lastSync, onSuccess, onError) async {
    String timeLastSync;
    if (lastSync == null) {
      timeLastSync = "";
    } else {
      timeLastSync = "/?last_updated_at=$lastSync";
    }
    try {
      var url = baseUrl + APIEndpoint.SYNC_DATA_SUPPLIER + timeLastSync;
      var uri = Uri.parse(url);
      var response = await ioClient.get(
        uri,
        headers: APIConfiguration(baseUrl).getDefaultHeaderWithToken(token),
      );
      log('url : $url');
      log('response : ${json.decode(response.body)}');
      SyncSupplierResponse apiResponse =
          SyncSupplierResponse.fromJson(json.decode(response.body));
      if (apiResponse.success == true) {
        onSuccess(apiResponse.data.suppliers);
      } else {
        onError(apiResponse.message);
      }
    } catch (exception) {
      log('error exception at ${baseUrl + APIEndpoint.SYNC_DATA_SUPPLIER + timeLastSync} : $exception');
      onError(exception);
    }
  }
}
