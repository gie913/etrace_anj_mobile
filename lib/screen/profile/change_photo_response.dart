class ChangePhotoResponse {
  bool success;
  String message;
  List<Null> data;

  ChangePhotoResponse({this.success, this.message, this.data});

  ChangePhotoResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {}
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {}
    return data;
  }
}
