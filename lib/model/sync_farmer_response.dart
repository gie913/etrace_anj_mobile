import 'farmers.dart';

class SyncFarmerResponse {
  bool? success;
  String? message;
  Data? data;

  SyncFarmerResponse({this.success, this.message, this.data});

  SyncFarmerResponse.fromJson(Map<String, dynamic> json) {
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
  List<Farmers>? farmers;
  int? totalRows;
  dynamic abw;

  Data({this.farmers, this.totalRows, this.abw});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['farmers'] != null) {
      farmers = [];
      json['farmers'].forEach((v) {
        farmers!.add(new Farmers.fromJson(v));
      });
    }
    totalRows = json['total_rows'];
    abw = json['abw'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['farmers'] = this.farmers!.map((v) => v.toJson()).toList();
    data['total_rows'] = this.totalRows;
    data['abw'] = this.abw;
    return data;
  }
}
