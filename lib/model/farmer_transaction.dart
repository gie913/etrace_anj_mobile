class FarmerTransactions {
  bool success;
  String message;
  Data data;

  FarmerTransactions({this.success, this.message, this.data});

  FarmerTransactions.fromJson(Map<String, dynamic> json) {
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
  int activeYear;
  List<Farmer> farmer;
  List<String> blacklistedFarmer;

  Data({this.activeYear, this.farmer});

  Data.fromJson(Map<String, dynamic> json) {
    activeYear = json['active_year'];
    if (json['farmer'] != null) {
      farmer = <Farmer>[];
      json['farmer'].forEach((v) {
        farmer.add(new Farmer.fromJson(v));
      });
    }
    blacklistedFarmer = json['blacklisted_farmer'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['active_year'] = this.activeYear;
    if (this.farmer != null) {
      data['farmer'] = this.farmer.map((v) => v.toJson()).toList();
    }
    data['blacklisted_farmer'] = this.blacklistedFarmer;
    return data;
  }
}

class Farmer {
  String ascendFarmerCode;
  String ascendFarmerName;
  dynamic trYear;
  dynamic maxTonnageYear;
  dynamic groupingMonth;
  String trMonth;

  Farmer(
      {this.ascendFarmerCode,
      this.ascendFarmerName,
      this.trYear,
        this.maxTonnageYear,
        this.groupingMonth,
      this.trMonth});

  Farmer.fromJson(Map<String, dynamic> json) {
    ascendFarmerCode = json['ascend_farmer_code'];
    ascendFarmerName = json['ascend_farmer_name'];
    maxTonnageYear = json['max_tonnage_year'];
    trYear = json['tr_year'];
    groupingMonth = json['grouping_month_in_year'];
    trMonth = json['tr_month'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ascend_farmer_code'] = this.ascendFarmerCode;
    data['ascend_farmer_name'] = this.ascendFarmerName;
    data['max_tonnage_year'] = this.maxTonnageYear;
    data['tr_year'] = this.trYear;
    data['grouping_month_in_year'] = this.groupingMonth;
    if (this.trMonth != null) {
      data['tr_month'] = this.trMonth.toString();
    }
    return data;
  }
}