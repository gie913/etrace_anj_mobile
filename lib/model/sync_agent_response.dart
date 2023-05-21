import 'agents.dart';

class SyncAgentResponse {
  bool? success;
  String? message;
  Data? data;

  SyncAgentResponse({this.success, this.message, this.data});

  SyncAgentResponse.fromJson(Map<String, dynamic> json) {
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
  List<Agents>? agents;
  int? totalRows;

  Data({this.agents, this.totalRows});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['suppliers'] != null) {
      agents = [];
      json['suppliers'].forEach((v) {
        agents!.add(Agents.fromJson(v));
      });
    }
    totalRows = json['total_rows'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['suppliers'] = this.agents!.map((v) => v.toJson()).toList();
    data['total_rows'] = this.totalRows;
    return data;
  }
}
