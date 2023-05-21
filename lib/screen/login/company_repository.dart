import 'dart:convert';
import 'dart:io';

import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/model/companies.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/io_client.dart';

class CompanyRepository {
  String? baseUrl;
  IOClient? ioClient;

  CompanyRepository(String baseUrl) {
    this.baseUrl = baseUrl;
    HttpClient httpClient = new HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
    this.ioClient = new IOClient(httpClient);
  }

  void doGetCompanies(BuildContext context, onSuccess, onError) async {
    try {
      var url = baseUrl! + APIEndpoint.COMPANIES_ENDPOINT;
      var uri = Uri.parse(url);
      var response = await ioClient!.get(uri);
      Companies apiResponse = Companies.fromJson(json.decode(response.body));
      if (apiResponse.success == true) {
        onSuccess(apiResponse.data);
      } else {
        onError(apiResponse.message);
      }
    } catch (exception) {
      onError(exception.toString());
    }
  }
}
