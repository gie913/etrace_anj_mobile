import 'package:e_trace_app/model/data_price.dart';

class PriceResponse {
  bool? success;
  String? message;
  DataPrice? dataPrice;

  PriceResponse({this.success, this.message, this.dataPrice});

  PriceResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    dataPrice =
        json['data'] != null ? new DataPrice.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    data['data'] = this.dataPrice!.toJson();
    return data;
  }
}
