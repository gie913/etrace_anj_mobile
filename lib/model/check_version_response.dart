class CheckVersionResponse {
  bool success;
  String message;
  DataTopics data;

  CheckVersionResponse({this.success, this.message, this.data});

  CheckVersionResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new DataTopics.fromJson(json['data']) : null;
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

class DataTopics {
  List<String> topics;

  DataTopics({this.topics});

  DataTopics.fromJson(Map<String, dynamic> json) {
    topics = json['topics'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['topics'] = this.topics;
    return data;
  }
}

class DataVersion {
  String currentAppVersion;
  String platform;
  int isForceUpdate;
  String redirectLink;

  DataVersion(
      {this.currentAppVersion,
        this.platform,
        this.isForceUpdate,
        this.redirectLink});

  DataVersion.fromJson(Map<String, dynamic> json) {
    currentAppVersion = json['current_app_version'];
    platform = json['platform'];
    isForceUpdate = json['is_force_update'];
    redirectLink = json['redirect_link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_app_version'] = this.currentAppVersion;
    data['platform'] = this.platform;
    data['is_force_update'] = this.isForceUpdate;
    data['redirect_link'] = this.redirectLink;
    return data;
  }
}