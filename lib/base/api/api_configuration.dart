import 'dart:io';

import 'package:http/io_client.dart';

class APIConfiguration {
  String baseUrl;
  IOClient ioClient;

  APIConfiguration(String baseUrl) {
    this.baseUrl = baseUrl;
    HttpClient httpClient = new HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
    this.ioClient = new IOClient(httpClient);
  }

  Map<String, String> getDefaultHeader() {
    Map<String, String> headers = {
      "Content-type": "application/json",
      "Accept": "application/json",
    };
    return headers;
  }

  Map<String, String> getDefaultHeaderWithToken(String token) {
    Map<String, String> headers = {
      "Content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token"
    };
    return headers;
  }

  Map<String, String> getDefaultHeaderOnlyToken(String token) {
    Map<String, String> headers = {"Authorization": "Bearer $token"};
    return headers;
  }

  Map<String, String> getDefaultHeaderFormWithToken(String token) {
    Map<String, String> headers = {
      "Media-type": "multipart/form-data",
      "Authorization": "Bearer $token"
    };
    return headers;
  }

  Map<String, String> getDefaultHeaderWithTokens(String token) {
    Map<String, String> headers = {
      "Content-type": "application/json",
      "Authorization": "Bearer $token"
    };
    return headers;
  }
}
