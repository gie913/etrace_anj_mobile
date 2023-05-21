import 'harvesting_ticket.dart';

class ReceiveResponse {
  bool? success;
  String? message;
  Data? data;

  ReceiveResponse({this.success, this.message, this.data});

  ReceiveResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    data['data'] = this.data!.toJson();
    return data;
  }
}

class Data {
  List<HarvestingTicket>? harvestingTicket;

  Data({this.harvestingTicket});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['harvesting_ticket'] != null) {
      harvestingTicket = [];
      json['harvesting_ticket'].forEach((v) {
        harvestingTicket!.add(new HarvestingTicket.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['harvesting_ticket'] =
        this.harvestingTicket!.map((v) => v.toJson()).toList();
    return data;
  }
}
