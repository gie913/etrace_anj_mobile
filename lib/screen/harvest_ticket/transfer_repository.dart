import 'dart:convert';

import 'package:e_trace_app/base/api/api_configuration.dart';
import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/screen/harvest_ticket/transfer_harvest_ticket.dart';
import 'package:e_trace_app/model/transfer_response.dart';

class TransferRepository extends APIConfiguration {
  TransferRepository(String baseUrl) : super(baseUrl);

  void doTransferTicket(TransferHarvestingTicketBody transferBody, String token,
      onSuccess, onError) async {
    var url = this.baseUrl + APIEndpoint.SEND_HARVEST_TICKET;
    var uri = Uri.parse(url);
    final map =
        jsonEncode({"harvesting_ticket": transferBody.harvestingTicket});

    try {
      var response = await ioClient.post(
        uri,
        body: map,
        headers: getDefaultHeaderWithToken(token),
      );

      String responseBody = response.body;
      Map<String, dynamic> responseJson = json.decode(responseBody);
      TransferResponse apiResponse = TransferResponse.fromJson(responseJson);
      if (apiResponse.success == true) {
        onSuccess(apiResponse);
      } else {
        onError();
      }
    } catch (exception) {
      onError(exception);
    }
  }
}
