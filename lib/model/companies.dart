class Companies {
  bool success;
  String message;
  List<DataCompanies> data;

  Companies({this.success, this.message, this.data});

  Companies.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data.add(DataCompanies.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DataCompanies {
  String id;
  String alias;
  String code;
  String name;

  DataCompanies({this.id, this.alias, this.code, this.name});

  DataCompanies.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    alias = json['alias'];
    code = json['code'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['alias'] = this.alias;
    data['code'] = this.code;
    data['name'] = this.name;
    return data;
  }
}
