import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:e_trace_app/base/api/api_configuration.dart';
import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/model/farmer_transaction.dart';
import 'package:http/io_client.dart';

class FarmerTransactionRepository {
  String baseUrl;
  IOClient ioClient;

  FarmerTransactionRepository(String baseUrl) {
    this.baseUrl = baseUrl;
    HttpClient httpClient = new HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
    this.ioClient = new IOClient(httpClient);
  }

  void doSyncFarmerTransaction(String token, onSuccess, onError) async {
    try {
      var url = baseUrl + APIEndpoint.FARMER_TRANSACTION;
      var uri = Uri.parse(url);
      var response = await ioClient.get(
        uri,
        headers: APIConfiguration(baseUrl).getDefaultHeaderWithToken(token),
      );
      log('url : $url');
      log('token : $token');
      log('response : ${json.decode(response.body)}');
      FarmerTransactions apiResponse =
          FarmerTransactions.fromJson(json.decode(response.body));
      if (apiResponse.success == true) {
        onSuccess(apiResponse);
      } else {
        onError(apiResponse.message);
      }
    } catch (exception) {
      log('error exception at ${baseUrl + APIEndpoint.FARMER_TRANSACTION} : $exception');
      onError(exception);
    }
  }
}
