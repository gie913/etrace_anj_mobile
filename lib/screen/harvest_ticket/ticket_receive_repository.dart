import 'dart:convert';

import 'package:e_trace_app/base/api/api_configuration.dart';
import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/model/receive_ticket_response.dart';
import 'package:e_trace_app/utils/storage_manager.dart';

class ReceiveTicketRepository extends APIConfiguration {
  ReceiveTicketRepository(String baseUrl) : super(baseUrl);

  void doReceiveTicket(onSuccess, onError) async {
    String token = await StorageManager.readData('token');
    try {
      var url = baseUrl! + APIEndpoint.RECEIVE_HARVEST_TICKET;
      var uri = Uri.parse(url);
      var response = await ioClient!.get(
        uri,
        headers: getDefaultHeaderWithToken(token),
      );
      ReceiveResponse apiResponse =
          ReceiveResponse.fromJson(json.decode(response.body));
      if (apiResponse.success == true) {
        onSuccess(apiResponse.data!.harvestingTicket);
      } else {
        onError(apiResponse.message);
      }
    } catch (exception) {
      onError(exception.toString());
    }
  }
}
