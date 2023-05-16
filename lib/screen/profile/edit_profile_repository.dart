import 'dart:convert';
import 'dart:io';

import 'package:e_trace_app/base/api/api_configuration.dart';
import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:http/io_client.dart';

import 'edit_response.dart';

class EditProfileRepository {

  String baseUrl;
  IOClient ioClient;

  EditProfileRepository(String baseUrl) {
    this.baseUrl = baseUrl;
    HttpClient httpClient = new HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);
    this.ioClient = new IOClient(httpClient);
  }

  void doEditProfile(String token, String phone, String email, onSuccess, onError) async {
    try {
      var url = baseUrl + APIEndpoint.CHANGE_PROFILE;
      var uri = Uri.parse(url);
      var map = new Map<String, dynamic>();
      map["phone_number"] = phone;
      map["email"] = email;
      var response = await ioClient.post(
        uri,
        body: json.encode(map),
        headers: APIConfiguration(baseUrl).getDefaultHeaderWithToken(token),
      );
      EditResponse apiResponse =
      EditResponse.fromJson(json.decode(response.body));
      if (apiResponse.success == true) {
        onSuccess("Berhasil Menyimpan");
      } else {
        onError("Gagal Menyimpan");
      }
    } catch (exception) {
      onError(exception.toString());
    }
  }
}