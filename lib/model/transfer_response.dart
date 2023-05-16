class TransferResponse {
  bool success;
  String message;
  Data data;

  TransferResponse({this.success, this.message, this.data});

  TransferResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Data {
  List<String> harvestingTicket;

  Data({this.harvestingTicket});

  Data.fromJson(Map<String, dynamic> json) {
    harvestingTicket = json['harvesting_ticket'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['harvesting_ticket'] = this.harvestingTicket;
    return data;
  }
}