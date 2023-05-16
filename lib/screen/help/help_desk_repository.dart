import 'dart:convert';

import 'package:e_trace_app/base/api/api_configuration.dart';
import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/model/send_help_desk.dart';
import 'package:e_trace_app/utils/storage_manager.dart';

class HelpDeskRepository extends APIConfiguration {
  HelpDeskRepository(String baseUrl) : super(baseUrl);

  void doSendHelpDesk(String subject, String message, onSuccess, onError) async {
    String token = await StorageManager.readData('token');
    var url = baseUrl + APIEndpoint.SEND_HELP_DESK;
    var uri = Uri.parse(url);
    final map = jsonEncode({"subject": subject, "message": message});

    try {
      var response = await ioClient.post(
        uri,
        body: map,
        headers: getDefaultHeaderWithToken(token),
      );

      String responseBody = response.body;
      Map<String, dynamic> responseJson = json.decode(responseBody);
      SendHelpDesk apiResponse = SendHelpDesk.fromJson(responseJson);
      if (apiResponse.success == true) {
        onSuccess(apiResponse);
      } else {
        onError(apiResponse);
      }
    } catch (exception) {
      onError(exception);
    }
  }
}
