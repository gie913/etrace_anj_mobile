import 'dart:convert';
import 'dart:io';

import 'package:e_trace_app/base/api/api_configuration.dart';
import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/base/strings/constants.dart';
import 'package:http/io_client.dart';

class SetVersionRepository {

  String baseUrl;
  IOClient ioClient;

  SetVersionRepository(String baseUrl) {
    this.baseUrl = baseUrl;
    HttpClient httpClient = new HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);
    this.ioClient = new IOClient(httpClient);
  }

  void doSetVersion(String token, onSuccess, onError) async {
    String platform;
    if (Platform.isAndroid) {
      platform = "android";
    } else {
      platform = "ios";
    }
    try {
      var url = baseUrl + APIEndpoint.SET_VERSION;
      var uri = Uri.parse(url);
      var map = new Map<String, dynamic>();
      map["user_app_version"] = APP_VERSION;
      map["platform"] = platform;
      var response = await ioClient.post(
        uri,
        body: json.encode(map),
        headers: APIConfiguration(baseUrl).getDefaultHeaderWithToken(token),
      );
      print(response);
    } catch (exception) {
      onError(exception.toString());
    }
  }
}