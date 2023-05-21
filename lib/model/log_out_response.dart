class LogOutResponse {
  bool? success;
  int? code;
  String? message;
  List<Null>? data;

  LogOutResponse({this.success, this.code, this.message, this.data});

  LogOutResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['code'] = this.code;
    data['message'] = this.message;
    return data;
  }
}
