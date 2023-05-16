import 'package:e_trace_app/model/collection_point.dart';

class UploadCollectionPoint {
  List<CollectionPoint> collectionPoint;

  UploadCollectionPoint({this.collectionPoint});

  UploadCollectionPoint.fromJson(Map<String, dynamic> json) {
    if (json['collection_point'] != null) {
      collectionPoint = [];
      json['collection_point'].forEach((v) {
        collectionPoint.add (CollectionPoint.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.collectionPoint != null) {
      data['collection_point'] =
          this.collectionPoint.map((v) => v.toJson()).toList();
    }
    return data;
  }
}