import 'dart:convert';
import 'dart:io';

import 'package:e_trace_app/base/api/api_configuration.dart';
import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/model/login_response.dart';
import 'package:e_trace_app/utils/storage_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/io_client.dart';

class LoginRepository {
  String baseUrl;
  IOClient ioClient;

  LoginRepository(String baseUrl) {
    this.baseUrl = baseUrl;
    HttpClient httpClient = new HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
    this.ioClient = new IOClient(httpClient);
  }

  void doPostLogin(BuildContext context, String username, String password,
      onSuccess, onError) async {
    try {
      var url = baseUrl + APIEndpoint.LOGIN_ENDPOINT;
      var uri = Uri.parse(url);
      var map = new Map<String, dynamic>();
      map["username"] = username;
      map["password"] = password;
      var response = await ioClient.post(
        uri,
        body: json.encode(map),
        headers: APIConfiguration(baseUrl).getDefaultHeader(),
      );
      LoginResponse apiResponse =
          LoginResponse.fromJson(json.decode(response.body));
      if (apiResponse.success == true) {
        StorageManager.saveData("useMaxTonnage", apiResponse.data.useMaxTonnage);
        onSuccess(context, apiResponse.data);
      } else {
        onError(context, apiResponse.message);
      }
    } catch (exception) {
      onError(context, "Kesalahan koneksi");
    }
  }
}
