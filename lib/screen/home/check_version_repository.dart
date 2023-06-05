import 'dart:convert';
import 'dart:io';

import 'package:e_trace_app/base/api/api_configuration.dart';
import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/model/check_version_response.dart';
import 'package:e_trace_app/utils/storage_manager.dart';
import 'package:flutter/cupertino.dart';

class CheckVersionRepository extends APIConfiguration {
  CheckVersionRepository(String baseUrl) : super(baseUrl);

  void doCheckVersion(BuildContext context, onSuccess, onError) async {
    String userToken = await StorageManager.readData('token');
    String platform;
    if (Platform.isAndroid) {
      platform = "android";
    } else {
      platform = "iOS";
    }
    try {
      var url = baseUrl! +
          APIEndpoint.CHECK_VERSION +
          APP_VERSION +
          "&platform=" +
          platform;
      var uri = Uri.parse(url);
      var response = await ioClient!.post(
        uri,
        headers: getDefaultHeaderWithToken(userToken),
      );
      CheckVersionResponse apiResponse =
          CheckVersionResponse.fromJson(json.decode(response.body));
      print(response.body);
      if (apiResponse.success == true) {
        onSuccess(apiResponse);
        print('Cek Response Check Version : ${json.decode(response.body)}');
      } else {
        onError(response);
      }
    } catch (exception) {
      onError(exception);
    }
  }
}
