class ForgotPasswordResponse {
  bool? success;
  String? message;
  List<Null>? data;

  ForgotPasswordResponse({this.success, this.message, this.data});

  ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    return data;
  }
}
