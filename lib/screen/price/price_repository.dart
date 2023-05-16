import 'dart:convert';
import 'dart:io';

import 'package:e_trace_app/base/api/api_configuration.dart';
import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/model/price_response.dart';
import 'package:http/io_client.dart';

class PriceRepository {

  String baseUrl;
  IOClient ioClient;

  PriceRepository(String baseUrl) {
    this.baseUrl = baseUrl;
    HttpClient httpClient = new HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);
    this.ioClient = new IOClient(httpClient);
  }

  void doGetPrice(String token, onSuccess, onError) async {
    try {
      var url = baseUrl + APIEndpoint.PRICE_ENDPOINT;
      var uri = Uri.parse(url);
      var response = await ioClient.get(
        uri,
        headers: APIConfiguration(baseUrl).getDefaultHeaderWithToken(token),
      );
      PriceResponse apiResponse =
      PriceResponse.fromJson(json.decode(response.body));
      print(response.body);
      if (apiResponse.success == true) {
        onSuccess(apiResponse);
      } else {
        onError(apiResponse.message);
      }
    } catch (exception) {
      onError(exception);
    }
  }
}