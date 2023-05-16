import 'dart:convert';
import 'dart:io';

import 'package:e_trace_app/base/api/api_configuration.dart';
import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/model/transfer_response.dart';
import 'package:e_trace_app/screen/harvest_ticket/transfer_harvest_ticket.dart';
import 'package:http/io_client.dart';

class SaveTransferRepository {
  String baseUrl;
  IOClient ioClient;

  SaveTransferRepository(String baseUrl) {
    this.baseUrl = baseUrl;
    HttpClient httpClient = new HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);
    this.ioClient = new IOClient(httpClient);
  }

  void doSaveTransferTicket(
      TransferHarvestingTicketBody transferBody, String token, onSuccess, onError) async {
    var url = this.baseUrl + APIEndpoint.SAVE_RECEIVE_ENDPOINT;
    var uri = Uri.parse(url);
    final map = jsonEncode({
      "harvesting_ticket": transferBody.harvestingTicket
    });

    try {
      var response = await ioClient.post(
        uri,
        body: map,
        headers: APIConfiguration(baseUrl).getDefaultHeaderWithToken(token),
      );

      String responseBody = response.body;
      Map<String, dynamic> responseJson = json.decode(responseBody);
      TransferResponse apiResponse = TransferResponse.fromJson(responseJson);
      onSuccess(apiResponse);
    } catch (exception) {
      onError(exception);
    }
  }
}