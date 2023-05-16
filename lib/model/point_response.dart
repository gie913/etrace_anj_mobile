class PointResponse {
  bool success;
  String message;
  Data data;

  PointResponse({this.success, this.message, this.data});

  PointResponse.fromJson(Map<String, dynamic> json) {
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
  int currentPoint;

  Data({this.currentPoint});

  Data.fromJson(Map<String, dynamic> json) {
    currentPoint = json['current_point'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_point'] = this.currentPoint;
    return data;
  }
}
