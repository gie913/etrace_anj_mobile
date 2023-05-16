import 'dart:convert';

import 'package:e_trace_app/base/api/api_configuration.dart';
import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/model/upload_collection_point.dart';
import 'package:e_trace_app/model/upload_collection_response.dart';
import 'package:e_trace_app/model/upload_delivery_order.dart';
import 'package:e_trace_app/model/upload_delivery_response.dart';
import 'package:e_trace_app/model/upload_harvest_response.dart';
import 'package:e_trace_app/model/upload_harvest_ticket.dart';

class UploadRepository extends APIConfiguration{
  UploadRepository(String baseUrl) : super(baseUrl);


  void doUploadHarvestTicket(String token,
      UploadHarvestTicket uploadBodyHarvestTicket, onSuccess, onError) async {
    var url = baseUrl + APIEndpoint.UPLOAD_HARVEST_TICKET;
    var uri = Uri.parse(url);
    final map = jsonEncode(
        {"harvesting_ticket": uploadBodyHarvestTicket.harvestingTicket});

    try {
      var response = await ioClient.post(
        uri,
        body: map,
        headers: getDefaultHeaderWithToken(token),
      );

      String responseBody = response.body;
      Map<String, dynamic> responseJson = json.decode(responseBody);
      UploadHarvestResponse apiResponse =
          UploadHarvestResponse.fromJson(responseJson);
      if (apiResponse.success == true) {
        onSuccess(apiResponse);
      } else {
        onError(apiResponse);
      }
    } catch (exception) {
      onError(exception);
    }
  }

  void doUploadCollectionPoint(String token,
      UploadCollectionPoint uploadCollectionPoint, onSuccess, onError) async {
    var url = baseUrl + APIEndpoint.UPLOAD_COLLECTION_POINT;
    var uri = Uri.parse(url);
    final map =
        jsonEncode({"collection_point": uploadCollectionPoint.collectionPoint});

    try {
      var response = await ioClient.post(
        uri,
        body: map,
        headers: getDefaultHeaderWithToken(token),
      );

      String responseBody = response.body;
      Map<String, dynamic> responseJson = json.decode(responseBody);
      UploadCollectionResponse apiResponse =
          UploadCollectionResponse.fromJson(responseJson);
      if (apiResponse.success == true) {
        onSuccess(apiResponse);
      } else {
        onError();
      }
    } catch (exception) {
      onError(exception);
    }
  }

  void doUploadDeliveryOrder(String token,
      UploadDeliveryOrder uploadDeliveryOrder, onSuccess, onError) async {
    var url = baseUrl + APIEndpoint.UPLOAD_DELIVERY_ORDER;
    var uri = Uri.parse(url);
    final map =
        jsonEncode({"delivery_order": uploadDeliveryOrder.deliveryOrder});
    try {
      var response = await ioClient.post(
        uri,
        body: map,
        headers: getDefaultHeaderWithToken(token),
      );

      String responseBody = response.body;
      Map<String, dynamic> responseJson = json.decode(responseBody);
      UploadDeliveryResponse apiResponse =
          UploadDeliveryResponse.fromJson(responseJson);
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
