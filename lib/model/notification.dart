class NotificationModel {
  String? referenceId;
  String? toPage;
  String? action;
  String? text;

  NotificationModel({this.referenceId, this.toPage, this.action, this.text});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    referenceId = json['reference_id'];
    toPage = json['to_page'];
    action = json['action'];
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['reference_id'] = this.referenceId;
    data['to_page'] = this.toPage;
    data['action'] = this.action;
    data['text'] = this.text;
    return data;
  }
}
