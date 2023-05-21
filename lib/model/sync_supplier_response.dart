import 'suppliers.dart';

class SyncSupplierResponse {
  bool? success;
  String? message;
  Data? data;

  SyncSupplierResponse({this.success, this.message, this.data});

  SyncSupplierResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    data['data'] = this.data!.toJson();
    return data;
  }
}

class Data {
  List<Suppliers>? suppliers;
  int? totalRows;

  Data({this.suppliers, this.totalRows});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['suppliers'] != null) {
      suppliers = [];
      json['suppliers'].forEach((v) {
        suppliers!.add(Suppliers.fromJson(v));
      });
    }
    totalRows = json['total_rows'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['suppliers'] = this.suppliers!.map((v) => v.toJson()).toList();
    data['total_rows'] = this.totalRows;
    return data;
  }
}
