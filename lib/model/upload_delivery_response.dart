class UploadDeliveryResponse {
  bool? success;
  String? message;
  Data? data;

  UploadDeliveryResponse({this.success, this.message, this.data});

  UploadDeliveryResponse.fromJson(Map<String, dynamic> json) {
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
  List<String>? deliveryOrder;

  Data({this.deliveryOrder});

  Data.fromJson(Map<String, dynamic> json) {
    deliveryOrder = json['delivery_order'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['delivery_order'] = this.deliveryOrder;
    return data;
  }
}
