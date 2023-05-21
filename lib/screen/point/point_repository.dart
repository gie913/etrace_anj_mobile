import 'dart:convert';
import 'dart:io';

import 'package:e_trace_app/base/api/api_configuration.dart';
import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/model/point_response.dart';
import 'package:http/io_client.dart';

class PointRepository {
  String? baseUrl;
  IOClient? ioClient;

  PointRepository(String baseUrl) {
    this.baseUrl = baseUrl;
    HttpClient httpClient = new HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
    this.ioClient = new IOClient(httpClient);
  }

  void doGetPrice(String token, onSuccess, onError) async {
    try {
      var url = baseUrl! + APIEndpoint.POINT_ENDPOINT;
      var uri = Uri.parse(url);
      var response = await ioClient!.get(
        uri,
        headers: APIConfiguration(baseUrl!).getDefaultHeaderWithToken(token),
      );
      PointResponse apiResponse =
          PointResponse.fromJson(json.decode(response.body));
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
