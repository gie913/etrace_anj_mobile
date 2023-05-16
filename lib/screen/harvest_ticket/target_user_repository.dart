import 'dart:convert';

import 'package:e_trace_app/base/api/api_configuration.dart';
import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/model/target_user_response.dart';
import 'package:e_trace_app/utils/storage_manager.dart';


class TargetUserRepository extends APIConfiguration {
  TargetUserRepository(String baseUrl) : super(baseUrl);


  void doGetTargetUser(onSuccess, onError) async {
    String token = await StorageManager.readData('token');
    try {
      var url = baseUrl + APIEndpoint.USER_TARGET_ENDPOINT;
      var uri = Uri.parse(url);
      var response = await ioClient.get(
        uri,
        headers: getDefaultHeaderWithToken(token),
      );
      TargetUserResponse apiResponse =
          TargetUserResponse.fromJson(json.decode(response.body));
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
