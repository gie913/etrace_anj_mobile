import 'dart:convert';
import 'dart:io';

import 'package:e_trace_app/base/api/api_configuration.dart';
import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/model/sync_agent_response.dart';
import 'package:http/io_client.dart';

class AgentRepository {

  String baseUrl;
  IOClient ioClient;

  AgentRepository(String baseUrl) {
    this.baseUrl = baseUrl;
    HttpClient httpClient = new HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);
    this.ioClient = new IOClient(httpClient);
  }

  void doSyncAgent(String token, String lastSync, onSuccess, onError) async {
    String timeLastSync;
    if (lastSync == null) {
      timeLastSync = "";
    } else {
      timeLastSync = "/?last_updated_at=$lastSync";
    }
    try {
      var url = baseUrl + APIEndpoint.SYNC_DATA_AGENT + timeLastSync;
      var uri = Uri.parse(url);
      var response = await ioClient.get(
        uri,
        headers: APIConfiguration(baseUrl).getDefaultHeaderWithToken(token),
      );
      SyncAgentResponse apiResponse =
      SyncAgentResponse.fromJson(json.decode(response.body));
      if (apiResponse.success == true) {
        onSuccess(apiResponse.data.agents);
      } else {
        onError(apiResponse.message);
      }
    } catch (exception) {
      onError(exception);
    }
  }
}
