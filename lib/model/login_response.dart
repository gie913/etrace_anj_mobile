import 'package:e_trace_app/model/access.dart';
import 'package:e_trace_app/model/user.dart';

class LoginResponse {
  bool success;
  String message;
  Data data;

  LoginResponse({this.success, this.message, this.data});

  LoginResponse.fromJson(Map<String, dynamic> json) {
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
  String token;
  User user;
  List<Access> access;
  int useMaxTonnage;

  Data({this.token, this.user, this.access});

  Data.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    if (json['access'] != null) {
      access = [];
      json['access'].forEach((v) {
        access.add(new Access.fromJson(v));
      });
    }
    useMaxTonnage = json['use_max_tonnage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    if (this.access != null) {
      data['access'] = this.access.map((v) => v.toJson()).toList();
    }
    data['use_max_tonnage'] = this.useMaxTonnage;
    return data;
  }
}
