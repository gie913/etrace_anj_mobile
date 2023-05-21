import 'dart:convert';
import 'dart:io';

import 'package:e_trace_app/base/api/api_configuration.dart';
import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/screen/login/forgot_password_response.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';

class ForgotPasswordRepository {
  String? baseUrl;
  IOClient? ioClient;

  ForgotPasswordRepository(String baseUrl) {
    this.baseUrl = baseUrl;
    HttpClient httpClient = new HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
    this.ioClient = new IOClient(httpClient);
  }

  void doPostForgotPassword(
      BuildContext context, String username, onSuccess, onError) async {
    try {
      var url = baseUrl! + APIEndpoint.FORGOT_PASSWORD;
      var uri = Uri.parse(url);
      var map = new Map<String, dynamic>();
      map["username"] = username;
      var response = await ioClient!.post(
        uri,
        body: json.encode(map),
        headers: APIConfiguration(baseUrl!).getDefaultHeader(),
      );
      ForgotPasswordResponse apiResponse =
          ForgotPasswordResponse.fromJson(json.decode(response.body));
      if (apiResponse.success == true) {
        onSuccess(context, apiResponse);
      } else {
        onError(context, apiResponse);
      }
    } catch (exception) {
      onError(context, exception.toString());
    }
  }
}
