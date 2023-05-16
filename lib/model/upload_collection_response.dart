class UploadCollectionResponse {
  bool success;
  String message;
  Data data;

  UploadCollectionResponse({this.success, this.message, this.data});

  UploadCollectionResponse.fromJson(Map<String, dynamic> json) {
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
  List<String> collectionPoint;

  Data({this.collectionPoint});

  Data.fromJson(Map<String, dynamic> json) {
    collectionPoint = json['collection_point'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['collection_point'] = this.collectionPoint;
    return data;
  }
}