import 'package:e_trace_app/model/delivery_order.dart';

class UploadDeliveryOrder {
  List<DeliveryOrder> deliveryOrder;

  UploadDeliveryOrder({this.deliveryOrder});

  UploadDeliveryOrder.fromJson(Map<String, dynamic> json) {
    if (json['delivery_order'] != null) {
      deliveryOrder = [];
      json['delivery_order'].forEach((v) {
        deliveryOrder.add(DeliveryOrder.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.deliveryOrder != null) {
      data['delivery_order'] =
          this.deliveryOrder.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
