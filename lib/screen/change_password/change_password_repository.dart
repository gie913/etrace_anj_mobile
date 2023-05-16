import 'dart:convert';

import 'package:e_trace_app/base/api/api_configuration.dart';
import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/utils/storage_manager.dart';

import 'change_password_response.dart';

class ChangePasswordRepository extends APIConfiguration {
  ChangePasswordRepository(String baseUrl) : super(baseUrl);


  void doChangePassword(String oldPassword, String newPassword,
      String confirmPassword, onSuccess, onLoading, onError) async {
    String token = await StorageManager.readData('token');
    onLoading();
    try {
      var map = new Map<String, dynamic>();
      map["old_password"] = oldPassword;
      map["new_password"] = newPassword;
      map["confirm_password"] = confirmPassword;
      var url = baseUrl + APIEndpoint.CHANGE_PASSWORD_ENDPOINT;
      var uri = Uri.parse(url);
      var response = await ioClient.post(
        uri,
        body: json.encode(map),
        headers: getDefaultHeaderWithToken(token),
      );
      ChangePassword apiResponse =
          ChangePassword.fromJson(json.decode(response.body));
      if (apiResponse.success == true) {
        onSuccess(apiResponse.message);
      } else {
        onError(apiResponse.message);
      }
    } catch (exception) {
      onError(exception);
    }
  }
}
